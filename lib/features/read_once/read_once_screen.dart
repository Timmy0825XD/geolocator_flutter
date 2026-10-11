import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/location_service.dart';
import '../../shared/widgets/widgets.dart';

/// Leer: posición actual + última guardada. Sin teoría.
class ReadOnceScreen extends StatefulWidget {
  const ReadOnceScreen({super.key});

  @override
  State<ReadOnceScreen> createState() => _ReadOnceScreenState();
}

class _ReadOnceScreenState extends State<ReadOnceScreen> {
  final _service = const LocationService();
  Position? _pos;
  Position? _lastKnown;
  String? _error;
  bool _cargando = false;

  Future<void> _leer() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final pos = await _service.determinarPosicion();
      if (mounted) setState(() => _pos = pos);
    } on LocationFailure catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _ultima() async {
    final last = await _service.ultimaConocida();
    setState(() {
      _lastKnown = last;
      _error = last == null ? 'Sin última posición guardada.' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leer posición')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _cargando ? null : _leer,
              icon: _cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 19),
              label: Text(_cargando ? 'Leyendo…' : 'Leer mi posición'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _ultima,
              icon: const Icon(Icons.history, size: 19),
              label: const Text('Ver última guardada'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            LocationErrorCard(
              message: _error!,
              onRetry: _leer,
              onSettings: _service.abrirAjustes,
            ),
          ],
          if (_pos != null) ...[
            const SizedBox(height: 12),
            PositionCard(title: 'Actual', position: _pos!),
          ],
          if (_lastKnown != null) ...[
            const SizedBox(height: 8),
            PositionCard(
                title: 'Guardada', position: _lastKnown!, live: false),
          ],
          if (_pos == null && _lastKnown == null && _error == null)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.explore_outlined,
                message: 'Pulsa el botón para obtener tu ubicación.',
              ),
            ),
        ],
      ),
    );
  }
}
