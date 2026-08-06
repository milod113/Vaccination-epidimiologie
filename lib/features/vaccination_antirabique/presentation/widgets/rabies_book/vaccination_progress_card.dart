import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import 'rabies_book_utils.dart';

/// Résumé visuel de la progression du protocole (barre premium + doses).
class VaccinationProgressCard extends StatelessWidget {
  final ProtocoleVaccinalModel? protocol;

  const VaccinationProgressCard({super.key, this.protocol});

  @override
  Widget build(BuildContext context) {
    final p = protocol;
    final done = p?.dosesAdministrees ?? 0;
    final total = p?.totalDoses ?? 0;
    final remaining = p?.dosesRestantes ?? 0;
    final percent = total == 0 ? 0 : (done / total).clamp(0.0, 1.0);
    final pct = (percent * 100).round();

    return bookCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.track_changes_rounded, color: EpidemiologyTheme.redPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progression du protocole', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800)),
                    Text('$done / $total doses administrées', style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm500)),
                  ],
                ),
              ),
              Text('$pct%', style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w800, color: total == 0 ? EpidemiologyTheme.warm300 : EpidemiologyTheme.redPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          if (total > 0)
            EpidemiologyTheme.doseProgress(current: done, total: total, height: 12)
          else
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm100,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Prévues', '$total', EpidemiologyTheme.warm600, Icons.event_note_rounded),
              _stat('Réalisées', '$done', EpidemiologyTheme.success, Icons.check_circle_outline_rounded),
              _stat('Restantes', '$remaining', remaining == 0 ? EpidemiologyTheme.success : EpidemiologyTheme.warning, Icons.hourglass_bottom_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 1),
            Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm500)),
          ],
        ),
      ),
    );
  }
}