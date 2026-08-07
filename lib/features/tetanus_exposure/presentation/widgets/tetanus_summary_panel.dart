import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import '../../domain/services/tetanus_evaluation_service.dart';
import 'tetanus_evaluation_controls.dart';

/// Panneau de résumé clinique (sidebar sur grand écran, bloc sur mobile).
class TetanusSummaryPanel extends StatelessWidget {
  const TetanusSummaryPanel({
    super.key,
    required this.resolution,
    required this.input,
    required this.dossierPret,
  });

  final TetanusDecisionResolution resolution;
  final TetanusEvaluationInput input;
  final bool dossierPret;

  (Color, IconData) get _riskViz {
    switch (resolution.risk) {
      case TetanusRiskLevel.faible:
        return (EpidemiologyTheme.success, Icons.verified_rounded);
      case TetanusRiskLevel.moyen:
        return (EpidemiologyTheme.warning, Icons.info_outline_rounded);
      case TetanusRiskLevel.eleve:
        return (EpidemiologyTheme.danger, Icons.warning_amber_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (riskColor, riskIcon) = _riskViz;
    final decisionColor = _decisionViz.$1;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.softGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowCard(riskColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_rounded,
                size: 18,
                color: EpidemiologyTheme.redPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'Synthèse clinique',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.warm900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row(
            'Niveau de risque',
            resolution.risk.label,
            color: riskColor,
            icon: riskIcon,
          ),
          _row(
            'Statut vaccinal',
            input.statutVaccinal.label,
            color: _vaccinColor(),
            icon: Icons.vaccines_outlined,
          ),
          _row(
            'Décision',
            resolution.decision.label,
            color: decisionColor,
            icon: Icons.event_note_outlined,
          ),
          const Divider(height: 24, color: EpidemiologyTheme.warm150),
          _prochaineAction(),
          const SizedBox(height: 14),
          _dossierStatus(),
          const SizedBox(height: 12),
          _panelAlerts(),
        ],
      ),
    );
  }

  (Color, IconData) get _decisionViz {
    switch (resolution.decision) {
      case TetanusDecision.simpleSurveillance:
        return (EpidemiologyTheme.success, Icons.check_circle_outline);
      case TetanusDecision.rappelIndique:
        return (EpidemiologyTheme.warning, Icons.vaccines_outlined);
      case TetanusDecision.vaccinationComplete:
        return (EpidemiologyTheme.info, Icons.medication_outlined);
      case TetanusDecision.vaccinationEtIg:
        return (EpidemiologyTheme.danger, Icons.warning_amber_outlined);
      case TetanusDecision.avisSpecialise:
        return (EpidemiologyTheme.orange, Icons.local_hospital_outlined);
    }
  }

  Color _vaccinColor() {
    switch (input.statutVaccinal) {
      case TetanusVaccinStatus.aJour:
        return EpidemiologyTheme.success;
      case TetanusVaccinStatus.incomplet:
        return EpidemiologyTheme.warning;
      case TetanusVaccinStatus.inconnu:
        return EpidemiologyTheme.warm400;
      case TetanusVaccinStatus.nonVaccine:
        return EpidemiologyTheme.danger;
    }
  }

  Widget _row(
    String label,
    String value, {
    required Color color,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon ?? Icons.info_outline, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: EpidemiologyTheme.warm400,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _prochaineAction() {
    final isUrgent = resolution.decision == TetanusDecision.vaccinationEtIg;
    final color = isUrgent
        ? EpidemiologyTheme.danger
        : resolution.decision == TetanusDecision.simpleSurveillance
        ? EpidemiologyTheme.success
        : EpidemiologyTheme.info;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROCHAINE ACTION',
            style: GoogleFonts.cairo(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isUrgent
                ? 'Administrer VAT + Ig sans délai.'
                : resolution.recommandation,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.warm800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dossierStatus() {
    return Row(
      children: [
        Icon(
          dossierPret
              ? Icons.check_circle_rounded
              : Icons.error_outline_rounded,
          size: 16,
          color: dossierPret
              ? EpidemiologyTheme.success
              : EpidemiologyTheme.warning,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            dossierPret
                ? 'Dossier prêt à valider'
                : 'Dossier incomplet à compléter',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: dossierPret
                  ? EpidemiologyTheme.success
                  : EpidemiologyTheme.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _panelAlerts() {
    final alerts = <(IconData, String, String, String)>[];
    if (!dossierPret) {
      alerts.add((
        Icons.fact_check_outlined,
        'Informations manquantes',
        'Le statut vaccinal ou le type de plaie doit être documenté.',
        'warning',
      ));
    }
    if (input.statutVaccinal == TetanusVaccinStatus.inconnu) {
      alerts.add((
        Icons.hide_source_outlined,
        'Statut vaccinal absent',
        'Préciser le statut pour affiner la conduite.',
        'info',
      ));
    }
    if (resolution.risk == TetanusRiskLevel.eleve) {
      alerts.add((
        Icons.warning_amber_rounded,
        'Plaie à haut risque',
        'Acte prophylactique à prioriser.',
        'danger',
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: alerts
          .map(
            (a) => TetanusAlertItem(
              icon: a.$1,
              title: a.$2,
              message: a.$3,
              color: _alertColor(a.$4),
            ),
          )
          .toList(),
    );
  }

  Color _alertColor(String kind) {
    switch (kind) {
      case 'danger':
        return EpidemiologyTheme.danger;
      case 'warning':
        return EpidemiologyTheme.warning;
      case 'info':
        return EpidemiologyTheme.info;
      default:
        return EpidemiologyTheme.warm400;
    }
  }
}
