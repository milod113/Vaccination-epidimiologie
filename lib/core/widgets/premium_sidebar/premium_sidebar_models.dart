import 'package:flutter/material.dart';

/// Ton visuel d'un badge de compteur / alerte sur un item de navigation.
enum SidebarBadgeTone { neutral, info, warning, danger, success }

/// Modèle d'un item de navigation de la sidebar, générique sur le type de
/// destination afin que chaque module (antirabique, tétanos, …) partage le
/// même composant de navigation.
class SidebarNavItemModel<T> {
  final String label;
  final IconData icon;
  final T destination;
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
class SidebarSection<T> {
  final String title;
  final List<SidebarNavItemModel<T>> items;

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

/// Identité visuelle du module affichée dans la sidebar (en-tête de marque
/// et pied de page). Permet à chaque module de garder son contexte métier
/// avec un rendu plateforme cohérent.
class SidebarIdentity {
  /// Titre affiché dans l'en-tête (une éventuelle ligne sautée est gérée).
  final String title;

  /// Sous-titre institutionnel (ex. « Service d'épidémiologie »).
  final String subtitle;

  /// Libellé du centre / service affiché en pied de page.
  final String centerLabel;

  /// Pictogramme du module.
  final IconData icon;

  const SidebarIdentity({
    required this.title,
    required this.subtitle,
    required this.centerLabel,
    required this.icon,
  });
}
