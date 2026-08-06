import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_traceability_summary.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/services/rabies_traceability_service.dart';
import 'traceability_ui.dart';

/// Bandeau compact de statut de traçabilité (carte + registre + événements).
///
/// Conçu pour la fiche J0 premium : synthèse lisible en une ligne sans ouvrir
/// un écran dédié. Le tap peut ouvrir l'écran de traçabilité via [onTap].
class TraceabilityStatusStrip extends StatelessWidget {
  final RabiesCaseRecord record;
  final VoidCallback? onTap;

  const TraceabilityStatusStrip({super.key, required this.record, this.onTap});

  @override
  Widget build(BuildContext context) {
    final summary = RabiesTraceabilityService.resume(record);
    final color = TraceabilityUi.traceabilityColor(summary.statut);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                TraceabilityUi.traceabilityIcon(summary.statut),
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traçabilité',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: EpidemiologyTheme.slate500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _ligne(summary),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: EpidemiologyTheme.slate800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${summary.pointsOk}/${summary.totalPoints}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  '${summary.nombreEvenements} év.',
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: EpidemiologyTheme.slate500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: EpidemiologyTheme.slate400),
          ],
        ),
      ),
    );
  }

  String _ligne(RabiesTraceabilitySummary s) {
    final parts = <String>[
      s.carteRemise ? 'Carte remise' : 'Carte non remise',
      s.registreRenseigne ? '· registre OK' : '· registre manquant',
    ];
    return parts.join(' ');
  }
}
