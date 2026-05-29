import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PremiumButton extends StatelessWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool outlined;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon ?? Icons.arrow_forward),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.goldDeep,
              side: const BorderSide(color: AppColors.roseGold, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon ?? Icons.favorite),
            label: Text(label),
          );

    if (expand) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
