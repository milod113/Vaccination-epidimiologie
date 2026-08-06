import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// K — Effets indésirables / MPVI (manifestation post-vaccinale indésirable).
class MpviInfo {
  final bool present;
  final DateTime? dateApparition;
  final String? manifestations;
  final MpviSeverity gravite;
  final String? mesuresPrises;
  final bool declarationPharmacovigilance;

  const MpviInfo({
    this.present = false,
    this.dateApparition,
    this.manifestations,
    this.gravite = MpviSeverity.benigne,
    this.mesuresPrises,
    this.declarationPharmacovigilance = false,
  });

  MpviInfo copyWith({
    bool? present,
    DateTime? dateApparition,
    String? manifestations,
    MpviSeverity? gravite,
    String? mesuresPrises,
    bool? declarationPharmacovigilance,
  }) {
    return MpviInfo(
      present: present ?? this.present,
      dateApparition: dateApparition ?? this.dateApparition,
      manifestations: manifestations ?? this.manifestations,
      gravite: gravite ?? this.gravite,
      mesuresPrises: mesuresPrises ?? this.mesuresPrises,
      declarationPharmacovigilance:
          declarationPharmacovigilance ?? this.declarationPharmacovigilance,
    );
  }

  Map<String, dynamic> toMap() => {
    'present': present,
    'dateApparition': DossierCodec.dateToIso(dateApparition),
    'manifestations': manifestations,
    'gravite': DossierCodec.encodeEnum(gravite),
    'mesuresPrises': mesuresPrises,
    'declarationPharmacovigilance': declarationPharmacovigilance,
  };

  factory MpviInfo.fromMap(Map<String, dynamic> map) => MpviInfo(
    present: DossierCodec.asBool(map['present']),
    dateApparition: DossierCodec.parseDateTime(map['dateApparition']),
    manifestations: map['manifestations'] as String?,
    gravite: DossierCodec.decodeEnum(MpviSeverity.values, map['gravite']) ??
        MpviSeverity.benigne,
    mesuresPrises: map['mesuresPrises'] as String?,
    declarationPharmacovigilance:
        DossierCodec.asBool(map['declarationPharmacovigilance']),
  );
}

/// L — Antibiotiques prescrits.
class AntibioticInfo {
  final AntibioticPrescription prescription;
  final String? molecule;
  final String? dose;
  final String? duree;
  final String? motif;
  final String? observations;

  const AntibioticInfo({
    this.prescription = AntibioticPrescription.nonPrecise,
    this.molecule,
    this.dose,
    this.duree,
    this.motif,
    this.observations,
  });

  AntibioticInfo copyWith({
    AntibioticPrescription? prescription,
    String? molecule,
    String? dose,
    String? duree,
    String? motif,
    String? observations,
  }) {
    return AntibioticInfo(
      prescription: prescription ?? this.prescription,
      molecule: molecule ?? this.molecule,
      dose: dose ?? this.dose,
      duree: duree ?? this.duree,
      motif: motif ?? this.motif,
      observations: observations ?? this.observations,
    );
  }

  bool get estPrescrit => prescription == AntibioticPrescription.oui;

  Map<String, dynamic> toMap() => {
    'prescription': DossierCodec.encodeEnum(prescription),
    'molecule': molecule,
    'dose': dose,
    'duree': duree,
    'motif': motif,
    'observations': observations,
  };

  factory AntibioticInfo.fromMap(Map<String, dynamic> map) => AntibioticInfo(
    prescription:
        DossierCodec.decodeEnum(AntibioticPrescription.values, map['prescription']) ??
            AntibioticPrescription.nonPrecise,
    molecule: map['molecule'] as String?,
    dose: map['dose'] as String?,
    duree: map['duree'] as String?,
    motif: map['motif'] as String?,
    observations: map['observations'] as String?,
  );
}

/// M — Vaccination antidiphtérique-tétanique.
class TetanusVaccination {
  final TetanusVaccinationStatus statut;
  final TetanusVaccineType type;
  final DateTime? dateAdministration;
  final String? observations;

  const TetanusVaccination({
    this.statut = TetanusVaccinationStatus.nonPrecisee,
    this.type = TetanusVaccineType.nonPrecise,
    this.dateAdministration,
    this.observations,
  });

  TetanusVaccination copyWith({
    TetanusVaccinationStatus? statut,
    TetanusVaccineType? type,
    DateTime? dateAdministration,
    String? observations,
  }) {
    return TetanusVaccination(
      statut: statut ?? this.statut,
      type: type ?? this.type,
      dateAdministration: dateAdministration ?? this.dateAdministration,
      observations: observations ?? this.observations,
    );
  }

  bool get estRealisee => statut == TetanusVaccinationStatus.oui;

  Map<String, dynamic> toMap() => {
    'statut': DossierCodec.encodeEnum(statut),
    'type': DossierCodec.encodeEnum(type),
    'dateAdministration': DossierCodec.dateToIso(dateAdministration),
    'observations': observations,
  };

  factory TetanusVaccination.fromMap(Map<String, dynamic> map) =>
      TetanusVaccination(
        statut: DossierCodec.decodeEnum(
                TetanusVaccinationStatus.values, map['statut']) ??
            TetanusVaccinationStatus.nonPrecisee,
        type: DossierCodec.decodeEnum(TetanusVaccineType.values, map['type']) ??
            TetanusVaccineType.nonPrecise,
        dateAdministration:
            DossierCodec.parseDateTime(map['dateAdministration']),
        observations: map['observations'] as String?,
      );
}

/// N — Autres traitements.
class OtherTreatments {
  final bool present;
  final String? description;
  final String? observations;

  const OtherTreatments({
    this.present = false,
    this.description,
    this.observations,
  });

  OtherTreatments copyWith({
    bool? present,
    String? description,
    String? observations,
  }) {
    return OtherTreatments(
      present: present ?? this.present,
      description: description ?? this.description,
      observations: observations ?? this.observations,
    );
  }

  Map<String, dynamic> toMap() => {
    'present': present,
    'description': description,
    'observations': observations,
  };

  factory OtherTreatments.fromMap(Map<String, dynamic> map) => OtherTreatments(
    present: DossierCodec.asBool(map['present']),
    description: map['description'] as String?,
    observations: map['observations'] as String?,
  );
}
