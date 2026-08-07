import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import '../../domain/services/tetanus_evaluation_service.dart';
import 'tetanus_evaluation_controls.dart';

/// Carte de décision clinique : synthèse forte de la conduite à tenir.
class TetanusDecisionCard extends StatelessWidget {
  const TetanusDecisionCard({
    super.key,
    required this.resolution,
    required this.input,
  });

  final TetanusDecisionResolution resolution;
  final TetanusEvaluationInput input;

  (Color, IconData, String) get _style {
    switch (resolution.decision) {
      case TetanusDecision.simpleSurveillance:
        return (
          EpidemiologyTheme.success,
          Icons.check_circle_rounded,
          'Aucun acte nécessaire',
        );
      case TetanusDecision.rappelIndique:
        return (
          EpidemiologyTheme.warning,
          Icons.vaccines_rounded,
          'Rappel VAT à planifier',
        );
      case TetanusDecision.vaccinationComplete:
        return (
          EpidemiologyTheme.info,
          Icons.medication_rounded,
          'Schéma VAT à initier',
        );
      case TetanusDecision.vaccinationEtIg:
        return (
          EpidemiologyTheme.danger,
          Icons.warning_amber_rounded,
          'Acte en urgence',
        );
      case TetanusDecision.avisSpecialise:
        return (
          EpidemiologyTheme.orange,
          Icons.local_hospital_rounded,
          'Avis spécialisé requis',
        );
    }
  }

  bool get _igRequises =>
      resolution.decision == TetanusDecision.vaccinationEtIg;
  bool get _vaccinNecessaire =>
      resolution.decision == TetanusDecision.vaccinationComplete ||
      resolution.decision == TetanusDecision.vaccinationEtIg ||
      resolution.decision == TetanusDecision.rappelIndique;
  bool get _rappelsIndique =>
      resolution.decision == TetanusDecision.rappelIndique;

  @override
  Widget build(BuildContext context) {
    final (color, icon, sub) = _style;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          ...EpidemiologyTheme.shadowSm,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.78)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Décision clinique',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resolution.decision.label,
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              TetanusBadge(
                label: sub,
                color: color,
                icon: icon,
                fontSize: 10.5,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: color.withValues(alpha: 0.12)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    resolution.recommandation,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.warm700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(_vaccinNecessaire, Icons.vaccines_outlined, 'Vaccination'),
              _pill(_igRequises, Icons.bloodtype_outlined, 'Immunoglobulines'),
              _pill(_rappelsIndique, Icons.event_repeat_outlined, 'Rappel'),
              if (input.traitementDejaRecu)
                _pill(true, Icons.done_all_rounded, 'Traitement déjà reçu'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(bool active, IconData icon, String label) {
    final activeColor = _style.$1;
    final color = active ? activeColor : EpidemiologyTheme.warm300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? activeColor.withValues(alpha: 0.10)
            : EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? activeColor.withValues(alpha: 0.25)
              : EpidemiologyTheme.warm150,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
