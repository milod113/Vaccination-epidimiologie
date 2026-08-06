import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';

/// Pastille de statut générique (contour doux ou remplie).
class StatusPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;

  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: filled ? 0 : 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}

/// Badge de catégorie rabique (I / II / III), avec code couleur sémantique.
class RiskBadge extends StatelessWidget {
  final RabiesRiskCategory category;
  final bool compact;

  const RiskBadge({super.key, required this.category, this.compact = false});

  static Color colorFor(RabiesRiskCategory c) => switch (c) {
    RabiesRiskCategory.categorieI => EpidemiologyTheme.success,
    RabiesRiskCategory.categorieII => EpidemiologyTheme.warning,
    RabiesRiskCategory.categorieIII => EpidemiologyTheme.danger,
  };

  @override
  Widget build(BuildContext context) {
    final color = colorFor(category);
    return StatusPill(
      label: category.label,
      icon: Icons.shield_outlined,
      color: color,
      filled: true,
    );
  }
}

/// Mini-fait clinique repris dans la synthèse (label + valeur colorée).
class KeyFactChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const KeyFactChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.14), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: EpidemiologyTheme.slate500),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: color, height: 1.1),
          ),
        ],
      ),
    );
  }
}