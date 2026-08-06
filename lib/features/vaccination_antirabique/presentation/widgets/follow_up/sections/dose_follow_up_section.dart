import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/epidemiology_theme.dart';
import '../../../../domain/models/dossier/rabies_case_record.dart';
import '../../../../domain/models/dossier/rabies_clinical_alert.dart';
import '../../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../../domain/models/dossier/vaccination.dart';
import '../../../../domain/services/rabies_follow_up_service.dart';
import '../../../../domain/services/rabies_protocol_resolver.dart';
import '../dose_timeline_card.dart';
import '../follow_up_section_scaffold.dart';
import '../next_dose_banner.dart';
import '../protocol_progress_card.dart';

/// Section « Suivi des doses ».
///
/// Timeline complète du protocole, progression, prochaine dose, retards,
/// alertes de protocole incomplet et actions (valider / reporter / manquée).
class DoseFollowUpSection extends StatelessWidget {
  final RabiesCaseRecord record;
  final RabiesFollowUpSummary summary;
  final ValueChanged<int> onValiderDose;
  final ValueChanged<int> onReporterDose;
  final ValueChanged<int> onMarquerManquee;
  final ValueChanged<VaccineDose> onDoseDetails;

  const DoseFollowUpSection({
    super.key,
    required this.record,
    required this.summary,
    required this.onValiderDose,
    required this.onReporterDose,
    required this.onMarquerManquee,
    required this.onDoseDetails,
  });

  @override
  Widget build(BuildContext context) {
    final proto = record.vaccination.protocole;
    final next = summary.prochaineDose;

    return FollowUpSectionScaffold(
      icon: Icons.vaccines,
      title: 'Suivi des doses',
      subtitle:
          '${proto.type.label} · ${RabiesProtocolResolver.schema(proto.type)} · '
          '${summary.dosesRealisees}/${summary.totalDoses} doses réalisées',
      accent: EpidemiologyTheme.redPrimary,
      children: [
        NextDoseBanner(
          summary: summary,
          onValider: next == null ? null : () => onValiderDose(next.numero),
          onDetails: next == null ? null : () => onDoseDetails(next),
        ),
        const SizedBox(height: 14),
        ProtocolProgressCard(
          summary: summary,
          protocolType: proto.type,
          dateDebut: proto.dateDebut,
          dateFin: RabiesFollowUpService.dateFinEstimee(record),
          dureeJours: RabiesFollowUpService.dureeEstimee(record),
        ),
        const SizedBox(height: 14),
        _protocolAlerts(),
        const SizedBox(height: 14),
        _timeline(proto, next),
      ],
    );
  }

  Widget _protocolAlerts() {
    final alerts = summary.alertes
        .where((a) =>
            a.section == RabiesAlertSection.protocole ||
            a.section == RabiesAlertSection.vaccination)
        .toList();
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertes de protocole',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.warm400,
          ),
        ),
        const SizedBox(height: 8),
        for (final a in alerts) _alertCard(a),
      ],
    );
  }

  Widget _alertCard(RabiesClinicalAlert a) {
    final color = switch (a.severity) {
      RabiesAlertSeverity.critical => EpidemiologyTheme.danger,
      RabiesAlertSeverity.warning => EpidemiologyTheme.warning,
      RabiesAlertSeverity.info => EpidemiologyTheme.slate500,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(a.icon, size: 17, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.titre,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: EpidemiologyTheme.slate700,
                  ),
                ),
                if (a.recommendation != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '→ ${a.recommendation}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: EpidemiologyTheme.redPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeline(VaccinationProtocol proto, VaccineDose? next) {
    if (proto.doses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.warm50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: EpidemiologyTheme.warm100),
        ),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined, size: 22, color: EpidemiologyTheme.slate400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune dose planifiée. Complétez la fiche J0 pour générer le protocole.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.slate600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14, bottom: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Timeline du protocole',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.warm400,
              ),
            ),
          ),
        ),
        for (var i = 0; i < proto.doses.length; i++)
          DoseTimelineCard(
            dose: proto.doses[i],
            isLast: i == proto.doses.length - 1,
            isNext: identical(proto.doses[i], next),
            onValider: proto.doses[i].estRealisee
                ? null
                : () => onValiderDose(proto.doses[i].numero),
            onReporter: proto.doses[i].estRealisee
                ? null
                : () => onReporterDose(proto.doses[i].numero),
            onMarquerManquee: proto.doses[i].estRealisee
                ? null
                : () => onMarquerManquee(proto.doses[i].numero),
            onDetails: () => onDoseDetails(proto.doses[i]),
          ),
      ],
    );
  }
}
