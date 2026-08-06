import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// G — Soins locaux réalisés.
class LocalCareInfo {
  final LocalCarePerformed realise;
  final List<LocalCareMethod> methodes;
  final String? produitsAppliques;
  final String? notes;

  const LocalCareInfo({
    this.realise = LocalCarePerformed.non,
    this.methodes = const [],
    this.produitsAppliques,
    this.notes,
  });

  LocalCareInfo copyWith({
    LocalCarePerformed? realise,
    List<LocalCareMethod>? methodes,
    String? produitsAppliques,
    String? notes,
  }) {
    return LocalCareInfo(
      realise: realise ?? this.realise,
      methodes: methodes ?? this.methodes,
      produitsAppliques: produitsAppliques ?? this.produitsAppliques,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
    'realise': DossierCodec.encodeEnum(realise),
    'methodes': methodes.map(DossierCodec.encodeEnum).toList(),
    'produitsAppliques': produitsAppliques,
    'notes': notes,
  };

  factory LocalCareInfo.fromMap(Map<String, dynamic> map) => LocalCareInfo(
    realise:
        DossierCodec.decodeEnum(LocalCarePerformed.values, map['realise']) ??
            LocalCarePerformed.non,
    methodes:
        DossierCodec.decodeEnumList(LocalCareMethod.values, map['methodes']),
    produitsAppliques: map['produitsAppliques'] as String?,
    notes: map['notes'] as String?,
  );
}

/// H — ERIG / immunoglobulines antirabiques équines.
class ErigInfo {
  final bool indiquee;
  final bool administree;
  final DateTime? date;
  final String? heure; // HH:mm
  final String? numeroLot;
  final DateTime? datePeremption;
  final double? titreIUMl;
  final double? poidsPatientKg;
  final double? doseTotaleTheoriqueIU;
  final double? doseTotaleTheoriqueMl;
  final bool methodeBesredka;
  final bool dilutionRealisee;
  final double? quantiteSerumPhysiologiqueMl;
  final double? quantiteDilueeInfiltreeMl;
  final double? quantiteTotaleInjecteeMl;
  final double? quantiteInjecteeImMl;
  final List<ErigRoute> voies;
  final int? nombreLesionsInfiltrees;
  final bool reactionPostErig;
  final ErigReactionType? typeReaction;
  final String? mesuresReaction;

  const ErigInfo({
    this.indiquee = false,
    this.administree = false,
    this.date,
    this.heure,
    this.numeroLot,
    this.datePeremption,
    this.titreIUMl,
    this.poidsPatientKg,
    this.doseTotaleTheoriqueIU,
    this.doseTotaleTheoriqueMl,
    this.methodeBesredka = false,
    this.dilutionRealisee = false,
    this.quantiteSerumPhysiologiqueMl,
    this.quantiteDilueeInfiltreeMl,
    this.quantiteTotaleInjecteeMl,
    this.quantiteInjecteeImMl,
    this.voies = const [],
    this.nombreLesionsInfiltrees,
    this.reactionPostErig = false,
    this.typeReaction,
    this.mesuresReaction,
  });

  ErigInfo copyWith({
    bool? indiquee,
    bool? administree,
    DateTime? date,
    String? heure,
    String? numeroLot,
    DateTime? datePeremption,
    double? titreIUMl,
    double? poidsPatientKg,
    double? doseTotaleTheoriqueIU,
    double? doseTotaleTheoriqueMl,
    bool? methodeBesredka,
    bool? dilutionRealisee,
    double? quantiteSerumPhysiologiqueMl,
    double? quantiteDilueeInfiltreeMl,
    double? quantiteTotaleInjecteeMl,
    double? quantiteInjecteeImMl,
    List<ErigRoute>? voies,
    int? nombreLesionsInfiltrees,
    bool? reactionPostErig,
    ErigReactionType? typeReaction,
    String? mesuresReaction,
  }) {
    return ErigInfo(
      indiquee: indiquee ?? this.indiquee,
      administree: administree ?? this.administree,
      date: date ?? this.date,
      heure: heure ?? this.heure,
      numeroLot: numeroLot ?? this.numeroLot,
      datePeremption: datePeremption ?? this.datePeremption,
      titreIUMl: titreIUMl ?? this.titreIUMl,
      poidsPatientKg: poidsPatientKg ?? this.poidsPatientKg,
      doseTotaleTheoriqueIU: doseTotaleTheoriqueIU ?? this.doseTotaleTheoriqueIU,
      doseTotaleTheoriqueMl:
          doseTotaleTheoriqueMl ?? this.doseTotaleTheoriqueMl,
      methodeBesredka: methodeBesredka ?? this.methodeBesredka,
      dilutionRealisee: dilutionRealisee ?? this.dilutionRealisee,
      quantiteSerumPhysiologiqueMl:
          quantiteSerumPhysiologiqueMl ?? this.quantiteSerumPhysiologiqueMl,
      quantiteDilueeInfiltreeMl:
          quantiteDilueeInfiltreeMl ?? this.quantiteDilueeInfiltreeMl,
      quantiteTotaleInjecteeMl:
          quantiteTotaleInjecteeMl ?? this.quantiteTotaleInjecteeMl,
      quantiteInjecteeImMl:
          quantiteInjecteeImMl ?? this.quantiteInjecteeImMl,
      voies: voies ?? this.voies,
      nombreLesionsInfiltrees:
          nombreLesionsInfiltrees ?? this.nombreLesionsInfiltrees,
      reactionPostErig: reactionPostErig ?? this.reactionPostErig,
      typeReaction: typeReaction ?? this.typeReaction,
      mesuresReaction: mesuresReaction ?? this.mesuresReaction,
    );
  }

  Map<String, dynamic> toMap() => {
    'indiquee': indiquee,
    'administree': administree,
    'date': DossierCodec.dateToIso(date),
    'heure': heure,
    'numeroLot': numeroLot,
    'datePeremption': DossierCodec.dateToIso(datePeremption),
    'titreIUMl': titreIUMl,
    'poidsPatientKg': poidsPatientKg,
    'doseTotaleTheoriqueIU': doseTotaleTheoriqueIU,
    'doseTotaleTheoriqueMl': doseTotaleTheoriqueMl,
    'methodeBesredka': methodeBesredka,
    'dilutionRealisee': dilutionRealisee,
    'quantiteSerumPhysiologiqueMl': quantiteSerumPhysiologiqueMl,
    'quantiteDilueeInfiltreeMl': quantiteDilueeInfiltreeMl,
    'quantiteTotaleInjecteeMl': quantiteTotaleInjecteeMl,
    'quantiteInjecteeImMl': quantiteInjecteeImMl,
    'voies': voies.map(DossierCodec.encodeEnum).toList(),
    'nombreLesionsInfiltrees': nombreLesionsInfiltrees,
    'reactionPostErig': reactionPostErig,
    'typeReaction': DossierCodec.encodeEnum(typeReaction),
    'mesuresReaction': mesuresReaction,
  };

  factory ErigInfo.fromMap(Map<String, dynamic> map) => ErigInfo(
    indiquee: DossierCodec.asBool(map['indiquee']),
    administree: DossierCodec.asBool(map['administree']),
    date: DossierCodec.parseDateTime(map['date']),
    heure: map['heure'] as String?,
    numeroLot: map['numeroLot'] as String?,
    datePeremption: DossierCodec.parseDateTime(map['datePeremption']),
    titreIUMl: DossierCodec.asDouble(map['titreIUMl']),
    poidsPatientKg: DossierCodec.asDouble(map['poidsPatientKg']),
    doseTotaleTheoriqueIU: DossierCodec.asDouble(map['doseTotaleTheoriqueIU']),
    doseTotaleTheoriqueMl: DossierCodec.asDouble(map['doseTotaleTheoriqueMl']),
    methodeBesredka: DossierCodec.asBool(map['methodeBesredka']),
    dilutionRealisee: DossierCodec.asBool(map['dilutionRealisee']),
    quantiteSerumPhysiologiqueMl:
        DossierCodec.asDouble(map['quantiteSerumPhysiologiqueMl']),
    quantiteDilueeInfiltreeMl:
        DossierCodec.asDouble(map['quantiteDilueeInfiltreeMl']),
    quantiteTotaleInjecteeMl:
        DossierCodec.asDouble(map['quantiteTotaleInjecteeMl']),
    quantiteInjecteeImMl: DossierCodec.asDouble(map['quantiteInjecteeImMl']),
    voies: DossierCodec.decodeEnumList(ErigRoute.values, map['voies']),
    nombreLesionsInfiltrees: DossierCodec.asInt(map['nombreLesionsInfiltrees']),
    reactionPostErig: DossierCodec.asBool(map['reactionPostErig']),
    typeReaction: DossierCodec.decodeEnum(ErigReactionType.values, map['typeReaction']),
    mesuresReaction: map['mesuresReaction'] as String?,
  );
}

/// I — Chirurgie / suture.
class SurgeryInfo {
  final SurgeryPerformed realise;
  final DateTime? date;
  final String? hopital;
  final String? service;
  final SutureTiming suture;

  const SurgeryInfo({
    this.realise = SurgeryPerformed.non,
    this.date,
    this.hopital,
    this.service,
    this.suture = SutureTiming.non,
  });

  SurgeryInfo copyWith({
    SurgeryPerformed? realise,
    DateTime? date,
    String? hopital,
    String? service,
    SutureTiming? suture,
  }) {
    return SurgeryInfo(
      realise: realise ?? this.realise,
      date: date ?? this.date,
      hopital: hopital ?? this.hopital,
      service: service ?? this.service,
      suture: suture ?? this.suture,
    );
  }

  Map<String, dynamic> toMap() => {
    'realise': DossierCodec.encodeEnum(realise),
    'date': DossierCodec.dateToIso(date),
    'hopital': hopital,
    'service': service,
    'suture': DossierCodec.encodeEnum(suture),
  };

  factory SurgeryInfo.fromMap(Map<String, dynamic> map) => SurgeryInfo(
    realise:
        DossierCodec.decodeEnum(SurgeryPerformed.values, map['realise']) ??
            SurgeryPerformed.non,
    date: DossierCodec.parseDateTime(map['date']),
    hopital: map['hopital'] as String?,
    service: map['service'] as String?,
    suture: DossierCodec.decodeEnum(SutureTiming.values, map['suture']) ??
        SutureTiming.non,
  );
}
