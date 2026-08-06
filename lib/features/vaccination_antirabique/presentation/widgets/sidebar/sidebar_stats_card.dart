import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import 'sidebar_models.dart';

/// Carte de résumé contextuel : mini KPIs du centre présentés en 2×2.
class SidebarStatsCard extends StatelessWidget {
  final List<SidebarStatsEntry> stats;

  const SidebarStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3F8FC), Color(0xFFEAF3FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.redLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 14, color: EpidemiologyTheme.redPrimary),
              const SizedBox(width: 6),
              Text(
                'RÉSUMÉ DU CENTRE',
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.redPrimary,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: stats.map((s) => _StatCell(entry: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final SidebarStatsEntry entry;

  const _StatCell({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: entry.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(entry.icon, size: 16, color: entry.color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.value,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.warm900,
                  height: 1.0,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.warm500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
