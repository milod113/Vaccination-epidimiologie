import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/epidemiology_theme.dart';
import '../../../../domain/models/dossier/rabies_case_record.dart';
import '../../../../domain/models/dossier/rabies_clinical_alert.dart';
import '../../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../../domain/services/rabies_traceability_service.dart';
import '../follow_up_section_scaffold.dart';
import '../../traceability/dossier_history_timeline.dart';
import '../../traceability/registry_card.dart';
import '../../traceability/traceability_summary_card.dart';

/// Section « Traçabilité » de l'écran de suivi.
///
/// Synthèse réglementaire : résumé de traçabilité, volets administratifs
/// (carte de vaccination / registre) et historique chronologique des actions
/// avec validateur, plus les alertes de cohérence éventuelles.
class TraceabilityFollowUpSection extends StatelessWidget {
  final RabiesCaseRecord record;
  final RabiesFollowUpSummary summary;

  const TraceabilityFollowUpSection({
    super.key,
    required this.record,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final trSummary = RabiesTraceabilityService.resume(record);
    final entries = RabiesTraceabilityService.lister(record);
    final coherenceAlerts = summary.alertes
        .where((a) => a.category == RabiesAlertCategory.coherence)
        .toList();

    return FollowUpSectionScaffold(
      icon: Icons.receipt_long_outlined,
      title: 'Traçabilité',
      subtitle: 'Carte de vaccination, registre et historique du dossier',
      accent: EpidemiologyTheme.indigo,
      children: [
        TraceabilitySummaryCard(summary: trSummary),
        const SizedBox(height: 14),
        RegistryCard(summary: trSummary),
        const SizedBox(height: 14),
        DossierHistoryTimeline(entries: entries),
        if (coherenceAlerts.isNotEmpty) ...[
          const SizedBox(height: 14),
          _alerts(coherenceAlerts),
        ],
      ],
    );
  }

  Widget _alerts(List<RabiesClinicalAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Points d\'attention',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.warm400,
          ),
        ),
        const SizedBox(height: 8),
        for (final a in alerts)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warningLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EpidemiologyTheme.warning.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 17, color: EpidemiologyTheme.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${a.titre} — ${a.message}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: EpidemiologyTheme.slate700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
