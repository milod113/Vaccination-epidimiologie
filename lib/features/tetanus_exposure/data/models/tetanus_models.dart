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

  bool get estUrgent => decision == TetanusDecision.vaccinationEtIg;
  bool get necessiteIg => typePlaie == TetanusWoundType.tetanigene && statutVaccinal != TetanusVaccinStatus.aJour;
  bool get estRappel => decision == TetanusDecision.rappelIndique;
  bool get plaieTetaniegene => typePlaie == TetanusWoundType.tetanigene;
}

class TetanusActeModel {
  final String id;
  final String patientId;
  final String dateActe;
  final String typeActe;
  final String? vaccin;
  final String? numeroLot;
  final String? dateExpiration;
  final String? administrateur;
  final String? centre;
  final String? observations;

  const TetanusActeModel({
    required this.id,
    required this.patientId,
    required this.dateActe,
    required this.typeActe,
    this.vaccin,
    this.numeroLot,
    this.dateExpiration,
    this.administrateur,
    this.centre,
    this.observations,
  });
}
