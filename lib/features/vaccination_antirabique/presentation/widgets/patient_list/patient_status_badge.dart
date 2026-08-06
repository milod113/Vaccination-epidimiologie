import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/patient_antirabique_model.dart';
import 'patient_list_models.dart';

/// Badge de statut « premium » pour un patient antirabique.
///
/// Reprend les codes couleurs sémantiques : vert = correct / terminé,
/// orange = vigilance, rouge = critique / retard, bleu = contexte / en cours.
class PatientStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const PatientStatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  /// Badge dérivé d'un [StatutSuivi] du modèle (en cours / terminé / perdu /
  /// transféré).
  factory PatientStatusBadge.suivi(StatutSuivi statut) {
    switch (statut) {
      case StatutSuivi.enCours:
        return PatientStatusBadge(
          label: statut.label,
          color: EpidemiologyTheme.info,
          icon: Icons.sync,
        );
      case StatutSuivi.termine:
        return PatientStatusBadge(
          label: statut.label,
          color: EpidemiologyTheme.success,
          icon: Icons.check_circle,
        );
      case StatutSuivi.perduDeVue:
        return PatientStatusBadge(
          label: statut.label,
          color: EpidemiologyTheme.danger,
          icon: Icons.person_off_outlined,
        );
      case StatutSuivi.transfere:
        return PatientStatusBadge(
          label: statut.label,
          color: EpidemiologyTheme.warning,
          icon: Icons.swap_horiz,
        );
    }
  }

  /// Badge « Rendez-vous dépassé » (retard observé par rapport à la date du
  /// prochain rendez-vous).
  factory PatientStatusBadge.enRetard(int jours) {
    return PatientStatusBadge(
      label: jours > 0 ? 'En retard · $jours j' : 'Rendez-vous dépassé',
      color: EpidemiologyTheme.danger,
      icon: Icons.hourglass_bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
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

/// Petite pastille de risque patient (catégorie d'exposition).
///
/// Catégorie III → rouge (risque élevé), II → orange (vigilance),
/// I → vert (faible risque), non évalué → gris (à évaluer).
class PatientRiskPill extends StatelessWidget {
  final CategorieExposition? categorie;

  const PatientRiskPill({super.key, this.categorie});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (categorie) {
      CategorieExposition.categorieI => (
          'Cat. I',
          EpidemiologyTheme.success,
          Icons.looks_one_outlined,
        ),
      CategorieExposition.categorieII => (
          'Cat. II',
          EpidemiologyTheme.warning,
          Icons.looks_two_outlined,
        ),
      CategorieExposition.categorieIII => (
          'Cat. III',
          EpidemiologyTheme.danger,
          Icons.looks_3_outlined,
        ),
      null => (
          'À évaluer',
          EpidemiologyTheme.slate500,
          Icons.rule_outlined,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Libellé relatif du rendez-vous avec couleur associée (utilisé dans la
/// carte patient).
class PatientRdvChip extends StatelessWidget {
  final PatientAntirabiqueModel patient;
  final DateTime today;

  const PatientRdvChip({
    super.key,
    required this.patient,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final overdue = patientEnRetard(patient, today);
    final dueToday = patientDueAujourdhui(patient, today);
    final ret = joursDeRetard(patient, today);
    final color = overdue
        ? EpidemiologyTheme.danger
        : dueToday
            ? EpidemiologyTheme.warning
            : EpidemiologyTheme.slate500;
    final icon = overdue
        ? Icons.schedule
        : dueToday
            ? Icons.notifications_active
            : Icons.event_available_outlined;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          '${libelleRendezVous(patient, today)}'
          '${patient.prochainRendezVous != null ? ' · ${formatDateIso(patient.prochainRendezVous)}' : ''}'
          '${ret > 0 ? ' · j-$ret' : ''}',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}