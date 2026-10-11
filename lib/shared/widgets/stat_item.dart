import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Dato título + valor para métricas (distancia, rumbo, velocidad…).
/// Reutilizado en Seguir y en la Gráfica del recorrido.
class StatItem extends StatelessWidget {
  final String title;
  final String value;
  final double valueSize;
  const StatItem({
    super.key,
    required this.title,
    required this.value,
    this.valueSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: valueSize)),
      ],
    );
  }
}
