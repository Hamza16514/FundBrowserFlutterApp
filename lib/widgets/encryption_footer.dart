import 'package:flutter/material.dart';

class EncryptionFooter extends StatelessWidget {
  const EncryptionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final iconColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Text(
          '256-bit encryption',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
