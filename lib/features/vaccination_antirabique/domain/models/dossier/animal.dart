import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// F — Animal en cause.
class AnimalInfo {
  final AnimalSpecies espece;
  final String? autreEspecePrecision;
  final String? couleurPelage;
  final AnimalStatus statut;
  final String? proprietaireNom;
  final AnimalBehavior comportement;
  final AnimalVaccinationStatus vaccination;
  final DateTime? dateVaccination;
  final ObservationStatus observationVeterinaire;
  final DateTime? debutObservation;
  final DateTime? finObservation;
  final ObservationResult resultatObservation;
  final AnimalOutcome sort;
  final HeadLabSend envoiTeteLabo;
  final LabAnalysisType? typeAnalyse;
  final DateTime? dateAnalyse;
  final LabResultStatus resultatLabo;

  const AnimalInfo({
    this.espece = AnimalSpecies.chien,
    this.autreEspecePrecision,
    this.couleurPelage,
    this.statut = AnimalStatus.errant,
    this.proprietaireNom,
    this.comportement = AnimalBehavior.normal,
    this.vaccination = AnimalVaccinationStatus.nonPrecisee,
    this.dateVaccination,
    this.observationVeterinaire = ObservationStatus.nonPrecisee,
    this.debutObservation,
    this.finObservation,
    this.resultatObservation = ObservationResult.nonPrecise,
    this.sort = AnimalOutcome.enFuite,
    this.envoiTeteLabo = HeadLabSend.nonPrecise,
    this.typeAnalyse,
    this.dateAnalyse,
    this.resultatLabo = LabResultStatus.nonDisponible,
  });

  AnimalInfo copyWith({
    AnimalSpecies? espece,
    String? autreEspecePrecision,
    String? couleurPelage,
    AnimalStatus? statut,
    String? proprietaireNom,
    AnimalBehavior? comportement,
    AnimalVaccinationStatus? vaccination,
    DateTime? dateVaccination,
    ObservationStatus? observationVeterinaire,
    DateTime? debutObservation,
    DateTime? finObservation,
    ObservationResult? resultatObservation,
    AnimalOutcome? sort,
    HeadLabSend? envoiTeteLabo,
    LabAnalysisType? typeAnalyse,
    DateTime? dateAnalyse,
    LabResultStatus? resultatLabo,
  }) {
    return AnimalInfo(
      espece: espece ?? this.espece,
      autreEspecePrecision: autreEspecePrecision ?? this.autreEspecePrecision,
      couleurPelage: couleurPelage ?? this.couleurPelage,
      statut: statut ?? this.statut,
      proprietaireNom: proprietaireNom ?? this.proprietaireNom,
      comportement: comportement ?? this.comportement,
      vaccination: vaccination ?? this.vaccination,
      dateVaccination: dateVaccination ?? this.dateVaccination,
      observationVeterinaire:
          observationVeterinaire ?? this.observationVeterinaire,
      debutObservation: debutObservation ?? this.debutObservation,
      finObservation: finObservation ?? this.finObservation,
      resultatObservation: resultatObservation ?? this.resultatObservation,
      sort: sort ?? this.sort,
      envoiTeteLabo: envoiTeteLabo ?? this.envoiTeteLabo,
      typeAnalyse: typeAnalyse ?? this.typeAnalyse,
      dateAnalyse: dateAnalyse ?? this.dateAnalyse,
      resultatLabo: resultatLabo ?? this.resultatLabo,
    );
  }

  bool get estObservable =>
      observationVeterinaire == ObservationStatus.oui ||
      sort == AnimalOutcome.vivantSousSurveillance;

  bool get animalEnrageConfirme =>
      resultatLabo == LabResultStatus.positifAnimalEnrage ||
      resultatObservation == ObservationResult.enrage;

  Map<String, dynamic> toMap() => {
    'espece': DossierCodec.encodeEnum(espece),
    'autreEspecePrecision': autreEspecePrecision,
    'couleurPelage': couleurPelage,
    'statut': DossierCodec.encodeEnum(statut),
    'proprietaireNom': proprietaireNom,
    'comportement': DossierCodec.encodeEnum(comportement),
    'vaccination': DossierCodec.encodeEnum(vaccination),
    'dateVaccination': DossierCodec.dateToIso(dateVaccination),
    'observationVeterinaire': DossierCodec.encodeEnum(observationVeterinaire),
    'debutObservation': DossierCodec.dateToIso(debutObservation),
    'finObservation': DossierCodec.dateToIso(finObservation),
    'resultatObservation': DossierCodec.encodeEnum(resultatObservation),
    'sort': DossierCodec.encodeEnum(sort),
    'envoiTeteLabo': DossierCodec.encodeEnum(envoiTeteLabo),
    'typeAnalyse': DossierCodec.encodeEnum(typeAnalyse),
    'dateAnalyse': DossierCodec.dateToIso(dateAnalyse),
    'resultatLabo': DossierCodec.encodeEnum(resultatLabo),
  };

  factory AnimalInfo.fromMap(Map<String, dynamic> map) => AnimalInfo(
    espece: DossierCodec.decodeEnum(AnimalSpecies.values, map['espece']) ??
        AnimalSpecies.chien,
    autreEspecePrecision: map['autreEspecePrecision'] as String?,
    couleurPelage: map['couleurPelage'] as String?,
    statut: DossierCodec.decodeEnum(AnimalStatus.values, map['statut']) ??
        AnimalStatus.errant,
    proprietaireNom: map['proprietaireNom'] as String?,
    comportement:
        DossierCodec.decodeEnum(AnimalBehavior.values, map['comportement']) ??
            AnimalBehavior.normal,
    vaccination: DossierCodec.decodeEnum(
        AnimalVaccinationStatus.values, map['vaccination']) ??
        AnimalVaccinationStatus.nonPrecisee,
    dateVaccination: DossierCodec.parseDateTime(map['dateVaccination']),
    observationVeterinaire:
        DossierCodec.decodeEnum(ObservationStatus.values, map['observationVeterinaire']) ??
            ObservationStatus.nonPrecisee,
    debutObservation: DossierCodec.parseDateTime(map['debutObservation']),
    finObservation: DossierCodec.parseDateTime(map['finObservation']),
    resultatObservation:
        DossierCodec.decodeEnum(ObservationResult.values, map['resultatObservation']) ??
            ObservationResult.nonPrecise,
    sort: DossierCodec.decodeEnum(AnimalOutcome.values, map['sort']) ??
        AnimalOutcome.enFuite,
    envoiTeteLabo:
        DossierCodec.decodeEnum(HeadLabSend.values, map['envoiTeteLabo']) ??
            HeadLabSend.nonPrecise,
    typeAnalyse: DossierCodec.decodeEnum(LabAnalysisType.values, map['typeAnalyse']),
    dateAnalyse: DossierCodec.parseDateTime(map['dateAnalyse']),
    resultatLabo:
        DossierCodec.decodeEnum(LabResultStatus.values, map['resultatLabo']) ??
            LabResultStatus.nonDisponible,
  );
}
