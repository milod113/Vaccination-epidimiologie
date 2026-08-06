import '../../../domain/models/dossier/dossier_actor.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/dossier_history.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/services/actor_context.dart';
import '../../../domain/services/rabies_traceability_service.dart';

/// Génère un historique réglementaire crédible à partir d'un dossier seed.
///
/// Le mock se comporte comme une vraie base : chaque état d'un dossier produit
/// les événements qui ont conduit à cet état (création, J0 validée, catégorie,
/// protocole, ERIG, doses réalisées, MPVI, carte/registre, clôture).
///
/// On enrichit aussi la traçabilité administrative avec l'acteur et la date de
/// remise / d'inscription lorsque le dossier indique que c'est fait.
class MockRabiesHistoryFactory {
  const MockRabiesHistoryFactory._();

  static final _now = DateTime.now();

  /// Enrichit un dossier : traçabilité (acteur/date) + historique complet.
  static RabiesCaseRecord enrichir(RabiesCaseRecord record) {
    final base = record.admission.dateArriveeUar ??
        record.dateCreation ??
        _now;
    final tr = record.tracabilite;
    final tracabilite = tr.copyWith(
      carteRemisePar: tr.carteRemise ? ActorContext.secretaire : null,
      dateCarteRemise:
          tr.carteRemise ? base.add(const Duration(minutes: 35)) : null,
      registreRenseignePar:
          tr.patientRepertorie ? ActorContext.secretaire : null,
      dateInscriptionRegistre:
          tr.patientRepertorie ? base.add(const Duration(minutes: 42)) : null,
    );
    final withTrace = record.copyWith(tracabilite: tracabilite);
    return withTrace.copyWith(historique: _build(withTrace, base: base));
  }

  static List<RabiesDossierHistoryEntry> _build(
    RabiesCaseRecord record, {
    required DateTime base,
  }) {
    final entries = <RabiesDossierHistoryEntry>[];
    var minutes = -25;

    void add(
      DossierHistoryActionType type,
      String titre,
      DossierSectionType section,
      DossierActor acteur, {
      String? description,
      ValidationStepType? etape,
      String? ancienne,
      String? nouvelle,
    }) {
      minutes += 15;
      entries.add(
        RabiesTraceabilityService.creerEntree(
          typeAction: type,
          titre: titre,
          sectionConcernee: section,
          acteur: acteur,
          description: description,
          etapeValidee: etape,
          ancienneValeur: ancienne,
          nouvelleValeur: nouvelle,
          dateHeure: base.add(Duration(minutes: minutes)),
        ),
      );
    }

    add(
      DossierHistoryActionType.creationDossier,
      'Création du dossier',
      DossierSectionType.dossier,
      ActorContext.infirmier,
      description: 'Ouverture du dossier ${record.numeroDossier} à l\'UAR.',
      etape: ValidationStepType.ficheJ0,
    );
    add(
      DossierHistoryActionType.evaluationJ0Validee,
      'Fiche J0 validée',
      DossierSectionType.classification,
      ActorContext.medecin,
      description: 'Évaluation initiale validée par le médecin.',
      etape: ValidationStepType.ficheJ0,
    );
    add(
      DossierHistoryActionType.categorieRecalculee,
      'Catégorie clinique déterminée',
      DossierSectionType.classification,
      ActorContext.medecin,
      ancienne: '—',
      nouvelle: record.categorie.label,
      etape: ValidationStepType.categorieClinique,
    );

    final proto = record.vaccination.protocole;
    if (proto.totalDoses > 0) {
      add(
        DossierHistoryActionType.protocoleChoisi,
        'Protocole vaccinal choisi',
        DossierSectionType.vaccination,
        ActorContext.medecin,
        nouvelle: '${proto.type.label} — ${proto.totalDoses} doses',
        etape: ValidationStepType.vaccinationInitiation,
      );
    }

    if (record.erig.administree) {
      add(
        DossierHistoryActionType.erigAdministree,
        'ERIG administrée',
        DossierSectionType.erig,
        ActorContext.agentVaccination,
        description: record.erig.numeroLot != null
            ? 'Lot ${record.erig.numeroLot}'
            : null,
        etape: ValidationStepType.erigAdministration,
      );
    }

    var doseStart = minutes;
    for (final dose in proto.doses) {
      if (!dose.estRealisee) continue;
      doseStart += 15;
      entries.add(
        RabiesTraceabilityService.creerEntree(
          typeAction: DossierHistoryActionType.doseAdministree,
          titre: 'Dose ${dose.etiquette} administrée',
          sectionConcernee: DossierSectionType.vaccination,
          acteur: ActorContext.agentVaccination,
          description: dose.numeroLot != null
              ? '${dose.voie.label} · lot ${dose.numeroLot}'
              : dose.voie.label,
          etapeValidee: ValidationStepType.doseAdministration,
          dateHeure: base.add(Duration(minutes: doseStart)),
        ),
      );
    }
    minutes = doseStart;

    if (record.mpvi.present) {
      add(
        DossierHistoryActionType.mpviEnregistre,
        'Effet indésirable enregistré',
        DossierSectionType.mpvi,
        ActorContext.infirmier,
        description: record.mpvi.manifestations,
        etape: ValidationStepType.effetIndesirable,
      );
    }

    if (record.tracabilite.carteRemise) {
      add(
        DossierHistoryActionType.carteRemise,
        'Carte de vaccination remise',
        DossierSectionType.tracabilite,
        ActorContext.secretaire,
        nouvelle: record.tracabilite.numeroCarte != null
            ? 'N° ${record.tracabilite.numeroCarte}'
            : null,
        etape: ValidationStepType.carteVaccination,
      );
    }

    if (record.tracabilite.patientRepertorie) {
      add(
        DossierHistoryActionType.registreRenseigne,
        'Inscription au registre de l\'UAR',
        DossierSectionType.tracabilite,
        ActorContext.secretaire,
        nouvelle: record.tracabilite.numeroRegistre != null
            ? 'N° ${record.tracabilite.numeroRegistre}'
            : null,
        etape: ValidationStepType.registreInscription,
      );
    }

    if (record.evolution.estClos) {
      add(
        DossierHistoryActionType.dossierCloture,
        'Dossier finalisé',
        DossierSectionType.evolution,
        ActorContext.medecin,
        description: record.evolution.resultat.label,
        etape: ValidationStepType.dossierCloture,
      );
    }

    entries.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return entries;
  }
}