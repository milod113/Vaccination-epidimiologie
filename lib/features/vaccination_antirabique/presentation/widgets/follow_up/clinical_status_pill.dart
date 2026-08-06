import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';

/// Pastille de statut clinique réutilisable (vert / orange / rouge / neutre).
///
/// Utilisée dans l'ensemble des écrans de suivi pour signaler un état de
/// manière immédiatement lisible (dose, animal, MPVI, traçabilité…).
class ClinicalStatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool subtle;
  final double fontSize;

  const ClinicalStatusPill({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.subtle = false,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: subtle ? 0.08 : 0.13),
        borderRadius: BorderRadius.circular(10),
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
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Couleur sémantique pour un statut de dose.
extension DoseStatusColorX on DoseStatus {
  Color get color => switch (this) {
        DoseStatus.realisee => EpidemiologyTheme.success,
        DoseStatus.enRetard => EpidemiologyTheme.warning,
        DoseStatus.manquee => EpidemiologyTheme.danger,
        DoseStatus.prevue => EpidemiologyTheme.slate400,
      };
}
