import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import 'traceability_ui.dart';

/// Chip de statut de validation d'une étape.
class ValidationStatusChip extends StatelessWidget {
  final ValidationStatus statut;

  const ValidationStatusChip({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final color = TraceabilityUi.validationColor(statut);
    final icon = switch (statut) {
      ValidationStatus.validee => Icons.check_circle_outline,
      ValidationStatus.enCours => Icons.schedule,
      ValidationStatus.rejetee => Icons.cancel_outlined,
      ValidationStatus.annulee => Icons.remove_circle_outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            statut.label,
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