import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';

class TetanusStatusBadge extends StatelessWidget {
  final TetanusDossierStatut statut;
  final double fontSize;
  final EdgeInsets padding;
  final bool showIcon;

  const TetanusStatusBadge({
    super.key,
    required this.statut,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withValues(alpha: 0.10),
            _color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _color.withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            statut.label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (statut) {
      case TetanusDossierStatut.enCours:
        return EpidemiologyTheme.info;
      case TetanusDossierStatut.acteEffectue:
        return EpidemiologyTheme.teal;
      case TetanusDossierStatut.suiviClos:
        return EpidemiologyTheme.warm400;
      case TetanusDossierStatut.perduDeVue:
        return EpidemiologyTheme.danger;
    }
  }
}

class TetanusVaccinStatusBadge extends StatelessWidget {
  final TetanusVaccinStatus status;
  final double fontSize;
  final bool compact;

  const TetanusVaccinStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _color.withValues(alpha: 0.10),
            _color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: 0.3),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (status) {
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
}

class TetanusDecisionBadge extends StatelessWidget {
  final TetanusDecision decision;
  final double fontSize;

  const TetanusDecisionBadge({
    super.key,
    required this.decision,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _color),
          const SizedBox(width: 5),
          Text(
            decision.label,
            style: GoogleFonts.inter(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }

  Color get _color {
    switch (decision) {
      case TetanusDecision.simpleSurveillance:
        return EpidemiologyTheme.success;
      case TetanusDecision.rappelIndique:
        return EpidemiologyTheme.warning;
      case TetanusDecision.vaccinationComplete:
        return EpidemiologyTheme.info;
      case TetanusDecision.vaccinationEtIg:
        return EpidemiologyTheme.danger;
      case TetanusDecision.avisSpecialise:
        return EpidemiologyTheme.orange;
    }
  }

  IconData get _icon {
    switch (decision) {
      case TetanusDecision.simpleSurveillance:
        return Icons.check_circle_outline;
      case TetanusDecision.rappelIndique:
        return Icons.vaccines_outlined;
      case TetanusDecision.vaccinationComplete:
        return Icons.medication_outlined;
      case TetanusDecision.vaccinationEtIg:
        return Icons.warning_amber_outlined;
      case TetanusDecision.avisSpecialise:
        return Icons.local_hospital_outlined;
    }
  }
}
