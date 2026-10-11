import 'package:geolocator/geolocator.dart';

/// Formatea una posición para mostrarla en la UI.
String resumenPosicion(Position p) {
  return '(${p.latitude.toStringAsFixed(6)}, '
      '${p.longitude.toStringAsFixed(6)}) ±${p.accuracy.toStringAsFixed(0)} m';
}

/// Fecha/hora corta legible.
String fechaCorta(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  final s = d.second.toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// Normaliza un rumbo a 0–360°.
double normalizarRumbo(double rumbo) => (rumbo % 360 + 360) % 360;

/// Punto cardinal en español (8 vientos) para un rumbo en grados.
String rumboCardinal(double rumbo) {
  const vientos = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
  final i = (normalizarRumbo(rumbo) / 45).round() % 8;
  return vientos[i];
}
