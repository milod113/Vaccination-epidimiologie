import 'dart:convert';

import 'dossier_codec.dart';
import 'admission.dart';
import 'animal.dart';
import 'clinical_care.dart';
import 'dossier_enums.dart';
import 'dossier_history.dart';
import 'exposure.dart';
import 'follow_up.dart';
import 'patient_identity.dart';
import 'traceability.dart';
import 'vaccination.dart';

/// Modèle central du dossier médical du patient exposé au risque rabique,
/// conforme au dossier antirabique algérien.
///
/// Agrège les sections A à P du formulaire officiel :
/// A. Identité patient · B. Adresse · C. Accueil/admission · D. Exposition ·
/// E. Classification · F. Animal · G. Soins locaux · H. ERIG · I. Chirurgie ·
/// J. Vaccination + protocole · K. MPVI · L. Antibiotiques · M. VAT · N. Autres
/// traitements · O. Traçabilité · P. Évolution.
class RabiesCaseRecord {
  final String id;
  final String numeroDossier;
  final PatientIdentity identity;
  final ArrivalInfo admission;
  final ExposureDetails exposition;
  final RiskClassification classification;
  final AnimalInfo animal;
  final LocalCareInfo soinsLocaux;
  final ErigInfo erig;
  final SurgeryInfo chirurgie;
  final RabiesVaccination vaccination;
  final MpviInfo mpvi;
  final AntibioticInfo antibiotiques;
  final TetanusVaccination vaccinationTetanos;
  final OtherTreatments autresTraitements;
  final TraceabilityInfo tracabilite;
  final FinalOutcome evolution;
  final List<RabiesDossierHistoryEntry> historique;
  final DateTime? dateCreation;
  final DateTime? dateMaj;

  const RabiesCaseRecord({
    required this.id,
    required this.numeroDossier,
    this.identity = const PatientIdentity(),
    this.admission = const ArrivalInfo(),
    this.exposition = const ExposureDetails(),
    this.classification = const RiskClassification(),
    this.animal = const AnimalInfo(),
    this.soinsLocaux = const LocalCareInfo(),
    this.erig = const ErigInfo(),
    this.chirurgie = const SurgeryInfo(),
    this.vaccination = const RabiesVaccination(),
    this.mpvi = const MpviInfo(),
    this.antibiotiques = const AntibioticInfo(),
    this.vaccinationTetanos = const TetanusVaccination(),
    this.autresTraitements = const OtherTreatments(),
    this.tracabilite = const TraceabilityInfo(),
    this.evolution = const FinalOutcome(),
    this.historique = const [],
    this.dateCreation,
    this.dateMaj,
  });

  RabiesCaseRecord copyWith({
    String? id,
    String? numeroDossier,
    PatientIdentity? identity,
    ArrivalInfo? admission,
    ExposureDetails? exposition,
    RiskClassification? classification,
    AnimalInfo? animal,
    LocalCareInfo? soinsLocaux,
    ErigInfo? erig,
    SurgeryInfo? chirurgie,
    RabiesVaccination? vaccination,
    MpviInfo? mpvi,
    AntibioticInfo? antibiotiques,
    TetanusVaccination? vaccinationTetanos,
    OtherTreatments? autresTraitements,
    TraceabilityInfo? tracabilite,
    FinalOutcome? evolution,
    List<RabiesDossierHistoryEntry>? historique,
    DateTime? dateCreation,
    DateTime? dateMaj,
  }) {
    return RabiesCaseRecord(
      id: id ?? this.id,
      numeroDossier: numeroDossier ?? this.numeroDossier,
      identity: identity ?? this.identity,
      admission: admission ?? this.admission,
      exposition: exposition ?? this.exposition,
      classification: classification ?? this.classification,
      animal: animal ?? this.animal,
      soinsLocaux: soinsLocaux ?? this.soinsLocaux,
      erig: erig ?? this.erig,
      chirurgie: chirurgie ?? this.chirurgie,
      vaccination: vaccination ?? this.vaccination,
      mpvi: mpvi ?? this.mpvi,
      antibiotiques: antibiotiques ?? this.antibiotiques,
      vaccinationTetanos: vaccinationTetanos ?? this.vaccinationTetanos,
      autresTraitements: autresTraitements ?? this.autresTraitements,
      tracabilite: tracabilite ?? this.tracabilite,
      evolution: evolution ?? this.evolution,
      historique: historique ?? this.historique,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMaj: dateMaj ?? this.dateMaj,
    );
  }

  // ── Helpers métier agrégés ─────────────────────────────────────────────

  String get patientNomComplet => identity.nomComplet;

  String get patientAge => identity.ageCalcule?.toString() ?? '—';

  RabiesRiskCategory get categorie => classification.categorie;

  bool get estUrgent => categorie == RabiesRiskCategory.categorieIII;

  bool get aErigAdministree => erig.administree;

  bool get aRetard => vaccination.protocole.aRetard;

  bool get protocoleTermine => vaccination.protocole.estTermine;

  bool get aMpvi => mpvi.present;

  Map<String, dynamic> toMap() => {
    'id': id,
    'numeroDossier': numeroDossier,
    'identity': identity.toMap(),
    'admission': admission.toMap(),
    'exposition': exposition.toMap(),
    'classification': classification.toMap(),
    'animal': animal.toMap(),
    'soinsLocaux': soinsLocaux.toMap(),
    'erig': erig.toMap(),
    'chirurgie': chirurgie.toMap(),
    'vaccination': vaccination.toMap(),
    'mpvi': mpvi.toMap(),
    'antibiotiques': antibiotiques.toMap(),
    'vaccinationTetanos': vaccinationTetanos.toMap(),
    'autresTraitements': autresTraitements.toMap(),
    'tracabilite': tracabilite.toMap(),
    'evolution': evolution.toMap(),
    'historique': historique.map((e) => e.toMap()).toList(),
    'dateCreation': DossierCodec.dateTimeToIso(dateCreation),
    'dateMaj': DossierCodec.dateTimeToIso(dateMaj),
  };

  String toJson() => jsonEncode(toMap());

  factory RabiesCaseRecord.fromMap(Map<String, dynamic> map) =>
      RabiesCaseRecord(
        id: map['id'] as String? ?? '',
        numeroDossier: map['numeroDossier'] as String? ?? '',
        identity:
            PatientIdentity.fromMap(DossierCodec.subMap(map, 'identity') ?? {}),
        admission:
            ArrivalInfo.fromMap(DossierCodec.subMap(map, 'admission') ?? {}),
        exposition:
            ExposureDetails.fromMap(DossierCodec.subMap(map, 'exposition') ?? {}),
        classification: RiskClassification.fromMap(
            DossierCodec.subMap(map, 'classification') ?? {}),
        animal: AnimalInfo.fromMap(DossierCodec.subMap(map, 'animal') ?? {}),
        soinsLocaux:
            LocalCareInfo.fromMap(DossierCodec.subMap(map, 'soinsLocaux') ?? {}),
        erig: ErigInfo.fromMap(DossierCodec.subMap(map, 'erig') ?? {}),
        chirurgie:
            SurgeryInfo.fromMap(DossierCodec.subMap(map, 'chirurgie') ?? {}),
        vaccination: RabiesVaccination.fromMap(
            DossierCodec.subMap(map, 'vaccination') ?? {}),
        mpvi: MpviInfo.fromMap(DossierCodec.subMap(map, 'mpvi') ?? {}),
        antibiotiques: AntibioticInfo.fromMap(
            DossierCodec.subMap(map, 'antibiotiques') ?? {}),
        vaccinationTetanos: TetanusVaccination.fromMap(
            DossierCodec.subMap(map, 'vaccinationTetanos') ?? {}),
        autresTraitements: OtherTreatments.fromMap(
            DossierCodec.subMap(map, 'autresTraitements') ?? {}),
        tracabilite: TraceabilityInfo.fromMap(
            DossierCodec.subMap(map, 'tracabilite') ?? {}),
        evolution:
            FinalOutcome.fromMap(DossierCodec.subMap(map, 'evolution') ?? {}),
        historique: (map['historique'] as List?)?.map((e) {
          return RabiesDossierHistoryEntry.fromMap(
            Map<String, dynamic>.from(e as Map),
          );
        }).toList() ??
            const [],
        dateCreation: DossierCodec.parseDateTime(map['dateCreation']),
        dateMaj: DossierCodec.parseDateTime(map['dateMaj']),
      );

  factory RabiesCaseRecord.fromJson(String json) =>
      RabiesCaseRecord.fromMap(Map<String, dynamic>.from(jsonDecode(json)));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RabiesCaseRecord && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
