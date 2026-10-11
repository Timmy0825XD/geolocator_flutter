import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/location_service.dart';
import '../../core/utils/format.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_colors.dart';
import 'route_graph_screen.dart';

/// Seguir: ruta en vivo + dirección, velocidad, checkpoints
/// automáticos cada 2 s y gráfica del movimiento.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _service = const LocationService();
  StreamSubscription<Position>? _sub;
  Timer? _timer;

  final List<Position> _puntos = [];
  final List<Position> _checks = [];
  Position? _actual;
  String? _error;

  bool get _on => _sub != null;

  Future<void> _iniciar() async {
    setState(() => _error = null);
    try {
      await _service.determinarPosicion();
    } on LocationFailure catch (e) {
      setState(() => _error = e.message);
      return;
    }
    _sub = _service.streamPosicion().listen(
      (p) {
        if (!mounted) return;
        setState(() {
          _actual = p;
          _puntos.insert(0, p);
          if (_puntos.length > 50) _puntos.removeLast();
        });
      },
      onError: (Object e) {
        if (mounted) setState(() => _error = 'Error del stream: $e');
      },
    );
    // Checkpoint automático cada 2 s con la última posición real.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final p = _actual;
      if (!mounted || p == null) return;
      setState(() {
        // Guarda solo si es un fix distinto al último checkpoint.
        if (_checks.isEmpty || _checks.last != p) _checks.add(p);
      });
    });
    setState(() {});
  }

  Future<void> _detener() async {
    _timer?.cancel();
    _timer = null;
    await _sub?.cancel();
    _sub = null;
    if (mounted) setState(() {});
  }

  void _limpiar() {
    setState(() {
      _puntos.clear();
      _checks.clear();
      _actual = null;
      _error = null;
    });
  }

  void _verGrafica() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            RouteGraphScreen(checkpoints: List.of(_checks)),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rumbo entre los 2 últimos puntos (dirección real del movimiento).
    double? rumbo;
    if (_puntos.length >= 2) {
      rumbo = normalizarRumbo(
          _service.rumboEntre(_puntos[1], _puntos[0]));
    }
    // Velocidad: del GPS, o calculada entre fixes si el GPS da 0.
    double? velMS;
    if (_actual != null && _actual!.speed >= 0) velMS = _actual!.speed;
    if ((velMS == null || velMS <= 0) && _puntos.length >= 2) {
      final d = _service.distanciaEntre(_puntos[1], _puntos[0]);
      final t = _puntos[0]
          .timestamp
          .difference(_puntos[1].timestamp)
          .inMilliseconds /
          1000;
      if (t > 0) velMS = d / t;
    }
    final velKH = velMS == null ? null : velMS * 3.6;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguir ruta'),
        actions: [
          IconButton(
            onPressed:
                (_puntos.isEmpty && _checks.isEmpty) ? null : _limpiar,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar',
          ),
          if (_on) const LiveBadge(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _on ? null : _iniciar,
                  icon: const Icon(Icons.play_arrow, size: 19),
                  label: const Text('Iniciar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _on ? _detener : null,
                  icon: const Icon(Icons.stop, size: 19),
                  label: const Text('Detener'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dirección + velocidad en vivo.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Flecha que rota según el rumbo real.
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color:
                          AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Transform.rotate(
                      angle: (rumbo ?? 0) * math.pi / 180,
                      child: Icon(
                        Icons.navigation,
                        color: rumbo == null
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rumbo == null
                              ? 'Sin dirección aún'
                              : '${rumbo.toStringAsFixed(0)}° ${rumboCardinal(rumbo)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        Text(
                          velKH == null
                              ? 'Camina para medir velocidad'
                              : '${velKH.toStringAsFixed(1)} km/h · ${(velKH / 3.6).toStringAsFixed(1)} m/s',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Checkpoints + botón de gráfica.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined,
                          color: AppColors.teal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Checkpoints (${_checks.length})',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_on)
                        const Text('auto cada 2 s',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _checks.length >= 2
                          ? _verGrafica
                          : null,
                      icon: const Icon(Icons.show_chart, size: 19),
                      label: const Text('Graficar mi movimiento'),
                    ),
                  ),
                  if (_checks.length < 2)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Inicia el seguimiento: se necesitan 2+ checkpoints.',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            LocationErrorCard(
              message: _error!,
              onRetry: _iniciar,
              onSettings: _service.abrirAjustes,
            ),
          ],
          const SizedBox(height: 12),
          Text('Puntos (${_puntos.length})',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_puntos.isEmpty)
            const EmptyState(
              icon: Icons.route_outlined,
              message: 'Inicia y camina para ver puntos.',
            ),
          for (var i = 0; i < _puntos.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.18),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  title: Text(resumenPosicion(_puntos[i]),
                      style: const TextStyle(fontSize: 13)),
                  subtitle: Text(
                    '${fechaCorta(_puntos[i].timestamp)} · ${_puntos[i].speed.toStringAsFixed(1)} m/s',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
