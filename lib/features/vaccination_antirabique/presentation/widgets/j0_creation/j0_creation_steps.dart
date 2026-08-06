import 'package:flutter/material.dart';

import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../../../domain/models/dossier/rabies_clinical_alert.dart';
import '../j0_wizard/j0_step_model.dart';

/// Étapes du wizard de création de l'évaluation J0.
///
/// Le découpage reprend le formulaire algérien du patient exposé au risque
/// rabique : accueil/admission, exposition, lésions, classification, animal,
/// soins/ERIG, vaccination/protocole puis traçabilité/validation.
class J0CreationSteps {
  const J0CreationSteps._();

  static const List<J0StepData> tous = [
    J0StepData(
      id: 'patient',
      number: '01',
      title: 'Patient · Admission',
      shortTitle: 'Admission',
      icon: Icons.badge_outlined,
      subtitle: 'Identité, adresse et accueil à l\'UAR.',
      sections: [
        RabiesAlertSection.identite,
        RabiesAlertSection.adresse,
        RabiesAlertSection.admission,
      ],
    ),
    J0StepData(
      id: 'exposition',
      number: '02',
      title: 'Exposition au risque rabique',
      shortTitle: 'Exposition',
      icon: Icons.coronavirus_outlined,
      subtitle: 'Date, heure, nature, siège et gravité de l\'exposition.',
      sections: [RabiesAlertSection.exposition],
    ),
    J0StepData(
      id: 'lesions',
      number: '03',
      title: 'Lésions · Gravité locale',
      shortTitle: 'Lésions',
      icon: Icons.healing_outlined,
      subtitle: 'État local de la plaie et éléments de gravité.',
      sections: [RabiesAlertSection.soinsLocaux],
    ),
    J0StepData(
      id: 'classification',
      number: '04',
      title: 'Classification du risque',
      shortTitle: 'Risque',
      icon: Icons.offline_bolt_outlined,
      subtitle: 'Catégorie OMS, PPE et immunoglobulines.',
      sections: [RabiesAlertSection.classification],
    ),
    J0StepData(
      id: 'animal',
      number: '05',
      title: 'Animal en cause',
      shortTitle: 'Animal',
      icon: Icons.pets_outlined,
      subtitle: 'Espèce, statut, comportement et devenir de l\'animal.',
      sections: [RabiesAlertSection.animal],
    ),
    J0StepData(
      id: 'soins',
      number: '06',
      title: 'Soins locaux · ERIG',
      shortTitle: 'Soins · ERIG',
      icon: Icons.local_hospital_outlined,
      subtitle: 'Lavage, désinfection et immunoglobulines.',
      sections: [RabiesAlertSection.soinsLocaux, RabiesAlertSection.erig],
    ),
    J0StepData(
      id: 'vaccination',
      number: '07',
      title: 'Vaccination · Protocole',
      shortTitle: 'Vaccination',
      icon: Icons.vaccines_outlined,
      subtitle: 'Type de vaccin, voie, lot et schéma prévu.',
      sections: [RabiesAlertSection.vaccination, RabiesAlertSection.protocole],
    ),
    J0StepData(
      id: 'tracabilite',
      number: '08',
      title: 'Traçabilité · Validation finale',
      shortTitle: 'Validation',
      icon: Icons.verified_outlined,
      subtitle: 'Carte, registre, observations et validation J0.',
      sections: [RabiesAlertSection.tracabilite, RabiesAlertSection.evolution],
    ),
  ];
}

/// Complétude par étape de la création J0.
///
/// Logique métier séparée des widgets : chaque étape est déclarée, son état
/// (non commencée / en cours / complète / à vérifier) est dérivé de l'état
/// courant du formulaire, sans duplication dans l'UI.
class J0CreationStatus {
  const J0CreationStatus._();

  static J0StepStatus statusFor(
    J0StepData step,
    InitialRabiesAssessment a,
    CategorieExposition? categorie,
  ) {
    final base = _baseStatus(step, a);
    if (base == J0StepStatus.complete && _needsReview(step, a, categorie)) {
      return J0StepStatus.toReview;
    }
    return base;
  }

  static J0StepStatus _baseStatus(J0StepData step, InitialRabiesAssessment a) {
    switch (step.id) {
      case 'patient':
        return _patientStatus(a);
      case 'exposition':
        return _expositionStatus(a);
      case 'lesions':
        return _lesionsStatus(a);
      case 'classification':
        return _classificationStatus(a);
      case 'animal':
        return _animalStatus(a);
      case 'soins':
        return _soinsStatus(a);
      case 'vaccination':
        return _vaccinationStatus(a);
      case 'tracabilite':
        return _tracabiliteStatus(a);
      default:
        return J0StepStatus.notStarted;
    }
  }

  static bool _needsReview(
    J0StepData step,
    InitialRabiesAssessment a,
    CategorieExposition? categorie,
  ) {
    switch (step.id) {
      case 'classification':
        // Catégorie III sans ERIG recommandée.
        return categorie == CategorieExposition.categorieIII &&
            !a.conduite.immunoglobulinesAEnvisager;
      case 'soins':
        // ERIG indiquée mais non administrée.
        return a.erigIndiquee && !a.erigAdministree;
      case 'vaccination':
        // PPE indiquée mais lot de vaccin non renseigné.
        return a.conduite.vaccinationIndiquee &&
            (a.vaccinLot == null || a.vaccinLot!.isEmpty);
      case 'tracabilite':
        // Carte / registre incohérents.
        return (a.carteRemise &&
                (a.numeroCarte == null || a.numeroCarte!.isEmpty)) ||
            (a.inscritRegistre &&
                (a.numeroRegistre == null || a.numeroRegistre!.isEmpty));
      default:
        return false;
    }
  }

  // ── Patient / admission ───────────────────────────────────────────
  static J0StepStatus _patientStatus(InitialRabiesAssessment a) {
    final started = (a.heureArrivee?.isNotEmpty ?? false) ||
        (a.modeArrivee?.isNotEmpty ?? false) ||
        (a.structureOrientation?.isNotEmpty ?? false) ||
        (a.commune?.isNotEmpty ?? false) ||
        (a.daira?.isNotEmpty ?? false) ||
        (a.wilaya?.isNotEmpty ?? false) ||
        (a.adresseResidence?.isNotEmpty ?? false);
    if (!started) return J0StepStatus.notStarted;
    final complete = (a.heureArrivee?.isNotEmpty ?? false) &&
        (a.modeArrivee?.isNotEmpty ?? false) &&
        (a.commune?.isNotEmpty ?? false);
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Exposition ───────────────────────────────────────────────────
  static J0StepStatus _expositionStatus(InitialRabiesAssessment a) {
    final e = a.exposition;
    final started = e.morsure ||
        e.griffure ||
        e.contactSalivairePeauLestee ||
        e.contactSalivaireMuqueuse ||
        (e.dateExposition?.isNotEmpty ?? false) ||
        (e.localisation?.isNotEmpty ?? false);
    if (!started) return J0StepStatus.notStarted;
    final natureConnue = e.morsure ||
        e.griffure ||
        e.contactSalivairePeauLestee ||
        e.contactSalivaireMuqueuse;
    final complete = (e.dateExposition?.isNotEmpty ?? false) &&
        (e.localisation?.isNotEmpty ?? false) &&
        natureConnue;
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Lésions / gravité locale ─────────────────────────────────────
  static J0StepStatus _lesionsStatus(InitialRabiesAssessment a) {
    final p = a.plaie;
    final started = p.signesGravite ||
        p.plaieLaveeImmediatement ||
        p.desinfectionRealisee;
    if (!started) return J0StepStatus.notStarted;
    final complete = p.signesGravite ||
        p.plaieLaveeImmediatement ||
        p.desinfectionRealisee;
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Classification ───────────────────────────────────────────────
  static J0StepStatus _classificationStatus(InitialRabiesAssessment a) {
    final started = a.conduite.vaccinationIndiquee ||
        a.conduite.immunoglobulinesAEnvisager ||
        a.decision.demarrerEssen ||
        a.decision.demarrerZagreb ||
        a.decision.demarrerApresConfirmation ||
        a.decision.reevaluationNecessaire;
    if (!started) return J0StepStatus.notStarted;
    final complete = a.decision.demarrerEssen ||
        a.decision.demarrerZagreb ||
        a.decision.demarrerApresConfirmation;
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Animal ───────────────────────────────────────────────────────
  static J0StepStatus _animalStatus(InitialRabiesAssessment a) {
    final started = (a.exposition.especeAnimale?.isNotEmpty ?? false) ||
        (a.animalEspece?.isNotEmpty ?? false) ||
        (a.animalStatut?.isNotEmpty ?? false) ||
        (a.animalComportement?.isNotEmpty ?? false) ||
        (a.animalSort?.isNotEmpty ?? false);
    if (!started) return J0StepStatus.notStarted;
    final complete = (a.exposition.especeAnimale?.isNotEmpty ?? false) ||
        (a.animalEspece?.isNotEmpty ?? false) ||
        (a.animalStatut?.isNotEmpty ?? false) ||
        (a.animalSort?.isNotEmpty ?? false);
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Soins locaux / ERIG ──────────────────────────────────────────
  static J0StepStatus _soinsStatus(InitialRabiesAssessment a) {
    final started = a.lavageEau ||
        a.lavageEauSavon ||
        (a.produitsAppliques?.isNotEmpty ?? false) ||
        a.erigIndiquee ||
        a.erigAdministree;
    if (!started) return J0StepStatus.notStarted;
    final complete = a.erigIndiquee
        ? a.erigAdministree
        : a.lavageEau ||
            a.lavageEauSavon ||
            (a.produitsAppliques?.isNotEmpty ?? false);
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Vaccination / protocole ──────────────────────────────────────
  static J0StepStatus _vaccinationStatus(InitialRabiesAssessment a) {
    final started = (a.vaccinType?.isNotEmpty ?? false) ||
        (a.vaccinLot?.isNotEmpty ?? false) ||
        (a.vaccinDci?.isNotEmpty ?? false) ||
        a.decision.demarrerEssen ||
        a.decision.demarrerZagreb;
    if (!started) return J0StepStatus.notStarted;
    final complete = (a.vaccinLot?.isNotEmpty ?? false) ||
        (a.vaccinDci?.isNotEmpty ?? false);
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }

  // ── Traçabilité ──────────────────────────────────────────────────
  static J0StepStatus _tracabiliteStatus(InitialRabiesAssessment a) {
    final started = a.carteRemise ||
        a.inscritRegistre ||
        (a.numeroCarte?.isNotEmpty ?? false) ||
        (a.numeroRegistre?.isNotEmpty ?? false);
    if (!started) return J0StepStatus.notStarted;
    final complete = a.carteRemise &&
        a.inscritRegistre &&
        (a.numeroCarte?.isNotEmpty ?? false) &&
        (a.numeroRegistre?.isNotEmpty ?? false);
    return complete ? J0StepStatus.complete : J0StepStatus.inProgress;
  }
}

/// Résumé clinique intelligent de la création J0.
///
/// Agrège la catégorie, la PPE, l'ERIG, le protocole, la synthèse médicale
/// et les points à compléter — uniquement à partir des données déjà saisies.
class J0CreationSummary {
  final CategorieExposition? categorie;
  final bool ppeIndiquee;
  final bool erigIndiquee;
  final String? protocole;
  final String? protocoleDuree;
  final DecisionSynthese synthese;
  final int completedSteps;
  final int totalSteps;
  final List<String> manquants;

  const J0CreationSummary({
    required this.categorie,
    required this.ppeIndiquee,
    required this.erigIndiquee,
    required this.protocole,
    required this.protocoleDuree,
    required this.synthese,
    required this.completedSteps,
    required this.totalSteps,
    required this.manquants,
  });

  factory J0CreationSummary.from(
    InitialRabiesAssessment a,
    PatientAntirabiqueModel? patient,
    List<J0StepData> steps,
    List<J0StepStatus> statuses,
  ) {
    final categorie = patient?.categorieExposition;

    String? protocole;
    String? duree;
    if (a.decision.demarrerEssen) {
      protocole = 'Essen (5 doses)';
      duree = '28 jours';
    } else if (a.decision.demarrerZagreb) {
      protocole = 'Zagreb (2-1-1)';
      duree = '21 jours';
    }

    final manquants = <String>[
      if (a.commune == null || a.commune!.isEmpty) 'Commune',
      if (a.exposition.dateExposition == null ||
          a.exposition.dateExposition!.isEmpty)
        'Date d\'exposition',
      if (a.exposition.localisation == null ||
          a.exposition.localisation!.isEmpty)
        'Siège des lésions',
      if ((a.exposition.especeAnimale == null ||
              a.exposition.especeAnimale!.isEmpty) &&
          (a.animalEspece == null || a.animalEspece!.isEmpty))
        'Espèce de l\'animal',
      if (categorie == CategorieExposition.categorieIII &&
          !a.conduite.immunoglobulinesAEnvisager)
        'ERIG à prévoir (catégorie III)',
      if (a.conduite.vaccinationIndiquee &&
          (a.vaccinLot == null || a.vaccinLot!.isEmpty))
        'Lot du vaccin',
      if (a.carteRemise &&
          (a.numeroCarte == null || a.numeroCarte!.isEmpty))
        'Numéro de la carte de vaccination',
      if (a.inscritRegistre &&
          (a.numeroRegistre == null || a.numeroRegistre!.isEmpty))
        'Numéro de registre',
    ];

    return J0CreationSummary(
      categorie: categorie,
      ppeIndiquee: a.conduite.vaccinationIndiquee,
      erigIndiquee: a.conduite.immunoglobulinesAEnvisager,
      protocole: protocole,
      protocoleDuree: duree,
      synthese: a.synthese,
      completedSteps: statuses
          .where((s) => s == J0StepStatus.complete)
          .length,
      totalSteps: steps.length,
      manquants: manquants,
    );
  }

  double get completionRatio =>
      totalSteps == 0 ? 0 : completedSteps / totalSteps;

  String get prochaineAction {
    switch (synthese) {
      case DecisionSynthese.compatibleDemarrage:
        return 'Démarrer le protocole vaccinal';
      case DecisionSynthese.precautionsComplementaires:
        return 'Précautions complémentaires à vérifier';
      case DecisionSynthese.avisSpecialiseRequis:
        return 'Avis spécialisé requis';
    }
  }
}
