// lib/widgets/app_button.dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String   label;
  final VoidCallback? onPressed;
  final bool     loading;
  final IconData? icon;
  final Color?   color;
  final bool     outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading  = false,
    this.icon,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveColor = color ?? scheme.primary;

    if (outlined) {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          side: BorderSide(color: effectiveColor),
          minimumSize: const Size(double.infinity, 48),
        ),
        child: _child(effectiveColor),
      );
    }

    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _child(Colors.white),
    );
  }

  Widget _child(Color color) {
    if (loading) {
      return SizedBox(
        width: 22, height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
