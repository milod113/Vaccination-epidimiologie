import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import 'dossier_list_models.dart';

/// KPI de synthèse de la liste des dossiers : total, protocoles en cours,
/// retards et urgences (catégorie III). Grille responsive de 4 cartes.
class DossierListKpis extends StatelessWidget {
  final List<RabiesCaseRecord> dossiers;

  const DossierListKpis({super.key, required this.dossiers});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);

    var enCours = 0;
    var enRetard = 0;
    var urgents = 0;

    for (final d in dossiers) {
      final s = statutProtocole(d, now);
      if (s == DossierProtocoleStatut.enCours) enCours++;
      if (dossierEnRetard(d, now)) enRetard++;
      if (d.estUrgent) urgents++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = 136.0;
        final columns = (constraints.maxWidth / itemWidth).floor().clamp(2, 4);
        final gap = 12.0;
        final totalWidth = constraints.maxWidth - gap * (columns - 1);
        final tileWidth = totalWidth / columns;

        final kpis = <Widget>[
          _KpiTile(
            label: 'Total dossiers',
            value: '${dossiers.length}',
            icon: Icons.folder_outlined,
            color: EpidemiologyTheme.info,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Suivis en cours',
            value: '$enCours',
            icon: Icons.sync,
            color: EpidemiologyTheme.teal,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'En retard',
            value: '$enRetard',
            icon: Icons.schedule,
            color: enRetard > 0
                ? EpidemiologyTheme.warning
                : EpidemiologyTheme.success,
            width: tileWidth,
          ),
          _KpiTile(
            label: 'Urgents (cat. III)',
            value: '$urgents',
            icon: Icons.priority_high,
            color: urgents > 0
                ? EpidemiologyTheme.danger
                : EpidemiologyTheme.slate400,
            width: tileWidth,
          ),
        ];

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Wrap(spacing: gap, runSpacing: gap, children: kpis),
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
