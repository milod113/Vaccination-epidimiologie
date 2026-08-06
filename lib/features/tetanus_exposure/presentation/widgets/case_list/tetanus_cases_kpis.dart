import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';

/// Indicateurs clés (KPI) de la liste des cas tétaniques.
///
/// Synthèse opérationnelle rapide : total, urgents, en cours, vaccin requis,
/// immunoglobulines et suivi clos.
class TetanusCasesKpis extends StatelessWidget {
  final List<TetanusPatientModel> patients;

  const TetanusCasesKpis({super.key, required this.patients});

  @override
  Widget build(BuildContext context) {
    var enCours = 0;
    var urgents = 0;
    var vaccinRequis = 0;
    var ig = 0;
    var clos = 0;

    for (final p in patients) {
      if (p.statutDossier == TetanusDossierStatut.enCours) enCours++;
      if (p.estUrgent) urgents++;
      if (p.decision == TetanusDecision.vaccinationComplete ||
          p.decision == TetanusDecision.vaccinationEtIg ||
          p.decision == TetanusDecision.rappelIndique) {
        vaccinRequis++;
      }
      if (p.immunoglobulines || p.necessiteIg) ig++;
      if (p.statutDossier == TetanusDossierStatut.suiviClos) clos++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = 128.0;
        final columns = (constraints.maxWidth / itemWidth).floor().clamp(2, 6);
        final gap = 12.0;
        final tileWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;

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
            color: enCours > 0 ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Urgents',
            value: '$urgents',
            icon: Icons.warning_amber_rounded,
            color: urgents > 0 ? EpidemiologyTheme.danger : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Vaccin requis',
            value: '$vaccinRequis',
            icon: Icons.vaccines_outlined,
            color: vaccinRequis > 0 ? EpidemiologyTheme.warning : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Ig requises',
            value: '$ig',
            icon: Icons.bloodtype_outlined,
            color: ig > 0 ? EpidemiologyTheme.indigo : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Suivi clos',
            value: '$clos',
            icon: Icons.check_circle_outline,
            color: clos > 0 ? EpidemiologyTheme.success : EpidemiologyTheme.slate400,
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