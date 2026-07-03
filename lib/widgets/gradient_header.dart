import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;

  const GradientHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final gradientStart = isDark 
        ? AppTheme.headerGradientStartDark 
        : AppTheme.headerGradientStartLight;
    final gradientEnd = isDark 
        ? AppTheme.headerGradientEndDark 
        : AppTheme.headerGradientEndLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 60.0,
        bottom: 40.0,
        left: 24.0,
        right: 24.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black45 : Colors.blue.withValues(alpha: 0.2)),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge at the top
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon ?? Icons.analytics_outlined,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Extension to define colors that might not be standard
extension on Color {
  // We can use standard Colors.white70 if whiteB0 is not a standard color.
}
// Let's replace whiteB0 with Colors.white70 to be safe and avoid compilation issues.
