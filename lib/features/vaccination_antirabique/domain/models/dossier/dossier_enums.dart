// ---------------------------------------------------------------------------
// Enums métier du dossier antirabique algérien
//
// Chaque enum possède un label français lisible et une valeur de persistance
// (name) utilisée par la sérialisation (voir dossier_codec.dart).
// ---------------------------------------------------------------------------

/// Sexe du patient.
enum PatientGender {
  masculin,
  feminin;

  String get label {
    switch (this) {
      case PatientGender.masculin:
        return 'Masculin';
      case PatientGender.feminin:
        return 'Féminin';
    }
  }
}

/// Niveau d'instruction déclaré du patient.
enum InstructionLevel {
  analphabete,
  primaire,
  moyen,
  secondaire,
  superieur,
  nonPrecise;

  String get label {
    switch (this) {
      case InstructionLevel.analphabete:
        return 'Analphabète';
      case InstructionLevel.primaire:
        return 'Primaire';
      case InstructionLevel.moyen:
        return 'Moyen';
      case InstructionLevel.secondaire:
        return 'Secondaire';
      case InstructionLevel.superieur:
        return 'Supérieur';
      case InstructionLevel.nonPrecise:
        return 'Non précisé';
    }
  }
}

/// Mode d'arrivée du patient à l'UAR.
enum ArrivalMode {
  venuDirectement,
  orienteParStructure;

  String get label {
    switch (this) {
      case ArrivalMode.venuDirectement:
        return 'Venu directement';
      case ArrivalMode.orienteParStructure:
        return 'Orienté par une structure de santé';
    }
  }
}

/// Lieu de l'exposition au risque rabique.
enum ExposurePlace {
  domicile,
  horsDomicile,
  autre;

  String get label {
    switch (this) {
      case ExposurePlace.domicile:
        return 'Domicile';
      case ExposurePlace.horsDomicile:
        return 'Hors domicile';
      case ExposurePlace.autre:
        return 'Autre';
    }
  }
}

/// Nature de l'exposition au virus rabique.
enum ExposureNature {
  contact,
  lechagePeauLestee,
  lechageMuqueuse,
  griffure,
  morsure;

  String get label {
    switch (this) {
      case ExposureNature.contact:
        return 'Contact (affouragement, peau intacte)';
      case ExposureNature.lechagePeauLestee:
        return 'Léchage sur peau lésée';
      case ExposureNature.lechageMuqueuse:
        return 'Léchage sur muqueuse';
      case ExposureNature.griffure:
        return 'Griffure';
      case ExposureNature.morsure:
        return 'Morsure';
    }
  }
}

/// Présence de saignement au niveau des lésions.
enum BleedingStatus {
  oui,
  non,
  nonPrecise;

  String get label {
    switch (this) {
      case BleedingStatus.oui:
        return 'Oui';
      case BleedingStatus.non:
        return 'Non';
      case BleedingStatus.nonPrecise:
        return 'Non précisé';
    }
  }
}

/// Nombre de lésions (qualitatif).
enum LesionCountType {
  unique,
  multiples,
  nonPrecise;

  String get label {
    switch (this) {
      case LesionCountType.unique:
        return 'Lésion unique';
      case LesionCountType.multiples:
        return 'Lésions multiples';
      case LesionCountType.nonPrecise:
        return 'Nombre non précisé';
    }
  }
}

/// Siège des lésions (sélection multiple).
enum LesionSite {
  tete,
  face,
  cou,
  main,
  pied,
  organesGenitauxExternes,
  membreSuperieur,
  membreInferieur,
  tronc,
  nonPrecise;

  String get label {
    switch (this) {
      case LesionSite.tete:
        return 'Tête';
      case LesionSite.face:
        return 'Face';
      case LesionSite.cou:
        return 'Cou';
      case LesionSite.main:
        return 'Main';
      case LesionSite.pied:
        return 'Pied';
      case LesionSite.organesGenitauxExternes:
        return 'Organes génitaux externes';
      case LesionSite.membreSuperieur:
        return 'Membre supérieur';
      case LesionSite.membreInferieur:
        return 'Membre inférieur';
      case LesionSite.tronc:
        return 'Tronc';
      case LesionSite.nonPrecise:
        return 'Non précisé';
    }
  }
}

/// Catégorie / grade rabique (classification OMS).
enum RabiesRiskCategory {
  categorieI,
  categorieII,
  categorieIII;

  String get label {
    switch (this) {
      case RabiesRiskCategory.categorieI:
        return 'Catégorie I';
      case RabiesRiskCategory.categorieII:
        return 'Catégorie II';
      case RabiesRiskCategory.categorieIII:
        return 'Catégorie III';
    }
  }

  String get description {
    switch (this) {
      case RabiesRiskCategory.categorieI:
        return 'Contact/affouragement, peau intacte — pas de vaccination';
      case RabiesRiskCategory.categorieII:
        return 'Morsure/griffure superficielle sans saignement — vaccin seul';
      case RabiesRiskCategory.categorieIII:
        return 'Morsure transdermique, saignement, muqueuse — vaccin + ERIG';
    }
  }

  /// Une exposition de catégorie III requiert des immunoglobulines.
  bool get necessiteErig => this == RabiesRiskCategory.categorieIII;

  /// Une exposition de catégorie I ne requiert aucune vaccination.
  bool get necessiteVaccination => this != RabiesRiskCategory.categorieI;
}

/// Méthode ayant servi à déterminer la catégorie de risque.
enum RiskAssessmentMethod {
  manuelle,
  automatique;

  String get label {
    switch (this) {
      case RiskAssessmentMethod.manuelle:
        return 'Calcul manuel';
      case RiskAssessmentMethod.automatique:
        return 'Calcul automatique';
    }
  }
}

/// Mesures déjà prises par la famille avant l'arrivée à l'UAR.
enum FamilyMeasure {
  lavageEau,
  lavageEauSavon,
  applicationProduit;

  String get label {
    switch (this) {
      case FamilyMeasure.lavageEau:
        return 'Lavage à l\'eau';
      case FamilyMeasure.lavageEauSavon:
        return 'Lavage eau + savon';
      case FamilyMeasure.applicationProduit:
        return 'Application d\'un produit';
    }
  }
}

/// Espèce de l'animal en cause.
enum AnimalSpecies {
  chien,
  chat,
  autre;

  String get label {
    switch (this) {
      case AnimalSpecies.chien:
        return 'Chien';
      case AnimalSpecies.chat:
        return 'Chat';
      case AnimalSpecies.autre:
        return 'Autre';
    }
  }
}

/// Statut de l'animal en cause.
enum AnimalStatus {
  errant,
  semiErrant,
  proprietaire;

  String get label {
    switch (this) {
      case AnimalStatus.errant:
        return 'Errant';
      case AnimalStatus.semiErrant:
        return 'Semi-errant';
      case AnimalStatus.proprietaire:
        return 'Ayant un propriétaire';
    }
  }
}

/// Comportement de l'animal lors de l'incident.
enum AnimalBehavior {
  normal,
  suspect;

  String get label {
    switch (this) {
      case AnimalBehavior.normal:
        return 'Normal';
      case AnimalBehavior.suspect:
        return 'Suspect';
    }
  }
}

/// Vaccination antirabique de l'animal.
enum AnimalVaccinationStatus {
  nonPrecisee,
  non,
  ouiNonDocumentee,
  ouiDocumentee;

  String get label {
    switch (this) {
      case AnimalVaccinationStatus.nonPrecisee:
        return 'Non précisée';
      case AnimalVaccinationStatus.non:
        return 'Non';
      case AnimalVaccinationStatus.ouiNonDocumentee:
        return 'Oui (non documentée)';
      case AnimalVaccinationStatus.ouiDocumentee:
        return 'Oui (documentée)';
    }
  }
}

/// Observation vétérinaire de l'animal.
enum ObservationStatus {
  nonPrecisee,
  non,
  oui;

  String get label {
    switch (this) {
      case ObservationStatus.nonPrecisee:
        return 'Non précisée';
      case ObservationStatus.non:
        return 'Non';
      case ObservationStatus.oui:
        return 'Oui';
    }
  }
}

/// Résultat de l'observation vétérinaire.
enum ObservationResult {
  enrage,
  nonEnrage,
  nonPrecise;

  String get label {
    switch (this) {
      case ObservationResult.enrage:
        return 'Enragé';
      case ObservationResult.nonEnrage:
        return 'Non enragé';
      case ObservationResult.nonPrecise:
        return 'Non précisé';
    }
  }
}

/// Sort de l'animal.
enum AnimalOutcome {
  abattu,
  mort,
  enFuite,
  vivantSousSurveillance;

  String get label {
    switch (this) {
      case AnimalOutcome.abattu:
        return 'Abattu';
      case AnimalOutcome.mort:
        return 'Mort';
      case AnimalOutcome.enFuite:
        return 'En fuite';
      case AnimalOutcome.vivantSousSurveillance:
        return 'Vivant sous surveillance';
    }
  }
}

/// Envoi de la tête de l'animal au laboratoire.
enum HeadLabSend {
  nonPrecise,
  non,
  oui;

  String get label {
    switch (this) {
      case HeadLabSend.nonPrecise:
        return 'Non précisé';
      case HeadLabSend.non:
        return 'Non';
      case HeadLabSend.oui:
        return 'Oui';
    }
  }
}

/// Type d'analyse laboratoire réalisée.
enum LabAnalysisType {
  corpsNegri,
  anticorpsFluorescents,
  inoculationSouris;

  String get label {
    switch (this) {
      case LabAnalysisType.corpsNegri:
        return 'Corps de Negri';
      case LabAnalysisType.anticorpsFluorescents:
        return 'Anticorps fluorescents';
      case LabAnalysisType.inoculationSouris:
        return 'Inoculation à la souris';
    }
  }
}

/// Résultat de l'analyse de laboratoire.
enum LabResultStatus {
  positifAnimalEnrage,
  negatifAnimalNonEnrage,
  enAttente,
  nonDisponible;

  String get label {
    switch (this) {
      case LabResultStatus.positifAnimalEnrage:
        return 'Positif — animal enragé';
      case LabResultStatus.negatifAnimalNonEnrage:
        return 'Négatif — animal non enragé';
      case LabResultStatus.enAttente:
        return 'En attente';
      case LabResultStatus.nonDisponible:
        return 'Non disponible';
    }
  }
}

/// Soins locaux réalisés (oui / non).
enum LocalCarePerformed {
  non,
  oui;

  String get label {
    switch (this) {
      case LocalCarePerformed.non:
        return 'Non';
      case LocalCarePerformed.oui:
        return 'Oui';
    }
  }
}

/// Méthode de soins locaux réalisée.
enum LocalCareMethod {
  lavageEau,
  lavageEauSavon,
  autre;

  String get label {
    switch (this) {
      case LocalCareMethod.lavageEau:
        return 'Lavage à l\'eau';
      case LocalCareMethod.lavageEauSavon:
        return 'Lavage eau + savon';
      case LocalCareMethod.autre:
        return 'Autre méthode';
    }
  }
}

/// Voies d'administration de l'ERIG.
enum ErigRoute {
  infiltrationLesionnelle,
  infiltrationPeriLesionnelle,
  injectionIntramusculaire;

  String get label {
    switch (this) {
      case ErigRoute.infiltrationLesionnelle:
        return 'Infiltration lésionnelle';
      case ErigRoute.infiltrationPeriLesionnelle:
        return 'Infiltration péri-lésionnelle';
      case ErigRoute.injectionIntramusculaire:
        return 'Injection intramusculaire';
    }
  }
}

/// Type de réaction post-ERIG.
enum ErigReactionType {
  chocAnaphylactique,
  reactionBenigne,
  autre;

  String get label {
    switch (this) {
      case ErigReactionType.chocAnaphylactique:
        return 'Choc anaphylactique';
      case ErigReactionType.reactionBenigne:
        return 'Réaction bénigne';
      case ErigReactionType.autre:
        return 'Autre';
    }
  }
}

/// Intervention chirurgicale réalisée.
enum SurgeryPerformed {
  non,
  oui;

  String get label {
    switch (this) {
      case SurgeryPerformed.non:
        return 'Non';
      case SurgeryPerformed.oui:
        return 'Oui';
    }
  }
}

/// Moment de la suture par rapport à l'infiltration ERIG.
enum SutureTiming {
  non,
  avantInfiltrationErig,
  apresInfiltrationErig;

  String get label {
    switch (this) {
      case SutureTiming.non:
        return 'Suture non réalisée';
      case SutureTiming.avantInfiltrationErig:
        return 'Oui, avant infiltration ERIG';
      case SutureTiming.apresInfiltrationErig:
        return 'Oui, après infiltration ERIG';
    }
  }
}

/// Type de vaccin antirabique utilisé.
enum RabiesVaccineType {
  non,
  vaccinTissulaire,
  vaccinCellulaire;

  String get label {
    switch (this) {
      case RabiesVaccineType.non:
        return 'Non';
      case RabiesVaccineType.vaccinTissulaire:
        return 'Vaccin tissulaire';
      case RabiesVaccineType.vaccinCellulaire:
        return 'Vaccin cellulaire';
    }
  }
}

/// Voie d'administration du vaccin.
enum AdministrationRoute {
  sousCutanee,
  intradermique,
  intramusculaire;

  String get label {
    switch (this) {
      case AdministrationRoute.sousCutanee:
        return 'Sous-cutanée';
      case AdministrationRoute.intradermique:
        return 'Intradermique';
      case AdministrationRoute.intramusculaire:
        return 'Intramusculaire';
    }
  }
}

/// Type de protocole vaccinal antirabique.
enum VaccinationProtocolType {
  essen,
  zagreb,
  vaccinTissulaireGradeII,
  vaccinTissulaireGradeIII,
  rappelJ0J3,
  autre;

  String get label {
    switch (this) {
      case VaccinationProtocolType.essen:
        return 'Essen (5 doses)';
      case VaccinationProtocolType.zagreb:
        return 'Zagreb (2-1-1)';
      case VaccinationProtocolType.vaccinTissulaireGradeII:
        return 'Vaccin tissulaire grade II';
      case VaccinationProtocolType.vaccinTissulaireGradeIII:
        return 'Vaccin tissulaire grade III';
      case VaccinationProtocolType.rappelJ0J3:
        return 'Rappel J0/J3';
      case VaccinationProtocolType.autre:
        return 'Autre';
    }
  }
}

/// Statut d'une dose de vaccin.
enum DoseStatus {
  prevue,
  realisee,
  enRetard,
  manquee;

  String get label {
    switch (this) {
      case DoseStatus.prevue:
        return 'Prévue';
      case DoseStatus.realisee:
        return 'Réalisée';
      case DoseStatus.enRetard:
        return 'En retard';
      case DoseStatus.manquee:
        return 'Manquée';
    }
  }
}

/// Gravité d'un effet indésirable / MPVI.
enum MpviSeverity {
  benigne,
  moderee,
  severe;

  String get label {
    switch (this) {
      case MpviSeverity.benigne:
        return 'Bénigne';
      case MpviSeverity.moderee:
        return 'Modérée';
      case MpviSeverity.severe:
        return 'Sévère';
    }
  }
}

/// Prescription d'antibiotiques.
enum AntibioticPrescription {
  nonPrecise,
  non,
  oui;

  String get label {
    switch (this) {
      case AntibioticPrescription.nonPrecise:
        return 'Non précisé';
      case AntibioticPrescription.non:
        return 'Non';
      case AntibioticPrescription.oui:
        return 'Oui';
    }
  }
}

/// Vaccination antidiphtérique-tétanique.
enum TetanusVaccinationStatus {
  nonPrecisee,
  non,
  oui;

  String get label {
    switch (this) {
      case TetanusVaccinationStatus.nonPrecisee:
        return 'Non précisée';
      case TetanusVaccinationStatus.non:
        return 'Non';
      case TetanusVaccinationStatus.oui:
        return 'Oui';
    }
  }
}

/// Type de vaccin antidiphtérique-tétanique.
enum TetanusVaccineType {
  dtPediatrique,
  dtAdulte,
  nonPrecise;

  String get label {
    switch (this) {
      case TetanusVaccineType.dtPediatrique:
        return 'DT pédiatrique';
      case TetanusVaccineType.dtAdulte:
        return 'dT adulte';
      case TetanusVaccineType.nonPrecise:
        return 'Non précisé';
    }
  }
}

/// Statut de remise de carte / inscription au registre.
enum TraceStatus {
  non,
  ouiAvecNumero;

  String get label {
    switch (this) {
      case TraceStatus.non:
        return 'Non';
      case TraceStatus.ouiAvecNumero:
        return 'Oui (avec numéro)';
    }
  }
}

/// Issue finale du dossier.
enum FinalCaseOutcome {
  vaccinationComplete,
  vaccinationIncomplete,
  dossierEnCours,
  abandonne,
  transfere;

  String get label {
    switch (this) {
      case FinalCaseOutcome.vaccinationComplete:
        return 'Vaccination complète';
      case FinalCaseOutcome.vaccinationIncomplete:
        return 'Vaccination incomplète';
      case FinalCaseOutcome.dossierEnCours:
        return 'Dossier en cours';
      case FinalCaseOutcome.abandonne:
        return 'Abandonné';
      case FinalCaseOutcome.transfere:
        return 'Transféré';
    }
  }
}

// ---------------------------------------------------------------------------
// Traçabilité réglementaire
// ---------------------------------------------------------------------------

/// Rôle de l'acteur ayant réalisé ou validé une étape du dossier.
enum ActorRole {
  medecin,
  infirmier,
  agentVaccination,
  secretaire,
  veterinaire,
  administrateur,
  autre;

  String get label {
    switch (this) {
      case ActorRole.medecin:
        return 'Médecin';
      case ActorRole.infirmier:
        return 'Infirmier';
      case ActorRole.agentVaccination:
        return 'Agent de vaccination';
      case ActorRole.secretaire:
        return 'Secrétaire';
      case ActorRole.veterinaire:
        return 'Vétérinaire';
      case ActorRole.administrateur:
        return 'Administrateur';
      case ActorRole.autre:
        return 'Autre';
    }
  }
}

/// Section du dossier concernée par un événement d'historique.
///
/// Aligné sur les sections A à P de la fiche officielle + "dossier".
enum DossierSectionType {
  dossier,
  identite,
  admission,
  exposition,
  classification,
  animal,
  soinsLocaux,
  erig,
  chirurgie,
  vaccination,
  mpvi,
  antibiotiques,
  tetanos,
  autresTraitements,
  tracabilite,
  evolution;

  String get label {
    switch (this) {
      case DossierSectionType.dossier:
        return 'Dossier';
      case DossierSectionType.identite:
        return 'Identité patient';
      case DossierSectionType.admission:
        return 'Admission';
      case DossierSectionType.exposition:
        return 'Exposition';
      case DossierSectionType.classification:
        return 'Classification';
      case DossierSectionType.animal:
        return 'Animal';
      case DossierSectionType.soinsLocaux:
        return 'Soins locaux';
      case DossierSectionType.erig:
        return 'ERIG';
      case DossierSectionType.chirurgie:
        return 'Chirurgie';
      case DossierSectionType.vaccination:
        return 'Vaccination';
      case DossierSectionType.mpvi:
        return 'Effets indésirables';
      case DossierSectionType.antibiotiques:
        return 'Antibiotiques';
      case DossierSectionType.tetanos:
        return 'Vaccination tétanos';
      case DossierSectionType.autresTraitements:
        return 'Autres traitements';
      case DossierSectionType.tracabilite:
        return 'Traçabilité';
      case DossierSectionType.evolution:
        return 'Évolution';
    }
  }
}

/// Type d'action tracée dans l'historique du dossier.
enum DossierHistoryActionType {
  creationDossier,
  evaluationJ0Validee,
  categorieRecalculee,
  protocoleChoisi,
  erigAdministree,
  doseAdministree,
  doseReportee,
  doseManquee,
  mpviEnregistre,
  observationVeterinaireMaj,
  carteRemise,
  registreRenseigne,
  dossierCloture,
  dossierModifie,
  autre;

  String get label {
    switch (this) {
      case DossierHistoryActionType.creationDossier:
        return 'Création du dossier';
      case DossierHistoryActionType.evaluationJ0Validee:
        return 'Fiche J0 validée';
      case DossierHistoryActionType.categorieRecalculee:
        return 'Catégorie clinique déterminée';
      case DossierHistoryActionType.protocoleChoisi:
        return 'Protocole choisi';
      case DossierHistoryActionType.erigAdministree:
        return 'ERIG administrée';
      case DossierHistoryActionType.doseAdministree:
        return 'Dose administrée';
      case DossierHistoryActionType.doseReportee:
        return 'Dose reportée';
      case DossierHistoryActionType.doseManquee:
        return 'Dose manquée';
      case DossierHistoryActionType.mpviEnregistre:
        return 'Effet indésirable enregistré';
      case DossierHistoryActionType.observationVeterinaireMaj:
        return 'Observation vétérinaire mise à jour';
      case DossierHistoryActionType.carteRemise:
        return 'Carte de vaccination remise';
      case DossierHistoryActionType.registreRenseigne:
        return 'Inscription au registre';
      case DossierHistoryActionType.dossierCloture:
        return 'Dossier finalisé';
      case DossierHistoryActionType.dossierModifie:
        return 'Dossier modifié';
      case DossierHistoryActionType.autre:
        return 'Autre';
    }
  }
}

/// Étape de validation réglementaire du parcours antirabique.
enum ValidationStepType {
  ficheJ0,
  categorieClinique,
  erigAdministration,
  vaccinationInitiation,
  doseAdministration,
  effetIndesirable,
  carteVaccination,
  registreInscription,
  dossierCloture;

  String get label {
    switch (this) {
      case ValidationStepType.ficheJ0:
        return 'Fiche J0';
      case ValidationStepType.categorieClinique:
        return 'Catégorie clinique';
      case ValidationStepType.erigAdministration:
        return 'Administration ERIG';
      case ValidationStepType.vaccinationInitiation:
        return 'Initiation vaccinale';
      case ValidationStepType.doseAdministration:
        return 'Administration de dose';
      case ValidationStepType.effetIndesirable:
        return 'Effet indésirable';
      case ValidationStepType.carteVaccination:
        return 'Carte de vaccination';
      case ValidationStepType.registreInscription:
        return 'Inscription au registre';
      case ValidationStepType.dossierCloture:
        return 'Clôture du dossier';
    }
  }
}

/// Statut de validation d'une étape tracée.
enum ValidationStatus {
  validee,
  enCours,
  rejetee,
  annulee;

  String get label {
    switch (this) {
      case ValidationStatus.validee:
        return 'Validée';
      case ValidationStatus.enCours:
        return 'En cours';
      case ValidationStatus.rejetee:
        return 'Rejetée';
      case ValidationStatus.annulee:
        return 'Annulée';
    }
  }
}

/// Statut global de complétude de la traçabilité réglementaire.
enum TraceabilityStatus {
  complete,
  incomplete,
  nonDemarre;

  String get label {
    switch (this) {
      case TraceabilityStatus.complete:
        return 'Traçabilité complète';
      case TraceabilityStatus.incomplete:
        return 'Traçabilité incomplète';
      case TraceabilityStatus.nonDemarre:
        return 'Traçabilité à démarrer';
    }
  }
}
