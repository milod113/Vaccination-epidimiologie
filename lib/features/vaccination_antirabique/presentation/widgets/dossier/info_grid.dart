import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Entrée d'une grille d'informations (libellé / valeur).
class InfoTile {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? valueColor;

  const InfoTile({required this.label, this.value, this.icon, this.valueColor});
}

/// Grille d'informations réactive : deux colonnes sur desktop, une sur mobile.
class InfoGrid extends StatelessWidget {
  final List<InfoTile> items;
  final EdgeInsetsGeometry padding;

  const InfoGrid({super.key, required this.items, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 540;
        final rows = <List<InfoTile>>[];
        for (var i = 0; i < items.length; i += 2) {
          rows.add([items[i], if (i + 1 < items.length) items[i + 1]]);
        }
        return Padding(
          padding: padding,
          child: Column(
            children: [
              for (var r = 0; r < rows.length; r++) ...[
                if (r > 0) const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _tile(rows[r][0], separator: r < rows.length - 1)),
                    if (rows[r].length > 1) ...[
                      SizedBox(width: twoColumns ? 24 : 16),
                      Expanded(
                        child: _tile(
                          rows[r][1],
                          separator: r < rows.length - 1,
                        ),
                      ),
                    ],
                    if (rows[r].length == 1 && twoColumns) const SizedBox(width: 24),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _tile(InfoTile t, {required bool separator}) {
    final v = t.value == null || t.value!.isEmpty ? '—' : t.value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (separator && t.icon == null) ...[
          Container(height: 1, color: EpidemiologyTheme.warm100),
          const SizedBox(height: 12),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.icon != null) ...[
              Icon(t.icon, size: 14, color: EpidemiologyTheme.warm400),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: EpidemiologyTheme.slate400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    v,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: t.valueColor ?? EpidemiologyTheme.slate800,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}