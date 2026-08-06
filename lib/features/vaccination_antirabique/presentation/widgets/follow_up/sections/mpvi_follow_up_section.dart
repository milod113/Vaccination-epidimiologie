import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/epidemiology_theme.dart';
import '../../../../domain/models/dossier/rabies_case_record.dart';
import '../../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../follow_up_section_scaffold.dart';
import '../mpvi_alert_card.dart';

/// Section « Réactions post-vaccinales » (MPVI).
///
/// Affiche l'état MPVI du dossier ainsi que les éventuelles alertes de
/// cohérence. Préparée pour une extension future (historique de réactions).
class MpviFollowUpSection extends StatelessWidget {
  final RabiesCaseRecord record;
  final RabiesFollowUpSummary summary;

  const MpviFollowUpSection({
    super.key,
    required this.record,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final mpvi = record.mpvi;
    return FollowUpSectionScaffold(
      icon: Icons.health_and_safety_outlined,
      title: 'Réactions post-vaccinales',
      subtitle: mpvi.present
          ? 'Manifestation post-vaccinale indésirable enregistrée'
          : 'Suivi des effets indésirables de la vaccination',
      accent: mpvi.present
          ? (mpvi.gravite.label == 'Sévère' ? EpidemiologyTheme.danger : EpidemiologyTheme.warning)
          : EpidemiologyTheme.success,
      children: [
        MpviAlertCard(mpvi: mpvi),
        if (mpvi.present) ...[
          const SizedBox(height: 14),
          _noteCard(),
        ],
      ],
    );
  }

  Widget _noteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 18, color: EpidemiologyTheme.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conduite à tenir',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Noter la réaction, évaluer le lien avec la vaccination, '
                  'adapter le schéma si nécessaire et déclarer en '
                  'pharmacovigilance conformément aux instructions nationales.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: EpidemiologyTheme.slate600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
