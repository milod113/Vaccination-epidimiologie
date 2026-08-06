import 'dossier_enums.dart';
import 'rabies_clinical_alert.dart';
import 'rabies_decision_summary.dart';
import 'vaccination.dart';

/// Statut global du protocole vaccinal dans le parcours de suivi.
enum RabiesProtocolStatus {
  sansProtocole,
  enCours,
  enRetard,
  termine;

  String get label {
    switch (this) {
      case RabiesProtocolStatus.sansProtocole:
        return 'Sans protocole';
      case RabiesProtocolStatus.enCours:
        return 'Protocole en cours';
      case RabiesProtocolStatus.enRetard:
        return 'Protocole en retard';
      case RabiesProtocolStatus.termine:
        return 'Protocole terminé';
    }
  }
}

/// Conclusion concernant l'animal en cause (influence la conduite clinique).
enum AnimalConclusion {
  enrageConfirme,
  nonEnrageConfirme,
  enAttente,
  indetermine;

  String get label {
    switch (this) {
      case AnimalConclusion.enrageConfirme:
        return 'Animal enragé confirmé';
      case AnimalConclusion.nonEnrageConfirme:
        return 'Animal non enragé';
      case AnimalConclusion.enAttente:
        return 'Résultat en attente';
      case AnimalConclusion.indetermine:
        return 'Statut indéterminé';
    }
  }
}

/// Résumé agrégé du parcours de suivi, produit par `RabiesFollowUpService`.
///
/// Objectif : l'UI (écrans de suivi) consomme ce résumé sans jamais recalculer
/// la logique métier (progression, prochaine dose, retards, animal, MPVI,
/// traçabilité, évolution).
class RabiesFollowUpSummary {
  final RabiesDecisionSummary decision;
  final List<RabiesClinicalAlert> alertes;
  final RabiesProtocolStatus protocoleStatut;
  final int dosesRealisees;
  final int totalDoses;
  final double progression; // 0.0 → 1.0
  final VaccineDose? prochaineDose;
  final int joursRetard;
  final bool doseDueAujourdhui;
  final AnimalConclusion animalConclusion;
  final bool mpviPresent;
  final MpviSeverity mpviGravite;
  final bool traceCarteOk;
  final bool traceRegistreOk;
  final FinalCaseOutcome evolutionResultat;
  final bool dossierClos;

  const RabiesFollowUpSummary({
    required this.decision,
    required this.alertes,
    required this.protocoleStatut,
    required this.dosesRealisees,
    required this.totalDoses,
    required this.progression,
    required this.prochaineDose,
    required this.joursRetard,
    required this.doseDueAujourdhui,
    required this.animalConclusion,
    required this.mpviPresent,
    required this.mpviGravite,
    required this.traceCarteOk,
    required this.traceRegistreOk,
    required this.evolutionResultat,
    required this.dossierClos,
  });

  int get alertesCritiques =>
      alertes.where((a) => a.severity == RabiesAlertSeverity.critical).length;

  int get alertesWarnings =>
      alertes.where((a) => a.severity == RabiesAlertSeverity.warning).length;

  bool get traceComplete => traceCarteOk && traceRegistreOk;

  int get progressionPercent => (progression * 100).round();

  /// Prochaine dose à administrer, ou null si le protocole est terminé / vide.
  VaccineDose? get prochaineDoseNonRealisee => prochaineDose;
}
