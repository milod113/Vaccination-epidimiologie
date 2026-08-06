import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// Une dose du protocole vaccinal.
class VaccineDose {
  final int numero;
  final String jourTheorique; // J0, J3, J7...
  final DateTime? datePrevue;
  final DateTime? dateReelle;
  final DoseStatus statut;
  final String? numeroLot;
  final AdministrationRoute voie;
  final String? notes;

  const VaccineDose({
    required this.numero,
    this.jourTheorique = '',
    this.datePrevue,
    this.dateReelle,
    this.statut = DoseStatus.prevue,
    this.numeroLot,
    this.voie = AdministrationRoute.intramusculaire,
    this.notes,
  });

  VaccineDose copyWith({
    int? numero,
    String? jourTheorique,
    DateTime? datePrevue,
    DateTime? dateReelle,
    DoseStatus? statut,
    String? numeroLot,
    AdministrationRoute? voie,
    String? notes,
  }) {
    return VaccineDose(
      numero: numero ?? this.numero,
      jourTheorique: jourTheorique ?? this.jourTheorique,
      datePrevue: datePrevue ?? this.datePrevue,
      dateReelle: dateReelle ?? this.dateReelle,
      statut: statut ?? this.statut,
      numeroLot: numeroLot ?? this.numeroLot,
      voie: voie ?? this.voie,
      notes: notes ?? this.notes,
    );
  }

  bool get estRealisee => statut == DoseStatus.realisee;

  String get etiquette => 'Dose $numero · $jourTheorique';

  Map<String, dynamic> toMap() => {
    'numero': numero,
    'jourTheorique': jourTheorique,
    'datePrevue': DossierCodec.dateToIso(datePrevue),
    'dateReelle': DossierCodec.dateToIso(dateReelle),
    'statut': DossierCodec.encodeEnum(statut),
    'numeroLot': numeroLot,
    'voie': DossierCodec.encodeEnum(voie),
    'notes': notes,
  };

  factory VaccineDose.fromMap(Map<String, dynamic> map) => VaccineDose(
    numero: DossierCodec.asInt(map['numero']) ?? 0,
    jourTheorique: map['jourTheorique'] as String? ?? '',
    datePrevue: DossierCodec.parseDateTime(map['datePrevue']),
    dateReelle: DossierCodec.parseDateTime(map['dateReelle']),
    statut: DossierCodec.decodeEnum(DoseStatus.values, map['statut']) ??
        DoseStatus.prevue,
    numeroLot: map['numeroLot'] as String?,
    voie:
        DossierCodec.decodeEnum(AdministrationRoute.values, map['voie']) ??
            AdministrationRoute.intramusculaire,
    notes: map['notes'] as String?,
  );
}

/// J — Sous-modèle protocole vaccinal antirabique.
class VaccinationProtocol {
  final VaccinationProtocolType type;
  final DateTime? dateDebut;
  final List<VaccineDose> doses;
  final bool complete;
  final bool interruption;
  final String? justificationChangement;
  final String? remarques;

  const VaccinationProtocol({
    this.type = VaccinationProtocolType.essen,
    this.dateDebut,
    this.doses = const [],
    this.complete = false,
    this.interruption = false,
    this.justificationChangement,
    this.remarques,
  });

  VaccinationProtocol copyWith({
    VaccinationProtocolType? type,
    DateTime? dateDebut,
    List<VaccineDose>? doses,
    bool? complete,
    bool? interruption,
    String? justificationChangement,
    String? remarques,
  }) {
    return VaccinationProtocol(
      type: type ?? this.type,
      dateDebut: dateDebut ?? this.dateDebut,
      doses: doses ?? this.doses,
      complete: complete ?? this.complete,
      interruption: interruption ?? this.interruption,
      justificationChangement:
          justificationChangement ?? this.justificationChangement,
      remarques: remarques ?? this.remarques,
    );
  }

  int get dosesRealisees => doses.where((d) => d.estRealisee).length;

  int get dosesRestantes => doses.where((d) => !d.estRealisee).length;

  int get totalDoses => doses.length;

  bool get estTermine => doses.isNotEmpty && doses.every((d) => d.estRealisee);

  bool get aRetard => doses.any((d) => d.statut == DoseStatus.enRetard);

  VaccineDose? get prochaineDose {
    final list = doses
        .where((d) => d.statut == DoseStatus.prevue || d.statut == DoseStatus.enRetard)
        .toList()
      ..sort((a, b) => (a.datePrevue ?? DateTime(9999)).compareTo(b.datePrevue ?? DateTime(9999)));
    return list.isEmpty ? null : list.first;
  }

  List<VaccineDose> get dosesEnRetard =>
      doses.where((d) => d.statut == DoseStatus.enRetard).toList();

  Map<String, dynamic> toMap() => {
    'type': DossierCodec.encodeEnum(type),
    'dateDebut': DossierCodec.dateToIso(dateDebut),
    'doses': doses.map((d) => d.toMap()).toList(),
    'complete': complete,
    'interruption': interruption,
    'justificationChangement': justificationChangement,
    'remarques': remarques,
  };

  factory VaccinationProtocol.fromMap(Map<String, dynamic> map) =>
      VaccinationProtocol(
        type: DossierCodec.decodeEnum(VaccinationProtocolType.values, map['type']) ??
            VaccinationProtocolType.essen,
        dateDebut: DossierCodec.parseDateTime(map['dateDebut']),
        doses: (map['doses'] as List? ?? const [])
            .map((e) => VaccineDose.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        complete: DossierCodec.asBool(map['complete']),
        interruption: DossierCodec.asBool(map['interruption']),
        justificationChangement: map['justificationChangement'] as String?,
        remarques: map['remarques'] as String?,
      );
}

/// J — Vaccination antirabique réalisée.
class RabiesVaccination {
  final RabiesVaccineType typeVaccin;
  final String? dci;
  final String? numeroLot;
  final DateTime? datePeremption;
  final double? doseAdministree;
  final AdministrationRoute voie;
  final VaccinationProtocol protocole;

  const RabiesVaccination({
    this.typeVaccin = RabiesVaccineType.non,
    this.dci,
    this.numeroLot,
    this.datePeremption,
    this.doseAdministree,
    this.voie = AdministrationRoute.intramusculaire,
    this.protocole = const VaccinationProtocol(),
  });

  RabiesVaccination copyWith({
    RabiesVaccineType? typeVaccin,
    String? dci,
    String? numeroLot,
    DateTime? datePeremption,
    double? doseAdministree,
    AdministrationRoute? voie,
    VaccinationProtocol? protocole,
  }) {
    return RabiesVaccination(
      typeVaccin: typeVaccin ?? this.typeVaccin,
      dci: dci ?? this.dci,
      numeroLot: numeroLot ?? this.numeroLot,
      datePeremption: datePeremption ?? this.datePeremption,
      doseAdministree: doseAdministree ?? this.doseAdministree,
      voie: voie ?? this.voie,
      protocole: protocole ?? this.protocole,
    );
  }

  bool get vaccinRealise => typeVaccin != RabiesVaccineType.non;

  Map<String, dynamic> toMap() => {
    'typeVaccin': DossierCodec.encodeEnum(typeVaccin),
    'dci': dci,
    'numeroLot': numeroLot,
    'datePeremption': DossierCodec.dateToIso(datePeremption),
    'doseAdministree': doseAdministree,
    'voie': DossierCodec.encodeEnum(voie),
    'protocole': protocole.toMap(),
  };

  factory RabiesVaccination.fromMap(Map<String, dynamic> map) =>
      RabiesVaccination(
        typeVaccin:
            DossierCodec.decodeEnum(RabiesVaccineType.values, map['typeVaccin']) ??
                RabiesVaccineType.non,
        dci: map['dci'] as String?,
        numeroLot: map['numeroLot'] as String?,
        datePeremption: DossierCodec.parseDateTime(map['datePeremption']),
        doseAdministree: DossierCodec.asDouble(map['doseAdministree']),
        voie:
            DossierCodec.decodeEnum(AdministrationRoute.values, map['voie']) ??
                AdministrationRoute.intramusculaire,
        protocole: VaccinationProtocol.fromMap(
            DossierCodec.subMap(map, 'protocole') ?? {}),
      );
}
