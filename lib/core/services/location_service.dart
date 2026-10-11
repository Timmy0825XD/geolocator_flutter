import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:geolocator/geolocator.dart';

/// Servicio central de ubicación (S10 + S15 + S16 + S19).
///
/// Agrupa el chequeo de permisos, la lectura única y el stream
/// con ajustes por plataforma.
class LocationService {
  const LocationService();

  /// Determina la posición actual verificando servicio y permisos.
  /// Lanza [LocationFailure] con mensaje en español si algo falla.
  Future<Position> determinarPosicion() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(
        'Servicio de ubicación apagado. Activa el GPS para continuar.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationFailure(
          'Permiso denegado. Concédelo para leer tu posición.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Permiso denegado para siempre. Ábrelo en Ajustes de la app.',
      );
    }

    try {
      // S11: lectura única con alta precisión.
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const LocationFailure(
          'Tiempo de espera agotado buscando el GPS.',
        ),
      );
    } catch (e) {
      if (e is LocationFailure) rethrow;
      throw LocationFailure('No se pudo leer la posición: $e');
    }
  }

  /// Última posición conocida (puede ser null si no hay caché).
  Future<Position?> ultimaConocida() {
    return Geolocator.getLastKnownPosition();
  }

  /// Estado actual del permiso sin pedirlo.
  Future<LocationPermission> estadoPermiso() {
    return Geolocator.checkPermission();
  }

  /// Pide el permiso al sistema.
  Future<LocationPermission> pedirPermiso() {
    return Geolocator.requestPermission();
  }

  /// Abre los ajustes de la app (caso deniedForever).
  Future<void> abrirAjustes() => Geolocator.openAppSettings();

  /// Stream de seguimiento en primer plano (demo).
  /// Sin servicio foreground ni wake lock: evita el crash
  /// `WAKE_LOCK` visto en logcat y basta para la demo en clase.
  Stream<Position> streamPosicion() {
    const distanceFilter = 10; // metros
    if (kIsWeb) {
      return Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
        ),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return Geolocator.getPositionStream(
        locationSettings: AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter,
          showBackgroundLocationIndicator: true,
          pauseLocationUpdatesAutomatically: true,
        ),
      );
    }
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Metros entre dos puntos (S14).
  double distanciaEntre(Position a, Position b) {
    return Geolocator.distanceBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  /// Rumbo en grados entre dos puntos (S14).
  double rumboEntre(Position a, Position b) {
    return Geolocator.bearingBetween(
      a.latitude,
      a.longitude,
      b.latitude,
      b.longitude,
    );
  }

  /// Texto legible del permiso para la UI.
  static String textoPermiso(LocationPermission p) {
    return switch (p) {
      LocationPermission.always => 'always: acceso total, incluso en fondo',
      LocationPermission.whileInUse =>
        'whileInUse: solo con la app visible',
      LocationPermission.denied => 'denied: denegado (se puede reintentar)',
      LocationPermission.deniedForever =>
        'deniedForever: bloqueado, ir a Ajustes',
      LocationPermission.unableToDetermine => 'sin determinar',
    };
  }
}

/// Error controlado con mensaje listo para mostrar en UI (S19).
class LocationFailure implements Exception {
  final String message;
  const LocationFailure(this.message);

  @override
  String toString() => message;
}
