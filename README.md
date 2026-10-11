# ¿Dónde estás? GPS en Flutter con geolocator + flutter_map (OSM)

Demo universitaria: de `pubspec.yaml` a tu primera coordenada en **Android, iOS y Web**.
Misma API de lectura (`geolocator`), tres contratos con el usuario. Mapa con `flutter_map` + OpenStreetMap (sin API Key).

## Qué incluye

- **Leer una vez:** `getCurrentPosition(accuracy: high)` + `getLastKnownPosition()`.
- **Seguir en vivo:** `getPositionStream(distanceFilter: 10)` + `distanceBetween` / `bearingBetween`.
- **Mapa en vivo:** `FlutterMap` centrado en tu posición, marcador + ruta con `PolylineLayer`. Atribución © OpenStreetMap.
- **Permiso:** estado servicio + permiso, pantalla previa, ir a Ajustes en `deniedForever`.
- **Slides:** `slides/index.html` (10 secciones, sin build, abre en navegador).

## Paquetes

| Paquete | Para qué | Plataformas |
|---|---|---|
| [geolocator ^14.1.1](https://pub.dev/packages/geolocator) | Permisos, `Position`, lectura y stream. Usa `FusedLocationProviderClient` en Android, `CLLocationManager` en iOS, Geolocation API en Web. | Android · iOS · macOS · Web |
| [flutter_map ^8.3.2](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2) | Render del mapa OSM, marcador y ruta. Sin key ni facturación. | Android · iOS · Web · Desktop |

## Requisitos

- Flutter 3.35+ / Dart 3.9+ (`flutter --version`)
- Android Studio o Xcode para emulador / dispositivo
- Internet (los tiles OSM se descargan en vivo)

## Instalación

```bash
flutter pub get
# Android / iOS
flutter run
# Web (recuerda: solo HTTPS, localhost permitido)
flutter run -d chrome
```

## Configuración de permisos

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

Hijos directos de `<manifest>`. En tiempo de ejecución el plugin pide el diálogo del sistema.

### iOS — `ios/Runner/Info.plist`

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Usamos tu ubicación para mostrar tu posición en el mapa y seguir tu recorrido durante la demo.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación incluso en segundo plano solo si activas el seguimiento continuo.</string>
```

Sin `NSLocationWhenInUseUsageDescription` el permiso falla. El texto lo escribes tú: aparece en el diálogo.

### Web — sin archivo

El navegador pide el permiso al llamar la API. Exige **HTTPS** (`localhost` es excepción).
No existen en Web: `getLastKnownPosition`, `openAppSettings`, `getServiceStatusStream`.

## Lógica principal

```dart
// 1. Servicio + permiso (lib/core/services/location_service.dart)
final ok = await Geolocator.isLocationServiceEnabled();
var p = await Geolocator.checkPermission();
if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
if (p == LocationPermission.deniedForever) await Geolocator.openAppSettings();

// 2. Lectura única
final pos = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
);

// 3. Seguimiento (10 m mínimo, cancela al salir)
final sub = Geolocator.getPositionStream(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high, distanceFilter: 10),
).listen((pos) { /* actualizar UI / mapa */ });

// 4. Mapa OSM (lib/features/map/map_screen.dart)
FlutterMap(
  mapController: map,
  options: MapOptions(
    initialCenter: LatLng(pos.latitude, pos.longitude),
    initialZoom: 16),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app_geolocator'),
    MarkerLayer(markers: [miPosicion]),
    PolylineLayer(polylines: [ruta]),
  ],
);
```

Manejo de negación:

| Estado | Qué hace la app |
|---|---|
| `denied` | Explica para qué + botón Reintentar |
| `deniedForever` | Explica + botón Abrir ajustes (`openAppSettings`, solo móvil) |
| Servicio apagado | Avisa "Activa el GPS" y no intenta leer |
| Timeout 15 s | `LocationFailure('Tiempo de espera agotado…')` |

## Estructura

```
lib/
  main.dart
  app/app.dart            # tabs: Inicio · Leer · Seguir · Mapa · Permiso
  core/services/location_service.dart  # determinarPosicion, streamPosicion, abrirAjustes
  core/utils/format.dart
  features/home|read_once|tracking|map|compare
slides/                   # presentación rediseñada (HTML+CSS+JS)
```

## Guion demo (2–3 min, rúbrica punto 5)

1. **Aceptar:** tab Leer → permitir → muestra lat/lon/±m. Tab Mapa → punto + ruta.
2. **Negar:** revoca en ajustes → Reintentar → muestra tarjeta "Sin ubicación" + Abrir ajustes.
3. **Web:** abre en HTTPS, muestra diálogo del navegador.

## Slides

Abre `slides/index.html` en el navegador. 10 secciones: portada → agenda → qué es → hardware → casos → paquetes → permisos → implementación → demo/fallos → cierre. Sin dependencias, respeta `prefers-reduced-motion`.

## Subir a GitHub

```bash
git init
git add .
git commit -m "GPS en Flutter: geolocator + flutter_map (OSM, sin key)"
gh repo create app_geolocator --public --source=. --push
# o: crea repo vacío en github.com y:
git remote add origin https://github.com/TU_USUARIO/app_geolocator.git
git branch -M main
git push -u origin main
```

Pega la URL del repo en la slide 10 (Cierre).

## Equipo

Josheph Martinez · Oscar Duque · Sebastian Carrillo — Exposición universitaria, oct 2026.
