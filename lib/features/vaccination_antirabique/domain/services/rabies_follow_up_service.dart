import '../models/dossier/dossier_enums.dart';
import '../models/dossier/rabies_case_record.dart';
import '../models/dossier/rabies_follow_up_summary.dart';
import 'rabies_alert_service.dart';
import 'rabies_decision_engine.dart';
import 'rabies_protocol_resolver.dart';

/// Service métier du parcours de suivi post-J0.
///
/// Concentre la logique de suivi (progression, prochaine dose, retards,
/// conclusion animale, MPVI, traçabilité, évolution) ainsi que les mutations
/// possibles du dossier (valider une dose, reporter, marquer manquée).
/// Les widgets appellent ce service et n'implémentent aucune règle métier.
class RabiesFollowUpService {
  const RabiesFollowUpService._();

  // ── Agrégation du résumé de suivi ─────────────────────────────────

  /// Construit le résumé complet du parcours de suivi à un instant donné.
  static RabiesFollowUpSummary summary(
    RabiesCaseRecord record, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final decision = RabiesDecisionEngine.resumer(record, now: ref);
    final alertes = RabiesAlertService.evaluer(record, now: ref);
    final proto = record.vaccination.protocole;

    final total = proto.totalDoses;
    final realisees = proto.dosesRealisees;

    final enRetard = RabiesProtocolResolver.enRetard(proto, ref);
    final statut = total == 0
        ? RabiesProtocolStatus.sansProtocole
        : proto.estTermine
            ? RabiesProtocolStatus.termine
            : enRetard
                ? RabiesProtocolStatus.enRetard
                : RabiesProtocolStatus.enCours;

    return RabiesFollowUpSummary(
      decision: decision,
      alertes: alertes,
      protocoleStatut: statut,
      dosesRealisees: realisees,
      totalDoses: total,
      progression: total == 0 ? 0.0 : realisees / total,
      prochaineDose: RabiesProtocolResolver.prochaineDose(proto),
      joursRetard: RabiesProtocolResolver.retardMax(proto, ref),
      doseDueAujourdhui:
          RabiesProtocolResolver.dosesAujourdHui(proto, ref).isNotEmpty,
      animalConclusion: _animalConclusion(record),
      mpviPresent: record.mpvi.present,
      mpviGravite: record.mpvi.gravite,
      traceCarteOk: record.tracabilite.carteRemise,
      traceRegistreOk: record.tracabilite.patientRepertorie,
      evolutionResultat: record.evolution.resultat,
      dossierClos: record.evolution.estClos,
    );
  }

  /// Détermine la conclusion concernant l'animal.
  ///
  /// - Labo positif ou observation « enragé » → enragé confirmé.
  /// - Labo négatif ou observation « non enragé » → non enragé.
  /// - Observation ou analyse en cours → en attente.
  /// - Sinon → indéterminé.
  static AnimalConclusion _animalConclusion(RabiesCaseRecord record) {
    final a = record.animal;
    if (a.resultatLabo == LabResultStatus.positifAnimalEnrage ||
        a.resultatObservation == ObservationResult.enrage) {
      return AnimalConclusion.enrageConfirme;
    }
    if (a.resultatLabo == LabResultStatus.negatifAnimalNonEnrage ||
        a.resultatObservation == ObservationResult.nonEnrage) {
      return AnimalConclusion.nonEnrageConfirme;
    }
    if (a.resultatLabo == LabResultStatus.enAttente ||
        a.observationVeterinaire == ObservationStatus.oui) {
      return AnimalConclusion.enAttente;
    }
    return AnimalConclusion.indetermine;
  }

  // ── Mutations du dossier (actions de suivi) ───────────────────────

  /// Marque une dose comme réalisée (administrée).
  ///
  /// Met à jour le statut, la date réelle (par défaut aujourd'hui), le lot
  /// (par défaut celui du vaccin courant) et le flag `complete` du protocole
  /// lorsque toutes les doses sont réalisées.
  static RabiesCaseRecord validerDose(
    RabiesCaseRecord record,
    int numero, {
    DateTime? dateReelle,
    String? numeroLot,
    String? notes,
  }) {
    final proto = record.vaccination.protocole;
    final doses = proto.doses.map((dose) {
      if (dose.numero != numero || dose.estRealisee) return dose;
      return dose.copyWith(
        statut: DoseStatus.realisee,
        dateReelle: dateReelle ?? DateTime.now(),
        numeroLot: numeroLot ?? record.vaccination.numeroLot ?? dose.numeroLot,
        notes: notes ?? dose.notes,
      );
    }).toList();

    final allDone = doses.isNotEmpty && doses.every((d) => d.estRealisee);
    final updatedProto = proto.copyWith(doses: doses, complete: allDone);

    return record.copyWith(
      vaccination: record.vaccination.copyWith(protocole: updatedProto),
      dateMaj: DateTime.now(),
    );
  }

  /// Reporte une dose non réalisée : décale la date prévue (par défaut +7 j)
  /// et replace le statut en `prevue` pour qu'elle ne soit plus comptée en
  /// retard tant que le nouveau rendez-vous n'est pas passé.
  static RabiesCaseRecord reporterDose(
    RabiesCaseRecord record,
    int numero, {
    DateTime? nouvelleDate,
  }) {
    final proto = record.vaccination.protocole;
    final doses = proto.doses.map((dose) {
      if (dose.numero != numero || dose.estRealisee) return dose;
      final newDate = nouvelleDate ??
          (dose.datePrevue ?? DateTime.now()).add(const Duration(days: 7));
      return dose.copyWith(
        statut: DoseStatus.prevue,
        datePrevue: newDate,
        notes: [
          if (dose.notes != null) dose.notes!,
          'Dose reportée',
        ].join(' · '),
      );
    }).toList();

    return record.copyWith(
      vaccination: record.vaccination.copyWith(
        protocole: proto.copyWith(doses: doses),
      ),
      dateMaj: DateTime.now(),
    );
  }

  /// Marque une dose comme manquée (non administrée, perdue de vue).
  static RabiesCaseRecord marquerDoseManquee(
    RabiesCaseRecord record,
    int numero,
  ) {
    final proto = record.vaccination.protocole;
    final doses = proto.doses.map((dose) {
      if (dose.numero != numero || dose.estRealisee) return dose;
      return dose.copyWith(statut: DoseStatus.manquee);
    }).toList();

    return record.copyWith(
      vaccination: record.vaccination.copyWith(
        protocole: proto.copyWith(doses: doses),
      ),
      dateMaj: DateTime.now(),
    );
  }

  /// Durée estimée du protocole (en jours) à partir de la date de début.
  static int dureeEstimee(RabiesCaseRecord record) {
    final type = record.vaccination.protocole.type;
    return RabiesProtocolResolver.dureeJours(type);
  }

  /// Date de fin estimée du protocole.
  static DateTime? dateFinEstimee(RabiesCaseRecord record) {
    final debut = record.vaccination.protocole.dateDebut;
    if (debut == null) return null;
    return debut.add(Duration(days: dureeEstimee(record)));
  }
}
