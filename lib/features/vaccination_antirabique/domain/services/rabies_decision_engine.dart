import '../models/dossier/dossier_enums.dart';
import '../models/dossier/exposure.dart';
import '../models/dossier/rabies_case_record.dart';
import '../models/dossier/rabies_clinical_alert.dart';
import '../models/dossier/rabies_decision_summary.dart';
import '../models/dossier/vaccination.dart';
import 'rabies_protocol_resolver.dart';

/// Moteur de décision clinique antirabique.
///
/// Concentre toute la logique automatique (catégorie OMS, PPE, ERIG,
/// protocole, retard, prochaine dose, alertes) afin que les widgets ne
/// contiennent jamais de logique métier dupliquée.
///
/// Les règles suivent la classification OMS du risque rabique et le dossier
/// antirabique algérien (fiche papier + instruction 2024).
class RabiesDecisionEngine {
  const RabiesDecisionEngine._();

  // ── 1. Catégorie de risque (OMS) ────────────────────────────────────

  /// Calcule la catégorie de risque rabique et sa justification.
  ///
  /// - Catégorie I   : contact / affouragement, peau intacte.
  /// - Catégorie II  : griffure superficielle sans saignement, léchage
  ///   sur peau lésée, sur peau non intacte.
  /// - Catégorie III : morsure transdermique, griffure avec saignement,
  ///   léchage sur muqueuse, contact muqueux, sièges critiques.
  static RabiesCategoryDecision categorie(ExposureDetails e) {
    RabiesRiskCategory cat;
    String raison;

    switch (e.nature) {
      case ExposureNature.contact:
        cat = RabiesRiskCategory.categorieI;
        raison = 'Simple contact ou affouragement, peau intacte : '
            'aucun risque de transmission.';
      case ExposureNature.lechagePeauLestee:
        cat = RabiesRiskCategory.categorieII;
        raison = 'Léchage sur peau lésée sans saignement : '
            'exposition superficielle.';
      case ExposureNature.lechageMuqueuse:
        cat = RabiesRiskCategory.categorieIII;
        raison = 'Léchage sur muqueuse : contact muqueux, '
            'risque élevé de transmission.';
      case ExposureNature.griffure:
        if (e.aSaignement) {
          cat = RabiesRiskCategory.categorieIII;
          raison = 'Griffure avec saignement : lésion transdermique.';
        } else if (e.siegeSevere) {
          cat = RabiesRiskCategory.categorieIII;
          raison = 'Griffure sur zone critique (tête, face, cou, mains, '
              'organes génitaux) : catégorie III par siège.';
        } else {
          cat = RabiesRiskCategory.categorieII;
          raison = 'Griffure superficielle sans saignement, '
              'hors zone critique.';
        }
      case ExposureNature.morsure:
        cat = RabiesRiskCategory.categorieIII;
        raison = 'Morsure transdermique : inoculation directe du virus.';
    }

    if (e.siegeSevere && cat == RabiesRiskCategory.categorieII) {
      cat = RabiesRiskCategory.categorieIII;
      raison = '$raison. Siège critique (tête, face, cou, mains, '
          'organes génitaux) → catégorie III.';
    }

    return RabiesCategoryDecision(categorie: cat, raison: raison);
  }

  // ── 2. PPE (prophylaxie post-exposition) ───────────────────────────

  /// Déduit l'indication PPE à partir de la catégorie.
  ///
  /// - Catégorie I  → PPE non indiquée.
  /// - Catégorie II → PPE indiquée.
  /// - Catégorie III→ PPE indiquée et urgente.
  static RabiesPpeDecision ppe(RabiesRiskCategory cat) {
    switch (cat) {
      case RabiesRiskCategory.categorieI:
        return const RabiesPpeDecision(
          indiquee: false,
          urgente: false,
          message: 'Aucune prophylaxie post-exposition nécessaire.',
        );
      case RabiesRiskCategory.categorieII:
        return const RabiesPpeDecision(
          indiquee: true,
          urgente: false,
          message: 'PPE indiquée : vaccination antirabique à initier.',
        );
      case RabiesRiskCategory.categorieIII:
        return const RabiesPpeDecision(
          indiquee: true,
          urgente: true,
          message: 'PPE URGENTE : vaccin + ERIG à administrer '
              'immédiatement (J0).',
        );
    }
  }

  // ── 3. ERIG (immunoglobulines) ─────────────────────────────────────

  /// Évalue l'indication et la faisabilité de l'ERIG.
  ///
  /// - Catégorie III → ERIG indiquée.
  /// - Vaccination commencée il y a plus de 7 jours → ERIG plus indiquée.
  /// - Administrée sans lot / dose / voie → avertissements de complétude.
  static RabiesErigDecision erig(
    RabiesCaseRecord record, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final cat = record.categorie;
    final indicated = cat == RabiesRiskCategory.categorieIII;

    final warnings = <RabiesClinicalAlert>[];

    if (!indicated) {
      return RabiesErigDecision(
        indiquee: false,
        encorePermise: false,
        administree: record.erig.administree,
        message: 'ERIG non indiquée (exposition de ${cat.label}).',
        warnings: warnings,
      );
    }

    // Délai : ERIG ≤ 7 jours après le début de la vaccination.
    final debutVaccination = record.vaccination.protocole.dateDebut ??
        record.vaccination.protocole.doses
            .where((d) => d.dateReelle != null)
            .map((d) => d.dateReelle!)
            .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
    final joursDepuisVaccin = debutVaccination == null
        ? 0
        : ref.difference(debutVaccination).inDays;
    final encorePermise = debutVaccination == null || joursDepuisVaccin <= 7;

    final administree = record.erig.administree;

    String message;
    if (administree) {
      message = 'ERIG administrée.';
    } else if (encorePermise) {
      message = 'ERIG indiquée et encore permise : à administrer.';
    } else {
      message = 'ERIG indiquée mais délai dépassé '
          '(vaccination commencée depuis > 7 jours).';
    }

    if (!administree && encorePermise) {
      warnings.add(RabiesClinicalAlert(
        id: 'ERIG-NON-ADMIN',
        titre: 'ERIG indiquée non administrée',
        message: 'L\'ERIG est indiquée (catégorie III) et n\'a pas '
            'encore été administrée.',
        severity: RabiesAlertSeverity.critical,
        category: RabiesAlertCategory.erig,
        section: RabiesAlertSection.erig,
        blocking: true,
        recommendation: 'Administrer l\'ERIG dès que possible.',
      ));
    } else if (!encorePermise && !administree) {
      warnings.add(RabiesClinicalAlert(
        id: 'ERIG-DELAI',
        titre: 'Délai ERIG dépassé',
        message: 'La vaccination a commencé il y a plus de 7 jours : '
            'l\'ERIG n\'est plus indiquée.',
        severity: RabiesAlertSeverity.warning,
        category: RabiesAlertCategory.erig,
        section: RabiesAlertSection.erig,
        recommendation: 'Poursuivre le schéma vaccinal sans ERIG.',
      ));
    }

    if (administree) {
      if (record.erig.numeroLot == null || record.erig.numeroLot!.isEmpty) {
        warnings.add(RabiesClinicalAlert(
          id: 'ERIG-LOT',
          titre: 'Numéro de lot ERIG manquant',
          message: 'L\'ERIG a été administrée sans numéro de lot.',
          severity: RabiesAlertSeverity.warning,
          category: RabiesAlertCategory.erig,
          section: RabiesAlertSection.erig,
          recommendation: 'Renseigner le lot pour la traçabilité.',
        ));
      }
      if (record.erig.doseTotaleTheoriqueIU == null) {
        warnings.add(RabiesClinicalAlert(
          id: 'ERIG-DOSE',
          titre: 'Dose ERIG manquante',
          message: 'La dose théorique (UI) n\'est pas renseignée.',
          severity: RabiesAlertSeverity.warning,
          category: RabiesAlertCategory.erig,
          section: RabiesAlertSection.erig,
          recommendation: 'Calculer dose = poids (kg) × 20 UI/kg.',
        ));
      }
      if (record.erig.voies.isEmpty) {
        warnings.add(RabiesClinicalAlert(
          id: 'ERIG-VOIES',
          titre: 'Voie d\'administration ERIG manquante',
          message: 'Aucune voie d\'administration renseignée.',
          severity: RabiesAlertSeverity.warning,
          category: RabiesAlertCategory.erig,
          section: RabiesAlertSection.erig,
        ));
      }
    }

    return RabiesErigDecision(
      indiquee: indicated,
      encorePermise: encorePermise,
      administree: administree,
      message: message,
      warnings: warnings,
    );
  }

  // ── 4. Protocole vaccinal ──────────────────────────────────────────

  /// Propose le protocole le plus adapté.
  ///
  /// - Catégorie I → aucun protocole.
  /// - Catégorie II → Essen (ou tissulaire grade II si vaccin tissulaire).
  /// - Catégorie III → Zagreb (ou Essen si immunodéprimé).
  /// - Déjà vacciné (rappel) → schéma rappel J0/J3.
  static RabiesProtocolDecision? protocole(
    RabiesRiskCategory cat, {
    bool dejaVaccine = false,
    bool immunodeprime = false,
    bool vaccinTissulaire = false,
  }) {
    if (cat == RabiesRiskCategory.categorieI && !dejaVaccine) return null;

    VaccinationProtocolType type;
    String justification;

    if (dejaVaccine) {
      type = VaccinationProtocolType.rappelJ0J3;
      justification = 'Patient préalablement vacciné (rappel complet) : '
          'schéma rappel J0/J3.';
    } else if (vaccinTissulaire) {
      type = cat == RabiesRiskCategory.categorieIII
          ? VaccinationProtocolType.vaccinTissulaireGradeIII
          : VaccinationProtocolType.vaccinTissulaireGradeII;
      justification = 'Vaccin tissulaire utilisé : protocole '
          '${cat == RabiesRiskCategory.categorieIII ? 'grade III' : 'grade II'}.';
    } else if (cat == RabiesRiskCategory.categorieIII) {
      type = immunodeprime
          ? VaccinationProtocolType.essen
          : VaccinationProtocolType.zagreb;
      justification = immunodeprime
          ? 'Catégorie III + immunodépression : schéma Essen 5 doses.'
          : 'Catégorie III : schéma Zagreb 2-1-1 (réduit, 3 visites).';
    } else {
      type = VaccinationProtocolType.essen;
      justification = 'Catégorie II : schéma Essen 5 doses.';
    }

    return RabiesProtocolDecision(
      type: type,
      justification: justification,
      schemaJours: RabiesProtocolResolver.joursTheoriques(type),
    );
  }

  // ── 5. Prochaine dose / retard ─────────────────────────────────────

  /// Prochaine dose à administrer (ou null si terminé / vide).
  static VaccineDose? prochaineDose(RabiesCaseRecord record) {
    if (record.vaccination.protocole.doses.isEmpty) return null;
    return RabiesProtocolResolver.prochaineDose(record.vaccination.protocole);
  }

  /// Doses attendues aujourd'hui.
  static List<VaccineDose> dosesAujourdHui(
    RabiesCaseRecord record,
    DateTime now,
  ) =>
      RabiesProtocolResolver.dosesAujourdHui(record.vaccination.protocole, now);

  /// Doses en attente (non réalisées).
  static List<VaccineDose> dosesEnAttente(RabiesCaseRecord record) =>
      RabiesProtocolResolver.dosesEnAttente(record.vaccination.protocole);

  /// Doses en retard (date prévue passée, non réalisée).
  static List<VaccineDose> dosesEnRetard(
    RabiesCaseRecord record,
    DateTime now,
  ) =>
      RabiesProtocolResolver.dosesEnRetard(record.vaccination.protocole, now);

  /// Le protocole est-il en retard ?
  static bool enRetard(RabiesCaseRecord record, DateTime now) =>
      RabiesProtocolResolver.enRetard(record.vaccination.protocole, now);

  /// Nombre de jours de retard max.
  static int joursRetard(RabiesCaseRecord record, DateTime now) =>
      RabiesProtocolResolver.retardMax(record.vaccination.protocole, now);

  // ── 6. Résumé de décision clinique ─────────────────────────────────

  /// Produit le résumé complet du dossier à un instant donné.
  static RabiesDecisionSummary resumer(
    RabiesCaseRecord record, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final cat = categorie(record.exposition);
    final ppeDecision = ppe(cat.categorie);
    final erigDecision = erig(record, now: ref);
    final protocolDecision = protocole(
      cat.categorie,
      dejaVaccine:
          record.vaccination.protocole.type == VaccinationProtocolType.rappelJ0J3,
      immunodeprime:
          record.identity.terrainParticulier?.toLowerCase().contains('immuno') ??
              false,
      vaccinTissulaire:
          record.vaccination.typeVaccin == RabiesVaccineType.vaccinTissulaire,
    );

    final retard = RabiesProtocolResolver.enRetard(
      record.vaccination.protocole,
      ref,
    );
    final joursRetard = RabiesProtocolResolver.retardMax(
      record.vaccination.protocole,
      ref,
    );
    final prochaine = RabiesProtocolResolver.prochaineDose(
      record.vaccination.protocole,
    );

    // Statut global du dossier.
    final statut = _statutGlobal(
      record,
      protocole: protocolDecision,
      retard: retard,
      dosesVides: record.vaccination.protocole.doses.isEmpty,
    );

    return RabiesDecisionSummary(
      categorie: cat,
      ppe: ppeDecision,
      erig: erigDecision,
      protocole: protocolDecision,
      prochaineDose: prochaine,
      retard: retard,
      joursRetard: joursRetard,
      alertes: [],
      statut: statut,
    );
  }

  static RabiesDossierStatus _statutGlobal(
    RabiesCaseRecord record, {
    required RabiesProtocolDecision? protocole,
    required bool retard,
    required bool dosesVides,
  }) {
    if (record.evolution.estClos) return RabiesDossierStatus.terminee;
    if (protocole == null && dosesVides) {
      // Catégorie I : pas de protocole → prête si le reste est rempli.
      return RabiesDossierStatus.prete;
    }
    if (retard) return RabiesDossierStatus.enRetard;
    if (record.vaccination.protocole.estTermine) {
      return RabiesDossierStatus.terminee;
    }
    return RabiesDossierStatus.aCompleter;
  }
}
