import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/format.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_colors.dart';

/// Gráfica del movimiento a partir de los checkpoints.
/// Muestra trayectoria, velocidad en el tiempo y estadísticas.
class RouteGraphScreen extends StatelessWidget {
  final List<Position> checkpoints;
  const RouteGraphScreen({super.key, required this.checkpoints});

  @override
  Widget build(BuildContext context) {
    final pts = List<Position>.of(checkpoints);
    double total = 0;
    double maxV = 0;
    for (var i = 0; i < pts.length; i++) {
      maxV = math.max(maxV, math.max(0, pts[i].speed));
      if (i > 0) {
        total += Geolocator.distanceBetween(
          pts[i - 1].latitude,
          pts[i - 1].longitude,
          pts[i].latitude,
          pts[i].longitude,
        );
      }
    }
    final dur = pts.length >= 2
        ? pts.last.timestamp.difference(pts.first.timestamp)
        : Duration.zero;
    final avgV = dur.inSeconds > 0 ? total / dur.inSeconds : 0.0;

    String durTxt() {
      final m = dur.inMinutes;
      final s = dur.inSeconds % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Gráfica del recorrido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trayectoria',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${pts.length} checkpoints · inicio ${fechaCorta(pts.first.timestamp)} → fin ${fechaCorta(pts.last.timestamp)}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _TrayectoriaPainter(pts),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DotLegend(color: AppColors.success, label: 'Inicio'),
                      DotLegend(color: AppColors.primary, label: 'Ruta'),
                      DotLegend(color: AppColors.danger, label: 'Fin'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Velocidad en el tiempo (km/h)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _VelocidadPainter(pts),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: StatItem(
                          title: 'Distancia',
                          value: '${total.toStringAsFixed(0)} m',
                          valueSize: 15)),
                  Expanded(
                      child:
                          StatItem(title: 'Duración', value: durTxt(), valueSize: 15)),
                  Expanded(
                      child: StatItem(
                          title: 'Vel. media',
                          value:
                              '${(avgV * 3.6).toStringAsFixed(1)} km/h',
                          valueSize: 15)),
                  Expanded(
                      child: StatItem(
                          title: 'Vel. máx',
                          value:
                              '${(maxV * 3.6).toStringAsFixed(1)} km/h',
                          valueSize: 15)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dibuja la ruta normalizada al lienzo + puntos inicio/fin.
class _TrayectoriaPainter extends CustomPainter {
  final List<Position> pts;
  _TrayectoriaPainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.bg;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)),
      bg,
    );
    if (pts.isEmpty) return;

    var minLat = pts.first.latitude, maxLat = pts.first.latitude;
    var minLon = pts.first.longitude, maxLon = pts.first.longitude;
    for (final p in pts) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLon = math.min(minLon, p.longitude);
      maxLon = math.max(maxLon, p.longitude);
    }
    // Evita división por cero cuando no hay movimiento.
    final dLat = math.max(maxLat - minLat, 1e-7);
    final dLon = math.max(maxLon - minLon, 1e-7);
    const pad = 24.0;
    Offset norm(Position p) => Offset(
          pad +
              (p.longitude - minLon) /
                  dLon *
                  (size.width - pad * 2),
          pad +
              (1 - (p.latitude - minLat) / dLat) *
                  (size.height - pad * 2),
        );

    final ruta = Path()..moveTo(norm(pts.first).dx, norm(pts.first).dy);
    for (var i = 1; i < pts.length; i++) {
      ruta.lineTo(norm(pts[i]).dx, norm(pts[i]).dy);
    }
    canvas.drawPath(
      ruta,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in pts.map(norm)) {
      canvas.drawCircle(p, 2.5, Paint()..color = AppColors.primary);
    }
    canvas.drawCircle(
        norm(pts.first), 7, Paint()..color = AppColors.success);
    canvas.drawCircle(
        norm(pts.last), 7, Paint()..color = AppColors.danger);
  }

  @override
  bool shouldRepaint(covariant _TrayectoriaPainter old) =>
      old.pts != pts;
}

/// Velocidad (km/h) por checkpoint con área bajo la curva.
class _VelocidadPainter extends CustomPainter {
  final List<Position> pts;
  _VelocidadPainter(this.pts);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.bg;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(12)),
      bg,
    );
    if (pts.length < 2) {
      _texto(canvas, size, 'Se necesitan 2+ checkpoints');
      return;
    }
    final v = [
      for (final p in pts) math.max(0, p.speed) * 3.6,
    ];
    final maxV = math.max(v.reduce(math.max), 1.0);
    const padL = 34.0, padB = 20.0, padT = 10.0, padR = 8.0;

    // Ejes.
    final eje = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    canvas.drawLine(Offset(padL, padT),
        Offset(padL, size.height - padB), eje);
    canvas.drawLine(Offset(padL, size.height - padB),
        Offset(size.width - padR, size.height - padB), eje);

    // Etiqueta del máximo.
    _texto(canvas, Size(padL - 4, 14),
        maxV.toStringAsFixed(0), dy: padT - 4);

    Offset punto(int i) => Offset(
          padL +
              i / (v.length - 1) * (size.width - padL - padR),
          padT +
              (1 - v[i] / maxV) *
                  (size.height - padT - padB),
        );
    final linea = Path()..moveTo(punto(0).dx, punto(0).dy);
    for (var i = 1; i < v.length; i++) {
      linea.lineTo(punto(i).dx, punto(i).dy);
    }
    final area = Path.from(linea)
      ..lineTo(punto(v.length - 1).dx, size.height - padB)
      ..lineTo(punto(0).dx, size.height - padB)
      ..close();
    canvas.drawPath(
        area, Paint()..color = AppColors.primary.withValues(alpha: 0.2));
    canvas.drawPath(
      linea,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    for (var i = 0; i < v.length; i++) {
      canvas.drawCircle(punto(i), 3, Paint()..color = AppColors.teal);
    }
  }

  void _texto(Canvas canvas, Size size, String txt, {double dy = 0}) {
    final tp = TextPainter(
      text: TextSpan(
          text: txt,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, Offset(0, (size.height - tp.height) / 2 + dy));
  }

  @override
  bool shouldRepaint(covariant _VelocidadPainter old) =>
      old.pts != pts;
}
