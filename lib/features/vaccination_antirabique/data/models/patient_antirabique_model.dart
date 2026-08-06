enum CategorieExposition {
  categorieI,
  categorieII,
  categorieIII,
}

extension CategorieExpositionX on CategorieExposition {
  String get label {
    switch (this) {
      case CategorieExposition.categorieI:
        return 'Catégorie I';
      case CategorieExposition.categorieII:
        return 'Catégorie II';
      case CategorieExposition.categorieIII:
        return 'Catégorie III';
    }
  }

  String get description {
    switch (this) {
      case CategorieExposition.categorieI:
        return 'Contact/affouragement, peau intacte — pas de vaccination';
      case CategorieExposition.categorieII:
        return 'Morsure/griffure modérée, peau non intacte — vaccin seul';
      case CategorieExposition.categorieIII:
        return 'Morsure profonde, contamination muqueuse/plaie — vaccin + Ig';
    }
  }

  bool get necessiteRIG => this == CategorieExposition.categorieIII;
}

enum TypeExposition {
  morsureChien,
  morsureChat,
  morsureAutreAnimal,
  griffure,
  contactMuqueux,
  professionnelle,
}

extension TypeExpositionX on TypeExposition {
  String get label {
    switch (this) {
      case TypeExposition.morsureChien:
        return 'Morsure de chien';
      case TypeExposition.morsureChat:
        return 'Morsure de chat';
      case TypeExposition.morsureAutreAnimal:
        return 'Morsure autre animal';
      case TypeExposition.griffure:
        return 'Griffure';
      case TypeExposition.contactMuqueux:
        return 'Contact muqueux';
      case TypeExposition.professionnelle:
        return 'Exposition professionnelle';
    }
  }
}

enum ProtocoleType { essen, essenReduit, zagreb, ipc }

extension ProtocoleTypeX on ProtocoleType {
  String get label {
    switch (this) {
      case ProtocoleType.essen:
        return 'Essen (5 doses)';
      case ProtocoleType.essenReduit:
        return 'Essen réduit (4 doses)';
      case ProtocoleType.zagreb:
        return 'Zagreb (2-1-1)';
      case ProtocoleType.ipc:
        return 'IPC (ID)';
    }
  }

  String get description {
    switch (this) {
      case ProtocoleType.essen:
        return 'Schéma Essen IM : 1 dose à J0, J3, J7, J14, J28 — 5 doses, 5 visites, 28 jours. Recommandé pour patients immunodéprimés.';
      case ProtocoleType.essenReduit:
        return 'Schéma Essen réduit IM (OMS 2018) : 1 dose à J0, J3, J7, J14-28 — 4 doses, 4 visites. Pour immunocompétents.';
      case ProtocoleType.zagreb:
        return 'Schéma Zagreb IM (2-1-1) : 2 doses à J0 (1/site), puis 1 dose à J7 et J21 — 4 doses, 3 visites, 21 jours.';
      case ProtocoleType.ipc:
        return 'Schéma IPC ID (Institut Pasteur Cambodge) : 2 sites ID à J0, J3, J7 — 6 doses fractionnées, 3 visites, 7 jours.';
    }
  }

  int get totalDoses {
    switch (this) {
      case ProtocoleType.essen:
        return 5;
      case ProtocoleType.essenReduit:
        return 4;
      case ProtocoleType.zagreb:
        return 4;
      case ProtocoleType.ipc:
        return 6;
    }
  }

  int get nombreVisites {
    switch (this) {
      case ProtocoleType.essen:
        return 5;
      case ProtocoleType.essenReduit:
        return 4;
      case ProtocoleType.zagreb:
        return 3;
      case ProtocoleType.ipc:
        return 3;
    }
  }

  String get duree {
    switch (this) {
      case ProtocoleType.essen:
        return '28 jours';
      case ProtocoleType.essenReduit:
        return '14-28 jours';
      case ProtocoleType.zagreb:
        return '21 jours';
      case ProtocoleType.ipc:
        return '7 jours';
    }
  }
}

enum StatutSuivi {
  enCours,
  termine,
  perduDeVue,
  transfere,
}

extension StatutSuiviX on StatutSuivi {
  String get label {
    switch (this) {
      case StatutSuivi.enCours:
        return 'En cours';
      case StatutSuivi.termine:
        return 'Terminé';
      case StatutSuivi.perduDeVue:
        return 'Perdu de vue';
      case StatutSuivi.transfere:
        return 'Transféré';
    }
  }
}

enum AnimauxStatut { inconnu, suspect, confirme, observeSurveillance, vaccine }

extension AnimauxStatutX on AnimauxStatut {
  String get label {
    switch (this) {
      case AnimauxStatut.inconnu:
        return 'Inconnu';
      case AnimauxStatut.suspect:
        return 'Suspect';
      case AnimauxStatut.confirme:
        return 'Rage confirmée';
      case AnimauxStatut.observeSurveillance:
        return 'En observation';
      case AnimauxStatut.vaccine:
        return 'Vacciné';
    }
  }
}

class PatientAntirabiqueModel {
  final String id;
  final String nomComplet;

  /// Prénom isolé (facultatif) — `nomComplet` reste la référence d'affichage.
  final String? prenom;
  final int age;
  final String sexe;
  final double? poids;
  final String? telephone;
  final String dateExposition;

  /// Exposition / décision clinique — `null` tant que l'évaluation J0
  /// n'a pas été réalisée (patient admis en attente d'évaluation).
  final TypeExposition? typeExposition;
  final CategorieExposition? categorieExposition;
  final ProtocoleType? protocole;
  final StatutSuivi statut;
  final String? prochainRendezVous;

  /// Adresse de résidence.
  final String? adresse;
  final String? commune;
  final String? daira;
  final String? wilaya;

  /// Contexte d'admission.
  final String? dateAdmission;
  final String? heureAdmission;
  final String? modeArrivee;
  final String? structureOrientation;
  final String? dateCreation;

  final String? animalSource;
  final AnimauxStatut animalStatut;
  final bool animalCapture;
  final bool immunocompromis;
  final bool rigAdministree;
  final String? siteMorsure;
  final String? observations;

  const PatientAntirabiqueModel({
    required this.id,
    required this.nomComplet,
    required this.age,
    required this.sexe,
    this.prenom,
    this.poids,
    this.telephone,
    required this.dateExposition,
    this.typeExposition,
    this.categorieExposition,
    this.protocole,
    this.statut = StatutSuivi.enCours,
    this.prochainRendezVous,
    this.adresse,
    this.commune,
    this.daira,
    this.wilaya,
    this.dateAdmission,
    this.heureAdmission,
    this.modeArrivee,
    this.structureOrientation,
    this.dateCreation,
    this.animalSource,
    this.animalStatut = AnimauxStatut.inconnu,
    this.animalCapture = false,
    this.immunocompromis = false,
    this.rigAdministree = false,
    this.siteMorsure,
    this.observations,
  });

  /// Patient admis mais dont l'exposition n'est pas encore évaluée (J0).
  bool get enAttenteEvaluation =>
      typeExposition == null || categorieExposition == null;

  bool get necessiteRIG => categorieExposition?.necessiteRIG ?? false;

  PatientAntirabiqueModel copyWith({
    String? id,
    String? nomComplet,
    String? prenom,
    int? age,
    String? sexe,
    double? poids,
    String? telephone,
    String? dateExposition,
    TypeExposition? typeExposition,
    CategorieExposition? categorieExposition,
    ProtocoleType? protocole,
    StatutSuivi? statut,
    String? prochainRendezVous,
    String? adresse,
    String? commune,
    String? daira,
    String? wilaya,
    String? dateAdmission,
    String? heureAdmission,
    String? modeArrivee,
    String? structureOrientation,
    String? dateCreation,
    String? animalSource,
    AnimauxStatut? animalStatut,
    bool? animalCapture,
    bool? immunocompromis,
    bool? rigAdministree,
    String? siteMorsure,
    String? observations,
  }) {
    return PatientAntirabiqueModel(
      id: id ?? this.id,
      nomComplet: nomComplet ?? this.nomComplet,
      prenom: prenom ?? this.prenom,
      age: age ?? this.age,
      sexe: sexe ?? this.sexe,
      poids: poids ?? this.poids,
      telephone: telephone ?? this.telephone,
      dateExposition: dateExposition ?? this.dateExposition,
      typeExposition: typeExposition ?? this.typeExposition,
      categorieExposition: categorieExposition ?? this.categorieExposition,
      protocole: protocole ?? this.protocole,
      statut: statut ?? this.statut,
      prochainRendezVous: prochainRendezVous ?? this.prochainRendezVous,
      adresse: adresse ?? this.adresse,
      commune: commune ?? this.commune,
      daira: daira ?? this.daira,
      wilaya: wilaya ?? this.wilaya,
      dateAdmission: dateAdmission ?? this.dateAdmission,
      heureAdmission: heureAdmission ?? this.heureAdmission,
      modeArrivee: modeArrivee ?? this.modeArrivee,
      structureOrientation: structureOrientation ?? this.structureOrientation,
      dateCreation: dateCreation ?? this.dateCreation,
      animalSource: animalSource ?? this.animalSource,
      animalStatut: animalStatut ?? this.animalStatut,
      animalCapture: animalCapture ?? this.animalCapture,
      immunocompromis: immunocompromis ?? this.immunocompromis,
      rigAdministree: rigAdministree ?? this.rigAdministree,
      siteMorsure: siteMorsure ?? this.siteMorsure,
      observations: observations ?? this.observations,
    );
  }
}
