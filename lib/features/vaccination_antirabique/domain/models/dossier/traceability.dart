import 'dossier_actor.dart';
import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// O — Carte de vaccination / traçabilité.
///
/// État administratif réglementaire : carte de vaccination remise (avec numéro)
/// et inscription au registre de l'UAR (avec numéro), plus les remarques et,
/// lorsque l'information est connue, l'acteur et la date de chaque opération.
class TraceabilityInfo {
  final TraceStatus carteVaccination;
  final String? numeroCarte;
  final TraceStatus registre;
  final String? numeroRegistre;
  final String? remarques;
  final DossierActor? carteRemisePar;
  final DateTime? dateCarteRemise;
  final DossierActor? registreRenseignePar;
  final DateTime? dateInscriptionRegistre;

  const TraceabilityInfo({
    this.carteVaccination = TraceStatus.non,
    this.numeroCarte,
    this.registre = TraceStatus.non,
    this.numeroRegistre,
    this.remarques,
    this.carteRemisePar,
    this.dateCarteRemise,
    this.registreRenseignePar,
    this.dateInscriptionRegistre,
  });

  TraceabilityInfo copyWith({
    TraceStatus? carteVaccination,
    String? numeroCarte,
    TraceStatus? registre,
    String? numeroRegistre,
    String? remarques,
    DossierActor? carteRemisePar,
    DateTime? dateCarteRemise,
    DossierActor? registreRenseignePar,
    DateTime? dateInscriptionRegistre,
  }) {
    return TraceabilityInfo(
      carteVaccination: carteVaccination ?? this.carteVaccination,
      numeroCarte: numeroCarte ?? this.numeroCarte,
      registre: registre ?? this.registre,
      numeroRegistre: numeroRegistre ?? this.numeroRegistre,
      remarques: remarques ?? this.remarques,
      carteRemisePar: carteRemisePar ?? this.carteRemisePar,
      dateCarteRemise: dateCarteRemise ?? this.dateCarteRemise,
      registreRenseignePar: registreRenseignePar ?? this.registreRenseignePar,
      dateInscriptionRegistre:
          dateInscriptionRegistre ?? this.dateInscriptionRegistre,
    );
  }

  bool get carteRemise => carteVaccination == TraceStatus.ouiAvecNumero;

  bool get patientRepertorie => registre == TraceStatus.ouiAvecNumero;

  /// Nombre de volets renseignés (0..2).
  int get pointsRenseignes => (carteRemise ? 1 : 0) + (patientRepertorie ? 1 : 0);

  /// Complétude de la traçabilité (0.0 .. 1.0).
  double get completude => pointsRenseignes / 2;

  /// Statut global de la traçabilité réglementaire.
  TraceabilityStatus get statut {
    if (pointsRenseignes == 0) return TraceabilityStatus.nonDemarre;
    return pointsRenseignes == 2
        ? TraceabilityStatus.complete
        : TraceabilityStatus.incomplete;
  }

  Map<String, dynamic> toMap() => {
    'carteVaccination': DossierCodec.encodeEnum(carteVaccination),
    'numeroCarte': numeroCarte,
    'registre': DossierCodec.encodeEnum(registre),
    'numeroRegistre': numeroRegistre,
    'remarques': remarques,
    'carteRemisePar': carteRemisePar?.toMap(),
    'dateCarteRemise': DossierCodec.dateTimeToIso(dateCarteRemise),
    'registreRenseignePar': registreRenseignePar?.toMap(),
    'dateInscriptionRegistre': DossierCodec.dateTimeToIso(dateInscriptionRegistre),
  };

  factory TraceabilityInfo.fromMap(Map<String, dynamic> map) =>
      TraceabilityInfo(
        carteVaccination:
            DossierCodec.decodeEnum(TraceStatus.values, map['carteVaccination']) ??
                TraceStatus.non,
        numeroCarte: map['numeroCarte'] as String?,
        registre:
            DossierCodec.decodeEnum(TraceStatus.values, map['registre']) ??
                TraceStatus.non,
        numeroRegistre: map['numeroRegistre'] as String?,
        remarques: map['remarques'] as String?,
        carteRemisePar: map['carteRemisePar'] == null
            ? null
            : DossierActor.fromMap(
                DossierCodec.subMap(map, 'carteRemisePar') ?? const {}),
        dateCarteRemise: DossierCodec.parseDateTime(map['dateCarteRemise']),
        registreRenseignePar: map['registreRenseignePar'] == null
            ? null
            : DossierActor.fromMap(
                DossierCodec.subMap(map, 'registreRenseignePar') ?? const {}),
        dateInscriptionRegistre:
            DossierCodec.parseDateTime(map['dateInscriptionRegistre']),
      );
}

/// P — Évolution finale du dossier.
class FinalOutcome {
  final FinalCaseOutcome resultat;
  final String? observations;
  final DateTime? dateCloture;

  const FinalOutcome({
    this.resultat = FinalCaseOutcome.dossierEnCours,
    this.observations,
    this.dateCloture,
  });

  FinalOutcome copyWith({
    FinalCaseOutcome? resultat,
    String? observations,
    DateTime? dateCloture,
  }) {
    return FinalOutcome(
      resultat: resultat ?? this.resultat,
      observations: observations ?? this.observations,
      dateCloture: dateCloture ?? this.dateCloture,
    );
  }

  bool get estClos => resultat != FinalCaseOutcome.dossierEnCours;

  Map<String, dynamic> toMap() => {
    'resultat': DossierCodec.encodeEnum(resultat),
    'observations': observations,
    'dateCloture': DossierCodec.dateToIso(dateCloture),
  };

  factory FinalOutcome.fromMap(Map<String, dynamic> map) => FinalOutcome(
    resultat:
        DossierCodec.decodeEnum(FinalCaseOutcome.values, map['resultat']) ??
            FinalCaseOutcome.dossierEnCours,
    observations: map['observations'] as String?,
    dateCloture: DossierCodec.parseDateTime(map['dateCloture']),
  );
}
