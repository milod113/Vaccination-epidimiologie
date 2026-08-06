class DoseCertificat {
  final int numeroDose;
  final String dateAdministration;
  final String numeroLot;
  final String administrateur;
  final String voie;

  const DoseCertificat({
    required this.numeroDose,
    required this.dateAdministration,
    required this.numeroLot,
    required this.administrateur,
    this.voie = 'IM',
  });
}

class CertificatModel {
  final String id;
  final String patientId;
  final String patientNom;
  final int patientAge;
  final String dateExposition;
  final String typeExposition;
  final String categorieExposition;
  final String protocole;
  final List<DoseCertificat> doses;
  final bool rigAdministree;
  final String? rigLot;
  final String centre;
  final String medecinResponsable;
  final String dateEmission;
  final String? observations;

  const CertificatModel({
    required this.id,
    required this.patientId,
    required this.patientNom,
    required this.patientAge,
    required this.dateExposition,
    required this.typeExposition,
    required this.categorieExposition,
    required this.protocole,
    required this.doses,
    this.rigAdministree = false,
    this.rigLot,
    this.centre = 'Centre Antirabique',
    this.medecinResponsable = 'Dr. ',
    required this.dateEmission,
    this.observations,
  });

  bool get estComplet => doses.every((d) => d.dateAdministration.isNotEmpty);
}
