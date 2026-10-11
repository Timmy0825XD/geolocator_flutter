import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/location_service.dart';
import '../../theme/app_colors.dart';

/// Inicio: estado del GPS + accesos directos. Sin teoría.
class HomeScreen extends StatefulWidget {
  final ValueChanged<int> onGo;
  const HomeScreen({super.key, required this.onGo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = const LocationService();
  bool? _gps;
  LocationPermission? _permiso;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final gps = await Geolocator.isLocationServiceEnabled();
    final p = await _service.estadoPermiso();
    if (!mounted) return;
    setState(() {
      _gps = gps;
      _permiso = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ok = (_gps ?? false) &&
        (_permiso == LocationPermission.whileInUse ||
            _permiso == LocationPermission.always);
    return Scaffold(
      appBar: AppBar(title: const Text('GPS en Flutter')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Estado
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (ok
                                    ? AppColors.success
                                    : AppColors.primary)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            ok
                                ? Icons.satellite_alt
                                : Icons.satellite_alt_outlined,
                            color: ok
                                ? AppColors.success
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ok ? 'Listo para ubicarte' : 'Revisa tu GPS',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                'GPS: ${_gps == null ? '…' : (_gps! ? 'activado' : 'apagado')} · '
                                'Permiso: ${_permiso == null ? '…' : LocationService.textoPermiso(_permiso!).split(':').first}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Actualizar estado',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onGo(4),
                        icon: const Icon(Icons.lock_open_outlined, size: 19),
                        label: const Text('Ver permiso'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Acciones
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _Action(
                  icon: Icons.my_location,
                  title: 'Leer',
                  sub: 'Posición actual',
                  onTap: () => widget.onGo(1),
                ),
                _Action(
                  icon: Icons.route,
                  title: 'Seguir',
                  sub: 'Ruta en vivo',
                  onTap: () => widget.onGo(2),
                ),
                _Action(
                  icon: Icons.map,
                  title: 'Mapa',
                  sub: 'Ver en mapa',
                  onTap: () => widget.onGo(3),
                ),
                _Action(
                  icon: Icons.history,
                  title: 'Última',
                  sub: 'Posición guardada',
                  onTap: () => widget.onGo(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _Action(
      {required this.icon,
      required this.title,
      required this.sub,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
