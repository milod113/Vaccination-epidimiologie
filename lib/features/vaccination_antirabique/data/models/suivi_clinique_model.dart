enum EffetIndesirableType {
  aucun,
  local,
  general,
  grave,
}

extension EffetIndesirableTypeX on EffetIndesirableType {
  String get label {
    switch (this) {
      case EffetIndesirableType.aucun:
        return 'Aucun';
      case EffetIndesirableType.local:
        return 'Local (douleur, rougeur, œdème)';
      case EffetIndesirableType.general:
        return 'Général (fièvre, céphalées, myalgies)';
      case EffetIndesirableType.grave:
        return 'Grave (réaction anaphylactique, neurologique)';
    }
  }
}

class SuiviCliniqueModel {
  final String id;
  final String patientId;
  final String date;
  final String auteur;
  final String note;
  final EffetIndesirableType effetIndesirable;
  final String? descriptionEffet;
  final bool doseReportee;
  final String? motifReport;
  final String? dateNouveauRdv;

  const SuiviCliniqueModel({
    required this.id,
    required this.patientId,
    required this.date,
    required this.auteur,
    required this.note,
    this.effetIndesirable = EffetIndesirableType.aucun,
    this.descriptionEffet,
    this.doseReportee = false,
    this.motifReport,
    this.dateNouveauRdv,
  });
}
