import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/services/rabies_traceability_service.dart';
import 'dossier_history_timeline.dart';
import 'registry_card.dart';
import 'traceability_summary_card.dart';

/// Section « Traçabilité réglementaire » complète d'un dossier.
///
/// Regroupe : la carte de synthèse, les volets administratifs (carte/registre)
/// et la timeline de l'historique des modifications.
///
/// Utilisée dans le détail du dossier et l'écran de suivi. Un appel
/// [onOpenHistory] peut être fourni pour ouvrir l'écran dédié.
class TraceabilitySection extends StatelessWidget {
  final RabiesCaseRecord record;
  final VoidCallback? onOpenHistory;

  const TraceabilitySection({
    super.key,
    required this.record,
    this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    final summary = RabiesTraceabilityService.resume(record);
    final entries = RabiesTraceabilityService.lister(record);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onOpenHistory != null) _header(summary.nombreEvenements),
        TraceabilitySummaryCard(summary: summary),
        const SizedBox(height: 14),
        RegistryCard(summary: summary),
        const SizedBox(height: 14),
        DossierHistoryTimeline(entries: entries),
      ],
    );
  }

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: EpidemiologyTheme.primaryGradientWarm,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Traçabilité réglementaire',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
                Text(
                  '$count événements enregistrés',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: EpidemiologyTheme.slate500,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onOpenHistory,
            icon: const Icon(Icons.history, size: 16),
            label: const Text('Historique complet'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EpidemiologyTheme.indigo,
              side: BorderSide(color: EpidemiologyTheme.indigo.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
