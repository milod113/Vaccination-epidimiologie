import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/dashboard_antirabique_models.dart';

class AlertCard extends StatelessWidget {
  final AlerteAntirabiqueModel alerte;

  const AlertCard({super.key, required this.alerte});

  @override
  Widget build(BuildContext context) {
    final (Color accent, Color bg, IconData icon) = switch (alerte.severite) {
      AlerteSeverite.haute => (EpidemiologyTheme.danger, EpidemiologyTheme.dangerLight, Icons.error_outline),
      AlerteSeverite.moyenne => (EpidemiologyTheme.warning, EpidemiologyTheme.warningLight, Icons.warning_amber),
      AlerteSeverite.basse => (EpidemiologyTheme.info, EpidemiologyTheme.infoLight, Icons.info_outline),
    };

    return Container(
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(color: EpidemiologyTheme.blackWith(0.03), blurRadius: 6, offset: const Offset(0, 1)),
          BoxShadow(color: accent.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accent, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(alerte.type, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(alerte.severite.label,
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: accent)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(alerte.message,
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400,
                              color: EpidemiologyTheme.warm600, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
