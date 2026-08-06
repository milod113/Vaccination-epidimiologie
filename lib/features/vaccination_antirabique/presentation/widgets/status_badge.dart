import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../data/models/protocole_vaccinal_model.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.suivi(StatutSuivi statut) {
    switch (statut) {
      case StatutSuivi.enCours:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.infoLight,
          textColor: EpidemiologyTheme.info,
          icon: Icons.sync,
        );
      case StatutSuivi.termine:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.successLight,
          textColor: EpidemiologyTheme.success,
          icon: Icons.check_circle,
        );
      case StatutSuivi.perduDeVue:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.dangerLight,
          textColor: EpidemiologyTheme.danger,
          icon: Icons.warning,
        );
      case StatutSuivi.transfere:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.warningLight,
          textColor: EpidemiologyTheme.warning,
          icon: Icons.swap_horiz,
        );
    }
  }

  factory StatusBadge.dose(DoseStatut statut) {
    switch (statut) {
      case DoseStatut.administree:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.successLight,
          textColor: EpidemiologyTheme.success,
          icon: Icons.check_circle_outline,
        );
      case DoseStatut.prevue:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.infoLight,
          textColor: EpidemiologyTheme.info,
          icon: Icons.schedule,
        );
      case DoseStatut.reportee:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.warningLight,
          textColor: EpidemiologyTheme.warning,
          icon: Icons.access_time,
        );
      case DoseStatut.nonEffectuee:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.dangerLight,
          textColor: EpidemiologyTheme.danger,
          icon: Icons.cancel,
        );
    }
  }

  /// Badge basé sur le statut détaillé calculé (temps réel)
  factory StatusBadge.detail(DoseStatutDetaille statut) {
    switch (statut) {
      case DoseStatutDetaille.realisee:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.successLight,
          textColor: EpidemiologyTheme.success,
          icon: Icons.check_circle,
        );
      case DoseStatutDetaille.prevueAujourdhui:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.warningLight,
          textColor: EpidemiologyTheme.warning,
          icon: Icons.notifications_active,
        );
      case DoseStatutDetaille.aVenir:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.warm100,
          textColor: EpidemiologyTheme.warm500,
          icon: Icons.schedule,
        );
      case DoseStatutDetaille.enRetard:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.dangerLight,
          textColor: EpidemiologyTheme.danger,
          icon: Icons.warning,
        );
      case DoseStatutDetaille.reportee:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.warningLight,
          textColor: EpidemiologyTheme.warning,
          icon: Icons.access_time,
        );
      case DoseStatutDetaille.nonEffectuee:
        return StatusBadge(
          label: statut.label,
          backgroundColor: EpidemiologyTheme.dangerLight,
          textColor: EpidemiologyTheme.danger,
          icon: Icons.cancel,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.12), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
