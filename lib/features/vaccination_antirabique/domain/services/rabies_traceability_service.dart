import '../models/dossier/dossier_actor.dart';
import '../models/dossier/dossier_enums.dart';
import '../models/dossier/dossier_history.dart';
import '../models/dossier/dossier_traceability_summary.dart';
import '../models/dossier/rabies_case_record.dart';
import 'actor_context.dart';

/// Service métier centralisé de la traçabilité réglementaire du dossier.
///
/// Responsabilités :
/// - créer des entrées d'historique normalisées ([creerEntree]) ;
/// - ajouter un événement à un dossier (retourne une nouvelle copie) ;
/// - valider une étape réglementaire ([validerEtape]) ;
/// - lister / trier / filtrer les événements ([lister]) ;
/// - produire un résumé exploitable ([resume]).
///
/// Les widgets n'écrivent jamais l'historique directement : ils passent par
/// cette couche métier.
class RabiesTraceabilityService {
  const RabiesTraceabilityService._();

  // ── Construction d'une entrée ─────────────────────────────────────

  /// Construit une entrée d'historique normalisée et horodatée.
  static RabiesDossierHistoryEntry creerEntree({
    required DossierHistoryActionType typeAction,
    required String titre,
    required DossierSectionType sectionConcernee,
    required DossierActor acteur,
    String? description,
    ValidationStepType? etapeValidee,
    ValidationStatus statut = ValidationStatus.validee,
    String? ancienneValeur,
    String? nouvelleValeur,
    String? origine,
    DateTime? dateHeure,
  }) {
    return RabiesDossierHistoryEntry(
      id: _genererId(),
      dateHeure: dateHeure ?? DateTime.now(),
      typeAction: typeAction,
      titre: titre,
      description: description,
      sectionConcernee: sectionConcernee,
      acteur: acteur,
      etapeValidee: etapeValidee,
      statut: statut,
      ancienneValeur: ancienneValeur,
      nouvelleValeur: nouvelleValeur,
      origine: origine ?? 'Application',
    );
  }

  static String _genererId() {
    final now = DateTime.now();
    return 'H${now.microsecondsSinceEpoch}';
  }

  // ── Mutation du dossier ────────────────────────────────────────────

  /// Ajoute une entrée d'historique au dossier (copie mise à jour).
  static RabiesCaseRecord ajouter(
    RabiesCaseRecord record,
    RabiesDossierHistoryEntry entree,
  ) {
    return record.copyWith(historique: [...record.historique, entree]);
  }

  /// Ajoute un événement décrit à un dossier et retourne la copie mise à jour.
  static RabiesCaseRecord ajouterEvenement(
    RabiesCaseRecord record, {
    required DossierHistoryActionType typeAction,
    required String titre,
    required DossierSectionType sectionConcernee,
    required DossierActor acteur,
    String? description,
    ValidationStepType? etapeValidee,
    ValidationStatus statut = ValidationStatus.validee,
    String? ancienneValeur,
    String? nouvelleValeur,
    String? origine,
    DateTime? dateHeure,
  }) {
    return ajouter(
      record,
      creerEntree(
        typeAction: typeAction,
        titre: titre,
        sectionConcernee: sectionConcernee,
        acteur: acteur,
        description: description,
        etapeValidee: etapeValidee,
        statut: statut,
        ancienneValeur: ancienneValeur,
        nouvelleValeur: nouvelleValeur,
        origine: origine,
        dateHeure: dateHeure,
      ),
    );
  }

  /// Valide une étape réglementaire : ajoute l'événement correspondant,
  /// avec l'acteur passé (ou l'acteur courant de la session).
  static RabiesCaseRecord validerEtape(
    RabiesCaseRecord record, {
    required ValidationStepType etape,
    DossierActor? acteur,
    String? description,
    ValidationStatus statut = ValidationStatus.validee,
    String? ancienneValeur,
    String? nouvelleValeur,
    DateTime? dateHeure,
  }) {
    final a = acteur ?? ActorContext.acteurCourant;
    final mapping = _mappingEtape(etape);
    return ajouter(
      record,
      creerEntree(
        typeAction: mapping.$1,
        titre: mapping.$3,
        sectionConcernee: mapping.$2,
        acteur: a,
        description: description,
        etapeValidee: etape,
        statut: statut,
        ancienneValeur: ancienneValeur,
        nouvelleValeur: nouvelleValeur,
        dateHeure: dateHeure,
      ),
    );
  }

  /// Mappe une étape de validation vers (type d'action, section, titre).
  static (DossierHistoryActionType, DossierSectionType, String) _mappingEtape(
    ValidationStepType etape,
  ) {
    switch (etape) {
      case ValidationStepType.ficheJ0:
        return (
          DossierHistoryActionType.evaluationJ0Validee,
          DossierSectionType.classification,
          'Fiche J0 validée',
        );
      case ValidationStepType.categorieClinique:
        return (
          DossierHistoryActionType.categorieRecalculee,
          DossierSectionType.classification,
          'Catégorie clinique déterminée',
        );
      case ValidationStepType.erigAdministration:
        return (
          DossierHistoryActionType.erigAdministree,
          DossierSectionType.erig,
          'ERIG administrée',
        );
      case ValidationStepType.vaccinationInitiation:
        return (
          DossierHistoryActionType.protocoleChoisi,
          DossierSectionType.vaccination,
          'Vaccination initiée',
        );
      case ValidationStepType.doseAdministration:
        return (
          DossierHistoryActionType.doseAdministree,
          DossierSectionType.vaccination,
          'Dose administrée',
        );
      case ValidationStepType.effetIndesirable:
        return (
          DossierHistoryActionType.mpviEnregistre,
          DossierSectionType.mpvi,
          'Effet indésirable enregistré',
        );
      case ValidationStepType.carteVaccination:
        return (
          DossierHistoryActionType.carteRemise,
          DossierSectionType.tracabilite,
          'Carte de vaccination remise',
        );
      case ValidationStepType.registreInscription:
        return (
          DossierHistoryActionType.registreRenseigne,
          DossierSectionType.tracabilite,
          'Inscription au registre',
        );
      case ValidationStepType.dossierCloture:
        return (
          DossierHistoryActionType.dossierCloture,
          DossierSectionType.evolution,
          'Dossier finalisé',
        );
    }
  }

  // ── Lecture / filtrage ─────────────────────────────────────────────

  /// Liste les événements du plus récent au plus ancien.
  ///
  /// Peut être filtrée par [section] (dossier complet si null).
  static List<RabiesDossierHistoryEntry> lister(
    RabiesCaseRecord record, {
    DossierSectionType? section,
  }) {
    final all = [...record.historique];
    all.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    if (section != null) {
      return all.where((e) => e.sectionConcernee == section).toList();
    }
    return all;
  }

  /// Nombre d'événements (éventuellement filtrés par section).
  static int compter(RabiesCaseRecord record, {DossierSectionType? section}) =>
      lister(record, section: section).length;

  /// Dernière entrée de l'historique (ou null).
  static RabiesDossierHistoryEntry? derniere(
    RabiesCaseRecord record, {
    DossierSectionType? section,
  }) {
    final list = lister(record, section: section);
    return list.isEmpty ? null : list.first;
  }

  // ── Résumé ─────────────────────────────────────────────────────────

  /// Produit le résumé de traçabilité exploitable par l'UI.
  static RabiesTraceabilitySummary resume(RabiesCaseRecord record) {
    final tr = record.tracabilite;
    final entries = lister(record);
    return RabiesTraceabilitySummary(
      carteRemise: tr.carteRemise,
      numeroCarte: tr.numeroCarte,
      registreRenseigne: tr.patientRepertorie,
      numeroRegistre: tr.numeroRegistre,
      remarques: tr.remarques,
      nombreEvenements: entries.length,
      dernierActeur: entries.isNotEmpty ? entries.first.acteur : null,
      derniereModification:
          entries.isNotEmpty ? entries.first.dateHeure : record.dateMaj,
      statut: tr.statut,
      completude: tr.completude,
      carteRemisePar: tr.carteRemisePar,
      dateCarteRemise: tr.dateCarteRemise,
      registreRenseignePar: tr.registreRenseignePar,
      dateInscriptionRegistre: tr.dateInscriptionRegistre,
    );
  }
}