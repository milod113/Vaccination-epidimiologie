import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/travel_models.dart';

class TravelStatusBadge extends StatelessWidget {
  final TravelVaccinationStatus status;
  final double fontSize;

  const TravelStatusBadge({super.key, required this.status, this.fontSize = 11});

  Color get _color {
    switch (status) {
      case TravelVaccinationStatus.administre:
        return EpidemiologyTheme.success;
      case TravelVaccinationStatus.planifie:
        return EpidemiologyTheme.info;
      case TravelVaccinationStatus.enRetard:
        return EpidemiologyTheme.danger;
      case TravelVaccinationStatus.nonRequis:
        return EpidemiologyTheme.warm300;
    }
  }

  IconData? get _icon {
    switch (status) {
      case TravelVaccinationStatus.administre:
        return Icons.check_circle;
      case TravelVaccinationStatus.planifie:
        return Icons.schedule;
      case TravelVaccinationStatus.enRetard:
        return Icons.warning_amber_rounded;
      case TravelVaccinationStatus.nonRequis:
        return Icons.remove_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: fontSize - 1, color: _color),
          const SizedBox(width: 3),
          Text(status.label, style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w600, color: _color)),
        ],
      ),
    );
  }
}
