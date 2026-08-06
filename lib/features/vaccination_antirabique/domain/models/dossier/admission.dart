import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// C — Accueil / admission à l'UAR.
class ArrivalInfo {
  final DateTime? dateArriveeUar;
  final String? heureArrivee; // HH:mm
  final ArrivalMode modeArrivee;
  final String? structureOrientation;
  final DateTime? dateDebutPriseEnCharge;
  final String? heureDebutPriseEnCharge; // HH:mm

  const ArrivalInfo({
    this.dateArriveeUar,
    this.heureArrivee,
    this.modeArrivee = ArrivalMode.venuDirectement,
    this.structureOrientation,
    this.dateDebutPriseEnCharge,
    this.heureDebutPriseEnCharge,
  });

  ArrivalInfo copyWith({
    DateTime? dateArriveeUar,
    String? heureArrivee,
    ArrivalMode? modeArrivee,
    String? structureOrientation,
    DateTime? dateDebutPriseEnCharge,
    String? heureDebutPriseEnCharge,
  }) {
    return ArrivalInfo(
      dateArriveeUar: dateArriveeUar ?? this.dateArriveeUar,
      heureArrivee: heureArrivee ?? this.heureArrivee,
      modeArrivee: modeArrivee ?? this.modeArrivee,
      structureOrientation: structureOrientation ?? this.structureOrientation,
      dateDebutPriseEnCharge:
          dateDebutPriseEnCharge ?? this.dateDebutPriseEnCharge,
      heureDebutPriseEnCharge:
          heureDebutPriseEnCharge ?? this.heureDebutPriseEnCharge,
    );
  }

  Map<String, dynamic> toMap() => {
    'dateArriveeUar': DossierCodec.dateToIso(dateArriveeUar),
    'heureArrivee': heureArrivee,
    'modeArrivee': DossierCodec.encodeEnum(modeArrivee),
    'structureOrientation': structureOrientation,
    'dateDebutPriseEnCharge': DossierCodec.dateToIso(dateDebutPriseEnCharge),
    'heureDebutPriseEnCharge': heureDebutPriseEnCharge,
  };

  factory ArrivalInfo.fromMap(Map<String, dynamic> map) => ArrivalInfo(
    dateArriveeUar: DossierCodec.parseDateTime(map['dateArriveeUar']),
    heureArrivee: map['heureArrivee'] as String?,
    modeArrivee:
        DossierCodec.decodeEnum(ArrivalMode.values, map['modeArrivee']) ??
            ArrivalMode.venuDirectement,
    structureOrientation: map['structureOrientation'] as String?,
    dateDebutPriseEnCharge:
        DossierCodec.parseDateTime(map['dateDebutPriseEnCharge']),
    heureDebutPriseEnCharge: map['heureDebutPriseEnCharge'] as String?,
  );
}
