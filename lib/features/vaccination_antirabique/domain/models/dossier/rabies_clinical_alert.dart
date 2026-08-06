import 'package:flutter/material.dart';

/// Niveau de sévérité d'une alerte clinique.
enum RabiesAlertSeverity {
  info,
  warning,
  critical;

  String get label {
    switch (this) {
      case RabiesAlertSeverity.info:
        return 'Info';
      case RabiesAlertSeverity.warning:
        return 'Avertissement';
      case RabiesAlertSeverity.critical:
        return 'Critique';
    }
  }
}

/// Catégorie fonctionnelle d'une alerte.
enum RabiesAlertCategory {
  donneesManquantes,
  decision,
  erig,
  protocole,
  retard,
  suivi,
  coherence;

  String get label {
    switch (this) {
      case RabiesAlertCategory.donneesManquantes:
        return 'Données manquantes';
      case RabiesAlertCategory.decision:
        return 'Décision clinique';
      case RabiesAlertCategory.erig:
        return 'ERIG';
      case RabiesAlertCategory.protocole:
        return 'Protocole vaccinal';
      case RabiesAlertCategory.retard:
        return 'Retard';
      case RabiesAlertCategory.suivi:
        return 'Suivi';
      case RabiesAlertCategory.coherence:
        return 'Cohérence';
    }
  }
}

/// Section du dossier concernée par une alerte.
///
/// L'UI peut s'en servir pour afficher l'alerte au bon endroit.
enum RabiesAlertSection {
  identite,
  adresse,
  admission,
  exposition,
  classification,
  animal,
  soinsLocaux,
  erig,
  chirurgie,
  vaccination,
  protocole,
  mpvi,
  antibiotiques,
  tetanos,
  autresTraitements,
  tracabilite,
  evolution;

  String get label {
    switch (this) {
      case RabiesAlertSection.identite:
        return 'Identité patient';
      case RabiesAlertSection.adresse:
        return 'Adresse';
      case RabiesAlertSection.admission:
        return 'Admission';
      case RabiesAlertSection.exposition:
        return 'Exposition';
      case RabiesAlertSection.classification:
        return 'Classification';
      case RabiesAlertSection.animal:
        return 'Animal';
      case RabiesAlertSection.soinsLocaux:
        return 'Soins locaux';
      case RabiesAlertSection.erig:
        return 'ERIG';
      case RabiesAlertSection.chirurgie:
        return 'Chirurgie';
      case RabiesAlertSection.vaccination:
        return 'Vaccination';
      case RabiesAlertSection.protocole:
        return 'Protocole';
      case RabiesAlertSection.mpvi:
        return 'MPVI';
      case RabiesAlertSection.antibiotiques:
        return 'Antibiotiques';
      case RabiesAlertSection.tetanos:
        return 'VAT';
      case RabiesAlertSection.autresTraitements:
        return 'Autres traitements';
      case RabiesAlertSection.tracabilite:
        return 'Traçabilité';
      case RabiesAlertSection.evolution:
        return 'Évolution';
    }
  }
}

/// Alerte clinique structurée produite par le moteur de décision.
class RabiesClinicalAlert {
  final String id;
  final String titre;
  final String message;
  final RabiesAlertSeverity severity;
  final RabiesAlertCategory category;
  final RabiesAlertSection section;
  final bool blocking;
  final String? recommendation;

  const RabiesClinicalAlert({
    required this.id,
    required this.titre,
    required this.message,
    required this.severity,
    required this.category,
    required this.section,
    this.blocking = false,
    this.recommendation,
  });

  RabiesClinicalAlert copyWith({
    String? id,
    String? titre,
    String? message,
    RabiesAlertSeverity? severity,
    RabiesAlertCategory? category,
    RabiesAlertSection? section,
    bool? blocking,
    String? recommendation,
  }) {
    return RabiesClinicalAlert(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      message: message ?? this.message,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      section: section ?? this.section,
      blocking: blocking ?? this.blocking,
      recommendation: recommendation ?? this.recommendation,
    );
  }

  /// Icône Material recommandée selon la sévérité.
  IconData get icon {
    switch (severity) {
      case RabiesAlertSeverity.info:
        return Icons.info_outline;
      case RabiesAlertSeverity.warning:
        return Icons.warning_amber_rounded;
      case RabiesAlertSeverity.critical:
        return Icons.error_outline;
    }
  }
}
