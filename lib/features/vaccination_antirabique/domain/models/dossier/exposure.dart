import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// D — Exposition au risque rabique.
class ExposureDetails {
  final DateTime? dateExposition;
  final String? heureExposition; // HH:mm
  final ExposurePlace lieu;
  final bool peauNue; // true = peau nue, false = vêtement interposé
  final ExposureNature nature;
  final BleedingStatus saignement;
  final LesionCountType nombreLesions;
  final int? nombreLesionsValeur;
  final List<LesionSite> siegeLesions;

  const ExposureDetails({
    this.dateExposition,
    this.heureExposition,
    this.lieu = ExposurePlace.horsDomicile,
    this.peauNue = true,
    this.nature = ExposureNature.morsure,
    this.saignement = BleedingStatus.nonPrecise,
    this.nombreLesions = LesionCountType.nonPrecise,
    this.nombreLesionsValeur,
    this.siegeLesions = const [],
  });

  ExposureDetails copyWith({
    DateTime? dateExposition,
    String? heureExposition,
    ExposurePlace? lieu,
    bool? peauNue,
    ExposureNature? nature,
    BleedingStatus? saignement,
    LesionCountType? nombreLesions,
    int? nombreLesionsValeur,
    List<LesionSite>? siegeLesions,
  }) {
    return ExposureDetails(
      dateExposition: dateExposition ?? this.dateExposition,
      heureExposition: heureExposition ?? this.heureExposition,
      lieu: lieu ?? this.lieu,
      peauNue: peauNue ?? this.peauNue,
      nature: nature ?? this.nature,
      saignement: saignement ?? this.saignement,
      nombreLesions: nombreLesions ?? this.nombreLesions,
      nombreLesionsValeur: nombreLesionsValeur ?? this.nombreLesionsValeur,
      siegeLesions: siegeLesions ?? this.siegeLesions,
    );
  }

  bool get aSaignement => saignement == BleedingStatus.oui;

  bool get siegeSevere =>
      siegeLesions.any((s) =>
          s == LesionSite.tete ||
          s == LesionSite.face ||
          s == LesionSite.cou ||
          s == LesionSite.main ||
          s == LesionSite.organesGenitauxExternes);

  Map<String, dynamic> toMap() => {
    'dateExposition': DossierCodec.dateToIso(dateExposition),
    'heureExposition': heureExposition,
    'lieu': DossierCodec.encodeEnum(lieu),
    'peauNue': peauNue,
    'nature': DossierCodec.encodeEnum(nature),
    'saignement': DossierCodec.encodeEnum(saignement),
    'nombreLesions': DossierCodec.encodeEnum(nombreLesions),
    'nombreLesionsValeur': nombreLesionsValeur,
    'siegeLesions': siegeLesions.map(DossierCodec.encodeEnum).toList(),
  };

  factory ExposureDetails.fromMap(Map<String, dynamic> map) => ExposureDetails(
    dateExposition: DossierCodec.parseDateTime(map['dateExposition']),
    heureExposition: map['heureExposition'] as String?,
    lieu: DossierCodec.decodeEnum(ExposurePlace.values, map['lieu']) ??
        ExposurePlace.horsDomicile,
    peauNue: DossierCodec.asBool(map['peauNue'], fallback: true),
    nature: DossierCodec.decodeEnum(ExposureNature.values, map['nature']) ??
        ExposureNature.morsure,
    saignement:
        DossierCodec.decodeEnum(BleedingStatus.values, map['saignement']) ??
            BleedingStatus.nonPrecise,
    nombreLesions:
        DossierCodec.decodeEnum(LesionCountType.values, map['nombreLesions']) ??
            LesionCountType.nonPrecise,
    nombreLesionsValeur: DossierCodec.asInt(map['nombreLesionsValeur']),
    siegeLesions: DossierCodec.decodeEnumList(LesionSite.values, map['siegeLesions']),
  );
}

/// E — Classification du risque rabique.
class RiskClassification {
  final RabiesRiskCategory categorie;
  final String? justification;
  final RiskAssessmentMethod methode;
  final List<FamilyMeasure> mesuresFamiliales;
  final String? precisionMesures;

  const RiskClassification({
    this.categorie = RabiesRiskCategory.categorieII,
    this.justification,
    this.methode = RiskAssessmentMethod.automatique,
    this.mesuresFamiliales = const [],
    this.precisionMesures,
  });

  RiskClassification copyWith({
    RabiesRiskCategory? categorie,
    String? justification,
    RiskAssessmentMethod? methode,
    List<FamilyMeasure>? mesuresFamiliales,
    String? precisionMesures,
  }) {
    return RiskClassification(
      categorie: categorie ?? this.categorie,
      justification: justification ?? this.justification,
      methode: methode ?? this.methode,
      mesuresFamiliales: mesuresFamiliales ?? this.mesuresFamiliales,
      precisionMesures: precisionMesures ?? this.precisionMesures,
    );
  }

  bool get erigIndiquee => categorie.necessiteErig;

  bool get vaccinationIndiquee => categorie.necessiteVaccination;

  Map<String, dynamic> toMap() => {
    'categorie': DossierCodec.encodeEnum(categorie),
    'justification': justification,
    'methode': DossierCodec.encodeEnum(methode),
    'mesuresFamiliales': mesuresFamiliales.map(DossierCodec.encodeEnum).toList(),
    'precisionMesures': precisionMesures,
  };

  factory RiskClassification.fromMap(Map<String, dynamic> map) =>
      RiskClassification(
        categorie:
            DossierCodec.decodeEnum(RabiesRiskCategory.values, map['categorie']) ??
                RabiesRiskCategory.categorieII,
        justification: map['justification'] as String?,
        methode:
            DossierCodec.decodeEnum(RiskAssessmentMethod.values, map['methode']) ??
                RiskAssessmentMethod.automatique,
        mesuresFamiliales:
            DossierCodec.decodeEnumList(FamilyMeasure.values, map['mesuresFamiliales']),
        precisionMesures: map['precisionMesures'] as String?,
      );
}
