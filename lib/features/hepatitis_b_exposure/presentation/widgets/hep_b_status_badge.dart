import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/hep_b_models.dart';

class HepBStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final double fontSize;

  const HepBStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 11,
  });

  factory HepBStatusBadge.riskLevel(HepBRiskLevel level) {
    return HepBStatusBadge(
      label: level.label,
      color: level.color,
      icon: level == HepBRiskLevel.urgent
          ? Icons.warning_amber_rounded
          : level == HepBRiskLevel.eleve
              ? Icons.trending_up
              : Icons.info_outline,
    );
  }

  factory HepBStatusBadge.vaccination(HepBVaccinationStatus status) {
    return HepBStatusBadge(
      label: status.label,
      color: status.color,
    );
  }

  factory HepBStatusBadge.serology(HepBSerologyStatus status) {
    return HepBStatusBadge(
      label: status.label,
      color: status.color,
    );
  }

  factory HepBStatusBadge.dossier(HepBDossierStatut statut) {
    return HepBStatusBadge(
      label: statut.label,
      color: statut.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize - 1, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
