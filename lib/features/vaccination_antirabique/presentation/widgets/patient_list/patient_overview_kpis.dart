import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/patient_antirabique_model.dart';
import 'patient_list_models.dart';

/// Indicateurs clés (KPI) de la liste des patients : synthèse opérationnelle
/// rapide (total, en cours, en retard, doses du jour, catégorie III, ERIG).
class PatientOverviewKpis extends StatelessWidget {
  final List<PatientAntirabiqueModel> patients;

  const PatientOverviewKpis({super.key, required this.patients});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);

    var enCours = 0;
    var enRetard = 0;
    var dosesJour = 0;
    var catIII = 0;
    var rig = 0;

    for (final p in patients) {
      if (p.statut == StatutSuivi.enCours) enCours++;
      if (patientEnRetard(p, now)) enRetard++;
      if (patientDueAujourdhui(p, now)) dosesJour++;
      if (p.categorieExposition == CategorieExposition.categorieIII) catIII++;
      if (p.rigAdministree) rig++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Chaque carte KPI occupe au moins 120px ; wrap responsive.
        final itemWidth = 128.0;
        final columns = (constraints.maxWidth / itemWidth).floor().clamp(2, 6);
        final gap = 12.0;
        final totalWidth = (constraints.maxWidth - gap * (columns - 1));
        final tileWidth = totalWidth / columns;

        final kpis = <Widget>[
          _KpiTile(
            label: 'Total',
            value: '${patients.length}',
            icon: Icons.groups,
            color: EpidemiologyTheme.info,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'En cours',
            value: '$enCours',
            icon: Icons.sync,
            color: EpidemiologyTheme.teal,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'En retard',
            value: '$enRetard',
            icon: Icons.schedule,
            color: enRetard > 0 ? EpidemiologyTheme.danger : EpidemiologyTheme.success,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Doses du jour',
            value: '$dosesJour',
            icon: Icons.notifications_active_outlined,
            color: dosesJour > 0 ? EpidemiologyTheme.orange : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Cat. III',
            value: '$catIII',
            icon: Icons.priority_high,
            color: catIII > 0 ? EpidemiologyTheme.danger : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'ERIG',
            value: '$rig',
            icon: Icons.science_outlined,
            color: rig > 0 ? EpidemiologyTheme.indigo : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
        ];

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Wrap(
            spacing: gap,
            runSpacing: gap,
            children: kpis,
          ),
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: EpidemiologyTheme.slate900,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.warm500,
            ),
          ),
        ],
      ),
    );
  }
}