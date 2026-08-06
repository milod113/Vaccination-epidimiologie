import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import 'clinical_status_pill.dart';

/// Badge de statut d'une dose de vaccination.
///
/// Affiche un libellé court et une couleur sémantique selon l'état de la dose
/// (réalisée / prévue / en retard / manquée).
class DoseStatusBadge extends StatelessWidget {
  final DoseStatus status;
  final String? labelOverride;
  final bool compact;

  const DoseStatusBadge({
    super.key,
    required this.status,
    this.labelOverride,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            labelOverride ?? status.label,
            style: GoogleFonts.inter(
              fontSize: compact ? 10.5 : 11.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _icon => switch (status) {
        DoseStatus.realisee => Icons.check_circle_outline,
        DoseStatus.enRetard => Icons.schedule,
        DoseStatus.manquee => Icons.cancel_outlined,
        DoseStatus.prevue => Icons.event_outlined,
      };
}
