import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Insignia "EN VIVO" para el `actions` de un AppBar.
/// Reutilizada en Seguir y Mapa.
class LiveBadge extends StatelessWidget {
  final String label;
  const LiveBadge({super.key, this.label = 'EN VIVO'});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fiber_manual_record,
              color: AppColors.success, size: 12),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
