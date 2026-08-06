import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';

/// Carte d'alerte premium du carnet vaccinal (retard, ERIG, traçabilité…).
class RabiesBookAlertBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const RabiesBookAlertBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.04)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(fontSize: 13.5, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm700, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}