enum TravelVaccinationStatus {
  planifie,
  administre,
  enRetard,
  nonRequis;

  String get label {
    switch (this) {
      case TravelVaccinationStatus.planifie:
        return 'Planifié';
      case TravelVaccinationStatus.administre:
        return 'Administré';
      case TravelVaccinationStatus.enRetard:
        return 'En retard';
      case TravelVaccinationStatus.nonRequis:
        return 'Non requis';
    }
  }
}

enum TravelAlertLevel {
  info,
  warning,
  urgent;

  String get label {
    switch (this) {
      case TravelAlertLevel.info:
        return 'Info';
      case TravelAlertLevel.warning:
        return 'Alerte';
      case TravelAlertLevel.urgent:
        return 'Urgent';
    }
  }
}

class VaccinRecommandation {
  final String nom;
  final bool obligatoire;
  final TravelVaccinationStatus statut;
  final String? notes;

  const VaccinRecommandation({
    required this.nom,
    this.obligatoire = false,
    this.statut = TravelVaccinationStatus.nonRequis,
    this.notes,
  });
}

class TravelPatient {
  final String nom;
  final String prenom;
  final String destination;
  final String region;
  final DateTime depart;
  final List<VaccinRecommandation> vaccins;
  final String? conseils;

  const TravelPatient({
    required this.nom,
    required this.prenom,
    required this.destination,
    required this.region,
    required this.depart,
    required this.vaccins,
    this.conseils,
  });

  String get nomComplet => '$prenom $nom';

  int get joursRestants => DateTime.now().isBefore(depart)
      ? depart.difference(DateTime.now()).inDays
      : 0;

  bool get estUrgent => joursRestants > 0 && joursRestants <= 7;

  bool get estProche => joursRestants > 0 && joursRestants <= 14;

  int get vaccinsPlanifies =>
      vaccins.where((v) => v.statut == TravelVaccinationStatus.planifie).length;

  int get vaccinsAdministres =>
      vaccins.where((v) => v.statut == TravelVaccinationStatus.administre).length;

  int get vaccinsEnRetard =>
      vaccins.where((v) => v.statut == TravelVaccinationStatus.enRetard).length;

  int get vaccinsNonRequis =>
      vaccins.where((v) => v.statut == TravelVaccinationStatus.nonRequis).length;
}

class DestinationInfo {
  final String pays;
  final String region;
  final List<String> vaccinsRecommandes;
  final List<String> vaccinsObligatoires;
  final TravelAlertLevel niveauAlerte;
  final String? messageAlerte;

  const DestinationInfo({
    required this.pays,
    required this.region,
    required this.vaccinsRecommandes,
    this.vaccinsObligatoires = const [],
    this.niveauAlerte = TravelAlertLevel.info,
    this.messageAlerte,
  });
}
