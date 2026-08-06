enum AlerteSeverite { haute, moyenne, basse }

extension AlerteSeveriteX on AlerteSeverite {
  String get label {
    switch (this) {
      case AlerteSeverite.haute:
        return 'Haute';
      case AlerteSeverite.moyenne:
        return 'Moyenne';
      case AlerteSeverite.basse:
        return 'Basse';
    }
  }
}

class DashboardAntirabiqueData {
  final int patientsEnSuivi;
  final int vaccinationsDuJour;
  final int patientsEnRetard;
  final int alertesCritiques;
  final List<AlerteAntirabiqueModel> alertes;
  final List<VaccinationDuJour> vaccinationsDuJourList;
  final RepartitionProtocole repartitionProtocole;

  const DashboardAntirabiqueData({
    required this.patientsEnSuivi,
    required this.vaccinationsDuJour,
    required this.patientsEnRetard,
    required this.alertesCritiques,
    required this.alertes,
    required this.vaccinationsDuJourList,
    required this.repartitionProtocole,
  });
}

class VaccinationDuJour {
  final String patientNom;
  final String protocole;
  final int numeroDose;
  final String statut;

  const VaccinationDuJour({
    required this.patientNom,
    required this.protocole,
    required this.numeroDose,
    this.statut = 'Prévu',
  });
}

class AlerteAntirabiqueModel {
  final String type;
  final String message;
  final AlerteSeverite severite;
  final String? patientNom;

  const AlerteAntirabiqueModel({
    required this.type,
    required this.message,
    required this.severite,
    this.patientNom,
  });
}

class RepartitionProtocole {
  final int essen;
  final int essenReduit;
  final int zagreb;
  final int ipc;

  const RepartitionProtocole({
    required this.essen,
    required this.essenReduit,
    required this.zagreb,
    this.ipc = 0,
  });

  int get total => essen + essenReduit + zagreb + ipc;
  double get pourcentageEssen => total == 0 ? 0 : (essen / total * 100);
  double get pourcentageZagreb => total == 0 ? 0 : (zagreb / total * 100);
}
