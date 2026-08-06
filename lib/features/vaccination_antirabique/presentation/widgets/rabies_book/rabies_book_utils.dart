import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/protocole_vaccinal_model.dart';

/// Formatte une date ISO `yyyy-MM-dd` en `jj/mm/aaaa`.
String formatBookDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

String? formatBookDateOrNull(String? iso) =>
    iso == null ? null : formatBookDate(iso);

/// Couleur sémantique d'un statut de dose (carnet).
Color bookDoseColor(DoseStatutDetaille statut) {
  switch (statut) {
    case DoseStatutDetaille.realisee:
      return EpidemiologyTheme.success;
    case DoseStatutDetaille.prevueAujourdhui:
      return EpidemiologyTheme.warning;
    case DoseStatutDetaille.aVenir:
      return EpidemiologyTheme.info;
    case DoseStatutDetaille.enRetard:
      return EpidemiologyTheme.danger;
    case DoseStatutDetaille.reportee:
      return EpidemiologyTheme.warning;
    case DoseStatutDetaille.nonEffectuee:
      return EpidemiologyTheme.danger;
  }
}

IconData bookDoseIcon(DoseStatutDetaille statut) {
  switch (statut) {
    case DoseStatutDetaille.realisee:
      return Icons.check_circle_rounded;
    case DoseStatutDetaille.prevueAujourdhui:
      return Icons.notifications_active_rounded;
    case DoseStatutDetaille.aVenir:
      return Icons.schedule_rounded;
    case DoseStatutDetaille.enRetard:
      return Icons.warning_amber_rounded;
    case DoseStatutDetaille.reportee:
      return Icons.access_time_rounded;
    case DoseStatutDetaille.nonEffectuee:
      return Icons.cancel_rounded;
  }
}

/// Partagé entre les cartes du carnet : rendu d'une carte premium.
Widget bookCard({
  required Widget child,
  EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  Color? borderColor,
}) {
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: EpidemiologyTheme.white,
      borderRadius: BorderRadius.circular(22),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor.withValues(alpha: 0.25), width: 1),
      boxShadow: [
        ...EpidemiologyTheme.shadowMd,
        BoxShadow(
          color: EpidemiologyTheme.blackWith(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}