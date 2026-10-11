import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/utils/format.dart';
import '../../theme/app_colors.dart';

/// Ficha de una posición: encabezado con estado + rejilla de 6 datos
/// (latitud, longitud, precisión, altitud, velocidad, hora).
/// Extraída de Leer para reutilizarla donde se muestre un `Position`.
class PositionCard extends StatelessWidget {
  final String title;
  final Position position;

  /// `true` = fix en vivo (punto verde), `false` = guardada (ámbar).
  final bool live;
  const PositionCard({
    super.key,
    required this.title,
    required this.position,
    this.live = true,
  });

  @override
  Widget build(BuildContext context) {
    final pos = position;
    final datos = [
      ('Latitud', pos.latitude.toStringAsFixed(6)),
      ('Longitud', pos.longitude.toStringAsFixed(6)),
      ('Precisión', '±${pos.accuracy.toStringAsFixed(0)} m'),
      ('Altitud', '${pos.altitude.toStringAsFixed(0)} m'),
      ('Velocidad', '${pos.speed.toStringAsFixed(1)} m/s'),
      ('Hora', fechaCorta(pos.timestamp)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: live ? AppColors.success : AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(resumenPosicion(pos),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              children: [
                for (final d in datos)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(d.$1,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11)),
                        SelectableText(d.$2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
