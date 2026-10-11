import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/location_service.dart';
import '../../theme/app_colors.dart';

/// Permiso: ver estado, pedir y abrir ajustes. Sin teoría.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  final _service = const LocationService();
  LocationPermission? _permiso;
  bool? _gps;
  String? _mensaje;

  Future<void> _revisar() async {
    final g = await Geolocator.isLocationServiceEnabled();
    final p = await _service.estadoPermiso();
    setState(() {
      _gps = g;
      _permiso = p;
      _mensaje = null;
    });
  }

  Future<void> _pedir() async {
    final seguir = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Usar tu ubicación'),
        content: const Text(
          'La usamos solo para mostrarte tu posición y tu ruta. '
          'Puedes detenerlo cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ahora no'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (seguir != true) return;
    final p = await _service.pedirPermiso();
    setState(() {
      _permiso = p;
      _mensaje = switch (p) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          'Concedido. Ya puedes usar Leer, Seguir y Mapa.',
        LocationPermission.denied =>
          'Denegado. Puedes reintentarlo.',
        LocationPermission.deniedForever =>
          'Bloqueado. Abre Ajustes para habilitarlo.',
        LocationPermission.unableToDetermine => 'Sin determinar.',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _revisar();
  }

  @override
  Widget build(BuildContext context) {
    final gpsOk = _gps ?? false;
    final permOk = _permiso == LocationPermission.whileInUse ||
        _permiso == LocationPermission.always;
    return Scaffold(
      appBar: AppBar(title: const Text('Permiso')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _Fila(
                    icon: Icons.gps_fixed,
                    titulo: 'GPS del sistema',
                    valor: _gps == null
                        ? '…'
                        : (gpsOk ? 'Activado' : 'Apagado'),
                    ok: gpsOk,
                  ),
                  const SizedBox(height: 12),
                  _Fila(
                    icon: Icons.lock_outline,
                    titulo: 'Permiso de la app',
                    valor: _permiso == null
                        ? '…'
                        : LocationService.textoPermiso(_permiso!)
                            .split(':')
                            .first,
                    ok: permOk,
                  ),
                  if (_mensaje != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Text(_mensaje!),
                    ),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pedir,
                      icon: const Icon(Icons.lock_open_outlined, size: 19),
                      label: const Text('Pedir permiso'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _revisar,
                          icon: const Icon(Icons.refresh, size: 19),
                          label: const Text('Revisar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _service.abrirAjustes,
                          icon:
                              const Icon(Icons.settings_outlined, size: 19),
                          label: const Text('Ajustes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String valor;
  final bool ok;
  const _Fila(
      {required this.icon,
      required this.titulo,
      required this.valor,
      required this.ok});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: (ok ? AppColors.success : AppColors.warning)
                .withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon,
              color: ok ? AppColors.success : AppColors.warning,
              size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              Text(valor,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: ok ? AppColors.success : AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
