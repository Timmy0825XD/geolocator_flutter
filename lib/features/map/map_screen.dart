import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/location_service.dart';
import '../../core/utils/format.dart';
import '../../shared/widgets/widgets.dart';
import '../../theme/app_colors.dart';

/// Mapa con OpenStreetMap (flutter_map, sin API Key).
/// `geolocator` da la posición, `flutter_map` la dibuja.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _service = const LocationService();
  final _map = MapController();
  StreamSubscription<Position>? _sub;

  static const _inicial = LatLng(4.7110, -74.0721);

  Position? _pos;
  final List<LatLng> _ruta = [];
  String? _error;
  bool _cargando = true;
  bool _siguiendo = false;
  bool _mapaListo = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _map.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final pos = await _service.determinarPosicion();
      _aplicar(pos);
      _seguir();
      setState(() => _siguiendo = true);
    } on LocationFailure catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'No se pudo iniciar el mapa: $e');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _aplicar(Position p) {
    final punto = LatLng(p.latitude, p.longitude);
    setState(() {
      _pos = p;
      _ruta.add(punto);
      if (_ruta.length > 100) _ruta.removeAt(0);
    });
    if (_mapaListo) _map.move(punto, 16);
  }

  void _seguir() {
    _sub?.cancel();
    _sub = _service.streamPosicion().listen(
      _aplicar,
      onError: (Object e) {
        if (mounted) setState(() => _error = 'Error del stream: $e');
      },
    );
  }

  Future<void> _detener() async {
    await _sub?.cancel();
    _sub = null;
    if (mounted) setState(() => _siguiendo = false);
  }

  @override
  Widget build(BuildContext context) {
    final centro = _pos == null
        ? _inicial
        : LatLng(_pos!.latitude, _pos!.longitude);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          if (_siguiendo) const LiveBadge(),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 16,
              minZoom: 3,
              maxZoom: 19,
              onMapReady: () {
                _mapaListo = true;
                if (_pos != null) {
                  _map.move(
                      LatLng(_pos!.latitude, _pos!.longitude), 16);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_geolocator',
                maxNativeZoom: 19,
              ),
              if (_ruta.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _ruta,
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              if (_pos != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                          _pos!.latitude, _pos!.longitude),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                        ),
                        child: const Icon(Icons.my_location,
                            color: AppColors.primary, size: 22),
                      ),
                    ),
                  ],
                ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap',
                  ),
                ],
              ),
            ],
          ),
          if (_cargando)
            const Center(child: CircularProgressIndicator()),
          if (_error != null && !_cargando)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: LocationErrorCard(
                message: _error!,
                onRetry: _iniciar,
                onSettings: _service.abrirAjustes,
              ),
            ),
          if (_pos != null && _error == null && !_cargando)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Card(
                child: ListTile(
                  dense: true,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color:
                          AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.my_location,
                        color: AppColors.primary, size: 20),
                  ),
                  title: Text(resumenPosicion(_pos!),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '±${_pos!.accuracy.toStringAsFixed(0)} m · ${fechaCorta(_pos!.timestamp)} · ${_ruta.length} pts',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  trailing: IconButton(
                    icon: Icon(
                        _siguiendo ? Icons.stop : Icons.play_arrow),
                    tooltip: _siguiendo ? 'Detener' : 'Seguir',
                    onPressed: _siguiendo
                        ? _detener
                        : () {
                            _seguir();
                            setState(() => _siguiendo = true);
                          },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
