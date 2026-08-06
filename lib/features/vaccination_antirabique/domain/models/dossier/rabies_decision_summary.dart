import 'dossier_enums.dart';
import 'rabies_clinical_alert.dart';
import 'vaccination.dart';

/// Décision de catégorie de risque : catégorie + raison clinique.
class RabiesCategoryDecision {
  final RabiesRiskCategory categorie;
  final String raison;

  const RabiesCategoryDecision({
    required this.categorie,
    required this.raison,
  });
}

/// Décision PPE (prophylaxie post-exposition).
class RabiesPpeDecision {
  final bool indiquee;
  final bool urgente;
  final String message;

  const RabiesPpeDecision({
    required this.indiquee,
    required this.urgente,
    required this.message,
  });
}

/// Décision ERIG : indication + faisabilité + avertissements.
class RabiesErigDecision {
  final bool indiquee;
  final bool encorePermise;
  final bool administree;
  final String message;
  final List<RabiesClinicalAlert> warnings;

  const RabiesErigDecision({
    required this.indiquee,
    required this.encorePermise,
    required this.administree,
    required this.message,
    this.warnings = const [],
  });

  /// ERIG bloquante : indiquée, encore permise, mais non administrée.
  bool get bloquante => indiquee && encorePermise && !administree;
}

/// Décision de protocole vaccinal : type + justification + schéma.
class RabiesProtocolDecision {
  final VaccinationProtocolType type;
  final String justification;
  final List<String> schemaJours;
  final String? remarques;

  const RabiesProtocolDecision({
    required this.type,
    required this.justification,
    required this.schemaJours,
    this.remarques,
  });

  String get schemaLabel => schemaJours.join(', ');
}

/// Statut global d'un dossier (agrégé par le moteur).
enum RabiesDossierStatus {
  prete,
  aCompleter,
  enRetard,
  terminee;

  String get label {
    switch (this) {
      case RabiesDossierStatus.prete:
        return 'Prête pour validation J0';
      case RabiesDossierStatus.aCompleter:
        return 'Données à compléter';
      case RabiesDossierStatus.enRetard:
        return 'Protocole en retard';
      case RabiesDossierStatus.terminee:
        return 'Protocole terminé';
    }
  }
}

/// Résumé de décision clinique produit par `RabiesDecisionEngine`.
///
/// Objectif : l'UI affiche ce résumé de façon cohérente (badges, cartes,
/// alertes, sticky) sans jamais refaire la logique métier.
class RabiesDecisionSummary {
  final RabiesCategoryDecision categorie;
  final RabiesPpeDecision ppe;
  final RabiesErigDecision erig;
  final RabiesProtocolDecision? protocole;
  final VaccineDose? prochaineDose;
  final bool retard;
  final int joursRetard;
  final List<RabiesClinicalAlert> alertes;
  final RabiesDossierStatus statut;

  const RabiesDecisionSummary({
    required this.categorie,
    required this.ppe,
    required this.erig,
    required this.protocole,
    required this.prochaineDose,
    required this.retard,
    required this.joursRetard,
    required this.alertes,
    required this.statut,
  });

  int get alertesCritiques =>
      alertes.where((a) => a.severity == RabiesAlertSeverity.critical).length;

  int get alertesWarnings =>
      alertes.where((a) => a.severity == RabiesAlertSeverity.warning).length;

  bool get ppeNonIndiquee =>
      !ppe.indiquee && categorie.categorie == RabiesRiskCategory.categorieI;

  List<RabiesClinicalAlert> alertesParSection(RabiesAlertSection section) =>
      alertes.where((a) => a.section == section).toList();
}
