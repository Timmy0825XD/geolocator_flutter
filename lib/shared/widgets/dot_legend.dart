import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Leyenda punto + etiqueta (inicio/ruta/fin en la gráfica).
class DotLegend extends StatelessWidget {
  final Color color;
  final String label;
  const DotLegend({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
