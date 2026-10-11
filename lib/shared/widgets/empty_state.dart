import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Estado vacío genérico: icono + mensaje centrados en tarjeta.
/// Reutilizado en Leer, Seguir y Permiso.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState(
      {super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
