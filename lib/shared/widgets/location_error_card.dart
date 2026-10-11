import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Tarjeta de error de ubicación con acciones Reintentar + Ajustes.
/// Reutilizada en Leer, Seguir y Mapa: mismo mensaje, mismo manejo
/// del permiso negado (`denied` → reintentar, `deniedForever` → ajustes).
class LocationErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onSettings;
  const LocationErrorCard({
    super.key,
    required this.message,
    this.onRetry,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.error_outline,
                    color: AppColors.danger, size: 20),
                SizedBox(width: 8),
                Text('Sin ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(message),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reintentar'),
                  ),
                if (onSettings != null)
                  OutlinedButton.icon(
                    onPressed: onSettings,
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text('Ajustes'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
