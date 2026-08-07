enum TetanusWoundType { propre, aRisque, tetanigene }

extension TetanusWoundTypeX on TetanusWoundType {
  String get label {
    switch (this) {
      case TetanusWoundType.propre:
        return 'Plaie propre';
      case TetanusWoundType.aRisque:
        return 'Plaie à risque';
      case TetanusWoundType.tetanigene:
        return 'Plaie tétanigène';
    }
  }

  String get description {
    switch (this) {
      case TetanusWoundType.propre:
        return 'Plaie superficielle, propre, sans souillure ni corps étranger';
      case TetanusWoundType.aRisque:
        return 'Plaie modérée, contact avec terre/poussière possible';
      case TetanusWoundType.tetanigene:
        return 'Plaie profonde, souillée, avec corps étranger ou nécrose tissulaire';
    }
  }
}

enum TetanusVaccinStatus { aJour, incomplet, inconnu, nonVaccine }

extension TetanusVaccinStatusX on TetanusVaccinStatus {
  String get label {
    switch (this) {
      case TetanusVaccinStatus.aJour:
        return 'À jour';
      case TetanusVaccinStatus.incomplet:
        return 'Incomplet';
      case TetanusVaccinStatus.inconnu:
        return 'Inconnu';
      case TetanusVaccinStatus.nonVaccine:
        return 'Non vacciné';
    }
  }
}

enum TetanusDecision {
  simpleSurveillance,
  rappelIndique,
  vaccinationComplete,
  vaccinationEtIg,
  avisSpecialise,
}

extension TetanusDecisionX on TetanusDecision {
  String get label {
    switch (this) {
      case TetanusDecision.simpleSurveillance:
        return 'Simple surveillance';
      case TetanusDecision.rappelIndique:
        return 'Rappel VAT indiqué';
      case TetanusDecision.vaccinationComplete:
        return 'Vaccination à initier';
      case TetanusDecision.vaccinationEtIg:
        return 'VAT + Immunoglobulines';
      case TetanusDecision.avisSpecialise:
        return 'Avis spécialisé requis';
    }
  }

  String get resume {
    switch (this) {
      case TetanusDecision.simpleSurveillance:
        return 'Patient à jour. Aucun acte nécessaire. Surveillance clinique.';
      case TetanusDecision.rappelIndique:
        return 'Rappel vaccinal VAT indiqué. Administration dès que possible.';
      case TetanusDecision.vaccinationComplete:
        return 'Initier le schéma vaccinal complet VAT.';
      case TetanusDecision.vaccinationEtIg:
        return 'Vaccination VAT + immunoglobulines antitétaniques en urgence.';
      case TetanusDecision.avisSpecialise:
        return 'Contexte complexe. Avis médical spécialisé requis avant décision.';
    }
  }
}

enum TetanusDossierStatut { enCours, acteEffectue, suiviClos, perduDeVue }

extension TetanusDossierStatutX on TetanusDossierStatut {
  String get label {
    switch (this) {
      case TetanusDossierStatut.enCours:
        return 'En cours';
      case TetanusDossierStatut.acteEffectue:
        return 'Acte effectué';
      case TetanusDossierStatut.suiviClos:
        return 'Suivi clos';
      case TetanusDossierStatut.perduDeVue:
        return 'Perdu de vue';
    }
  }
}

/// Nature de l'acte médical enregistré pour un cas tétanique.
enum TetanusActType {
  vaccination,
  serumIg,
  soinsLocaux,
  evaluationMedicale,
  prescription,
  controleSuivi,
  clotureDossier,
}

extension TetanusActTypeX on TetanusActType {
  String get label {
    switch (this) {
      case TetanusActType.vaccination:
        return 'Vaccination antitétanique';
      case TetanusActType.serumIg:
        return 'Sérum / Immunoglobulines';
      case TetanusActType.soinsLocaux:
        return 'Soins locaux';
      case TetanusActType.evaluationMedicale:
        return 'Évaluation médicale';
      case TetanusActType.prescription:
        return 'Prescription médicale';
      case TetanusActType.controleSuivi:
        return 'Contrôle / suivi';
      case TetanusActType.clotureDossier:
        return 'Clôture du dossier';
    }
  }

  String get shortLabel {
    switch (this) {
      case TetanusActType.vaccination:
        return 'Vaccination';
      case TetanusActType.serumIg:
        return 'Sérum / Ig';
      case TetanusActType.soinsLocaux:
        return 'Soins locaux';
      case TetanusActType.evaluationMedicale:
        return 'Évaluation';
      case TetanusActType.prescription:
        return 'Prescription';
      case TetanusActType.controleSuivi:
        return 'Contrôle / suivi';
      case TetanusActType.clotureDossier:
        return 'Clôture';
    }
  }

  String get description {
    switch (this) {
      case TetanusActType.vaccination:
        return 'Administration d\'une dose de vaccin antitétanique (VAT)';
      case TetanusActType.serumIg:
        return 'Immunoglobulines antitétaniques / sérum spécifique';
      case TetanusActType.soinsLocaux:
        return 'Nettoyage, antisepsie ou parage de la plaie';
      case TetanusActType.evaluationMedicale:
        return 'Examen initial ou réévaluation clinique';
      case TetanusActType.prescription:
        return 'Prescription d\'antibiotiques, antalgiques ou autre';
      case TetanusActType.controleSuivi:
        return 'Consultation de contrôle et surveillance clinique';
      case TetanusActType.clotureDossier:
        return 'Conclusion du suivi et clôture du dossier';
    }
  }

  /// Valide si l'acte se rapporte à l'administration d'un produit.
  bool get requiresVaccin => this == TetanusActType.vaccination;
  bool get requiresLot =>
      this == TetanusActType.vaccination || this == TetanusActType.serumIg;
  bool get requiresOrganisation =>
      this == TetanusActType.vaccination || this == TetanusActType.serumIg;
  bool get isClosure => this == TetanusActType.clotureDossier;
}

class TetanusPatientModel {
  final String id;
  final String nomComplet;
  final int age;
  final String sexe;
  final String dateBlessure;
  final TetanusWoundType typePlaie;
  final String localisation;
  final bool plaieProfonde;
  final bool plaieSouillee;
  final bool corpsEtranger;
  final bool soinsLocauxRealises;
  final String delaiConsultation;
  final TetanusVaccinStatus statutVaccinal;
  final String? derniereDoseDate;
  final int? nombreDosesConnues;
  final TetanusDecision decision;
  final TetanusDossierStatut statutDossier;
  final bool immunoglobulines;
  final String? observations;
  final String dateCreation;
  final List<TetanusActeModel> historique;

  const TetanusPatientModel({
    required this.id,
    required this.nomComplet,
    required this.age,
    required this.sexe,
    required this.dateBlessure,
    required this.typePlaie,
    required this.localisation,
    this.plaieProfonde = false,
    this.plaieSouillee = false,
    this.corpsEtranger = false,
    this.soinsLocauxRealises = false,
    this.delaiConsultation = '< 6h',
    required this.statutVaccinal,
    this.derniereDoseDate,
    this.nombreDosesConnues,
    required this.decision,
    this.statutDossier = TetanusDossierStatut.enCours,
    this.immunoglobulines = false,
    this.observations,
    required this.dateCreation,
    this.historique = const [],
  });

  TetanusPatientModel copyWith({
    TetanusDossierStatut? statutDossier,
    bool? immunoglobulines,
    TetanusDecision? decision,
    List<TetanusActeModel>? historique,
  }) {
    return TetanusPatientModel(
      id: id,
      nomComplet: nomComplet,
      age: age,
      sexe: sexe,
      dateBlessure: dateBlessure,
      typePlaie: typePlaie,
      localisation: localisation,
      plaieProfonde: plaieProfonde,
      plaieSouillee: plaieSouillee,
      corpsEtranger: corpsEtranger,
      soinsLocauxRealises: soinsLocauxRealises,
      delaiConsultation: delaiConsultation,
      statutVaccinal: statutVaccinal,
      derniereDoseDate: derniereDoseDate,
      nombreDosesConnues: nombreDosesConnues,
      decision: decision ?? this.decision,
      statutDossier: statutDossier ?? this.statutDossier,
      immunoglobulines: immunoglobulines ?? this.immunoglobulines,
      observations: observations,
      dateCreation: dateCreation,
      historique: historique ?? this.historique,
    );
  }

  bool get estUrgent => decision == TetanusDecision.vaccinationEtIg;
  bool get necessiteIg =>
      typePlaie == TetanusWoundType.tetanigene &&
      statutVaccinal != TetanusVaccinStatus.aJour;
  bool get estRappel => decision == TetanusDecision.rappelIndique;
  bool get plaieTetaniegene => typePlaie == TetanusWoundType.tetanigene;
}

class TetanusActeModel {
  final String id;
  final String patientId;
  final String dateActe;
  final String typeActe;
  final TetanusActType? type;
  final String? vaccin;
  final String? numeroLot;
  final String? dateExpiration;
  final String? administrateur;
  final String? centre;
  final String? observations;
  final String? heureActe;
  final String? voie;
  final String? dose;
  final String? zone;
  final String? role;
  final bool valide;

  const TetanusActeModel({
    required this.id,
    required this.patientId,
    required this.dateActe,
    required this.typeActe,
    this.type,
    this.vaccin,
    this.numeroLot,
    this.dateExpiration,
    this.administrateur,
    this.centre,
    this.observations,
    this.heureActe,
    this.voie,
    this.dose,
    this.zone,
    this.role,
    this.valide = false,
  });
}
