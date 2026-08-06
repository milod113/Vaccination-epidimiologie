import 'package:flutter/material.dart';

/// Destinations de navigation du module « Vaccination antirabique ».
enum AntirabiqueDestination {
  dashboard,
  patients,
  dossiers,
  evaluation,
  carnet,
  protocoles,
  suivi,
  tracabilite,
  stocks,
  scanner,
  certificats,
  parametres,
}

/// Ton visuel d'un badge de compteur / alerte sur un item de navigation.
enum SidebarBadgeTone { neutral, info, warning, danger, success }

/// Modèle d'un item de navigation de la sidebar.
class SidebarNavItemModel {
  final String label;
  final IconData icon;
  final AntirabiqueDestination destination;
  final int? badge;
  final SidebarBadgeTone badgeTone;
  final bool showDot;
  final Color? dotColor;

  const SidebarNavItemModel({
    required this.label,
    required this.icon,
    required this.destination,
    this.badge,
    this.badgeTone = SidebarBadgeTone.neutral,
    this.showDot = false,
    this.dotColor,
  });
}

/// Section de navigation (regroupe des items sous un titre).
class SidebarSection {
  final String title;
  final List<SidebarNavItemModel> items;

  const SidebarSection(this.title, this.items);
}

/// Action rapide proposée dans la carte dédiée.
class SidebarQuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SidebarQuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Entrée du mini-résumé contextuel (KPIs).
class SidebarStatsEntry {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const SidebarStatsEntry({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}