import 'package:flutter/material.dart';
import '../../../../core/theme/epidemiology_theme.dart';

enum HepBExposureType {
  aes,
  contactSanguin,
  mereAgHbsPlus,
  sexuelle,
  autre;

  String get label {
    switch (this) {
      case HepBExposureType.aes:
        return 'AES';
      case HepBExposureType.contactSanguin:
        return 'Contact sanguin';
      case HepBExposureType.mereAgHbsPlus:
        return 'Mère Ag HBs+';
      case HepBExposureType.sexuelle:
        return 'Exposition sexuelle';
      case HepBExposureType.autre:
        return 'Autre';
    }
  }
}

enum HepBVaccinationStatus {
  vaccineReponseConnue,
  vaccineReponseInconnue,
  vaccineIncomplet,
  nonVaccine,
  inconnu;

  String get label {
    switch (this) {
      case HepBVaccinationStatus.vaccineReponseConnue:
        return 'Vacciné (réponse +)';
      case HepBVaccinationStatus.vaccineReponseInconnue:
        return 'Vacciné (réponse ?)';
      case HepBVaccinationStatus.vaccineIncomplet:
        return 'Vacciné incomplet';
      case HepBVaccinationStatus.nonVaccine:
        return 'Non vacciné';
      case HepBVaccinationStatus.inconnu:
        return 'Statut inconnu';
    }
  }

  Color get color {
    switch (this) {
      case HepBVaccinationStatus.vaccineReponseConnue:
        return EpidemiologyTheme.success;
      case HepBVaccinationStatus.vaccineReponseInconnue:
        return EpidemiologyTheme.warning;
      case HepBVaccinationStatus.vaccineIncomplet:
        return EpidemiologyTheme.warning;
      case HepBVaccinationStatus.nonVaccine:
        return EpidemiologyTheme.danger;
      case HepBVaccinationStatus.inconnu:
        return EpidemiologyTheme.warm400;
    }
  }
}

enum HepBSerologyStatus {
  enAttente,
  negatif,
  immunise,
  infecte,
  nonEffectue;

  String get label {
    switch (this) {
      case HepBSerologyStatus.enAttente:
        return 'En attente';
      case HepBSerologyStatus.negatif:
        return 'Négatif';
      case HepBSerologyStatus.immunise:
        return 'Immunisé';
      case HepBSerologyStatus.infecte:
        return 'Infecté (VHB)';
      case HepBSerologyStatus.nonEffectue:
        return 'Non effectué';
    }
  }

  Color get color {
    switch (this) {
      case HepBSerologyStatus.enAttente:
        return EpidemiologyTheme.warning;
      case HepBSerologyStatus.negatif:
        return EpidemiologyTheme.info;
      case HepBSerologyStatus.immunise:
        return EpidemiologyTheme.success;
      case HepBSerologyStatus.infecte:
        return EpidemiologyTheme.danger;
      case HepBSerologyStatus.nonEffectue:
        return EpidemiologyTheme.warm300;
    }
  }
}

enum HepBRiskLevel {
  standard,
  eleve,
  urgent;

  String get label {
    switch (this) {
      case HepBRiskLevel.standard:
        return 'Standard';
      case HepBRiskLevel.eleve:
        return 'Élevé';
      case HepBRiskLevel.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case HepBRiskLevel.standard:
        return EpidemiologyTheme.info;
      case HepBRiskLevel.eleve:
        return EpidemiologyTheme.warning;
      case HepBRiskLevel.urgent:
        return EpidemiologyTheme.danger;
    }
  }
}

enum HepBDoseStatus {
  planifie,
  administre,
  enRetard,
  nonRequi;

  String get label {
    switch (this) {
      case HepBDoseStatus.planifie:
        return 'Planifié';
      case HepBDoseStatus.administre:
        return 'Administré';
      case HepBDoseStatus.enRetard:
        return 'En retard';
      case HepBDoseStatus.nonRequi:
        return 'Non requis';
    }
  }

  Color get color {
    switch (this) {
      case HepBDoseStatus.planifie:
        return EpidemiologyTheme.info;
      case HepBDoseStatus.administre:
        return EpidemiologyTheme.success;
      case HepBDoseStatus.enRetard:
        return EpidemiologyTheme.danger;
      case HepBDoseStatus.nonRequi:
        return EpidemiologyTheme.warm300;
    }
  }

  IconData get icon {
    switch (this) {
      case HepBDoseStatus.planifie:
        return Icons.schedule;
      case HepBDoseStatus.administre:
        return Icons.check_circle;
      case HepBDoseStatus.enRetard:
        return Icons.warning_amber_rounded;
      case HepBDoseStatus.nonRequi:
        return Icons.remove_circle_outline;
    }
  }
}

enum HepBDossierStatut {
  enCours,
  suiviTermine,
  perduDeVue;

  String get label {
    switch (this) {
      case HepBDossierStatut.enCours:
        return 'En cours';
      case HepBDossierStatut.suiviTermine:
        return 'Suivi terminé';
      case HepBDossierStatut.perduDeVue:
        return 'Perdu de vue';
    }
  }

  Color get color {
    switch (this) {
      case HepBDossierStatut.enCours:
        return EpidemiologyTheme.info;
      case HepBDossierStatut.suiviTermine:
        return EpidemiologyTheme.success;
      case HepBDossierStatut.perduDeVue:
        return EpidemiologyTheme.warm400;
    }
  }
}

class HepBDose {
  final int numero;
  final String produit;
  final DateTime? dateAdministration;
  final HepBDoseStatus statut;
  final String? notes;

  const HepBDose({
    required this.numero,
    this.produit = 'Vaccin VHB',
    this.dateAdministration,
    this.statut = HepBDoseStatus.planifie,
    this.notes,
  });
}

class HepBSerologie {
  final DateTime? datePrelevement;
  final String agHbs;
  final String acAntiHbs;
  final String acAntiHbc;
  final String interpretation;
  final bool fait;

  const HepBSerologie({
    this.datePrelevement,
    this.agHbs = '',
    this.acAntiHbs = '',
    this.acAntiHbc = '',
    this.interpretation = '',
    this.fait = false,
  });
}

class HepBExposurePatient {
  final String id;
  final String nom;
  final String prenom;
  final int age;
  final HepBExposureType typeExposition;
  final DateTime dateExposition;
  final String sourceExposition;
  final HepBVaccinationStatus statutVaccinal;
  final HepBSerologie serologieInitiale;
  final HepBSerologie serologieM1;
  final HepBSerologie serologieM3;
  final HepBRiskLevel niveauRisque;
  final String decision;
  final String prochaineAction;
  final List<HepBDose> doses;
  final HepBDossierStatut statutDossier;
  final DateTime? dateCreation;

  const HepBExposurePatient({
    required this.id,
    required this.nom,
    required this.prenom,
    this.age = 30,
    required this.typeExposition,
    required this.dateExposition,
    this.sourceExposition = '',
    required this.statutVaccinal,
    this.serologieInitiale = const HepBSerologie(),
    this.serologieM1 = const HepBSerologie(),
    this.serologieM3 = const HepBSerologie(),
    this.niveauRisque = HepBRiskLevel.standard,
    this.decision = '',
    this.prochaineAction = '',
    this.doses = const [],
    this.statutDossier = HepBDossierStatut.enCours,
    this.dateCreation,
  });

  String get nomComplet => '$prenom $nom';

  int get joursDepuisExposition =>
      DateTime.now().difference(dateExposition).inDays;

  bool get serologieEnAttente =>
      !serologieInitiale.fait || !serologieM1.fait || !serologieM3.fait;

  int get dosesPlanifiees =>
      doses.where((d) => d.statut == HepBDoseStatus.planifie).length;

  int get dosesAdministrees =>
      doses.where((d) => d.statut == HepBDoseStatus.administre).length;

  int get dosesEnRetard =>
      doses.where((d) => d.statut == HepBDoseStatus.enRetard).length;
}
