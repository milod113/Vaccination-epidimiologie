import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// B — Adresse / résidence du patient.
class Residence {
  final String adresse;
  final String commune;
  final String daira;
  final String wilaya;
  final String? residence;
  final String? coordonnees;
  final String? notes;

  const Residence({
    this.adresse = '',
    this.commune = '',
    this.daira = '',
    this.wilaya = '',
    this.residence,
    this.coordonnees,
    this.notes,
  });

  Residence copyWith({
    String? adresse,
    String? commune,
    String? daira,
    String? wilaya,
    String? residence,
    String? coordonnees,
    String? notes,
  }) {
    return Residence(
      adresse: adresse ?? this.adresse,
      commune: commune ?? this.commune,
      daira: daira ?? this.daira,
      wilaya: wilaya ?? this.wilaya,
      residence: residence ?? this.residence,
      coordonnees: coordonnees ?? this.coordonnees,
      notes: notes ?? this.notes,
    );
  }

  String get resume =>
      [adresse, commune, daira, wilaya].where((e) => e.isNotEmpty).join(' — ');

  Map<String, dynamic> toMap() => {
    'adresse': adresse,
    'commune': commune,
    'daira': daira,
    'wilaya': wilaya,
    'residence': residence,
    'coordonnees': coordonnees,
    'notes': notes,
  };

  factory Residence.fromMap(Map<String, dynamic> map) => Residence(
    adresse: map['adresse'] as String? ?? '',
    commune: map['commune'] as String? ?? '',
    daira: map['daira'] as String? ?? '',
    wilaya: map['wilaya'] as String? ?? '',
    residence: map['residence'] as String?,
    coordonnees: map['coordonnees'] as String?,
    notes: map['notes'] as String?,
  );
}

/// A — Identité patient.
class PatientIdentity {
  final String nom;
  final String prenom;
  final DateTime? dateNaissance;
  final int? age;
  final PatientGender sexe;
  final double? poidsKg;
  final String? telephone;
  final String? profession;
  final InstructionLevel niveauInstruction;
  final String? terrainParticulier;
  final String? sourceInformation;
  final String? medecinTraitant;
  final String? infirmier;
  final Residence residence;

  const PatientIdentity({
    this.nom = '',
    this.prenom = '',
    this.dateNaissance,
    this.age,
    this.sexe = PatientGender.masculin,
    this.poidsKg,
    this.telephone,
    this.profession,
    this.niveauInstruction = InstructionLevel.nonPrecise,
    this.terrainParticulier,
    this.sourceInformation,
    this.medecinTraitant,
    this.infirmier,
    this.residence = const Residence(),
  });

  PatientIdentity copyWith({
    String? nom,
    String? prenom,
    DateTime? dateNaissance,
    int? age,
    PatientGender? sexe,
    double? poidsKg,
    String? telephone,
    String? profession,
    InstructionLevel? niveauInstruction,
    String? terrainParticulier,
    String? sourceInformation,
    String? medecinTraitant,
    String? infirmier,
    Residence? residence,
  }) {
    return PatientIdentity(
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      age: age ?? this.age,
      sexe: sexe ?? this.sexe,
      poidsKg: poidsKg ?? this.poidsKg,
      telephone: telephone ?? this.telephone,
      profession: profession ?? this.profession,
      niveauInstruction: niveauInstruction ?? this.niveauInstruction,
      terrainParticulier: terrainParticulier ?? this.terrainParticulier,
      sourceInformation: sourceInformation ?? this.sourceInformation,
      medecinTraitant: medecinTraitant ?? this.medecinTraitant,
      infirmier: infirmier ?? this.infirmier,
      residence: residence ?? this.residence,
    );
  }

  String get nomComplet => '$prenom $nom'.trim();

  bool get estComplet =>
      nom.isNotEmpty && prenom.isNotEmpty && (dateNaissance != null || age != null);

  int? get ageCalcule {
    if (age != null) return age;
    final dob = dateNaissance;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }

  Map<String, dynamic> toMap() => {
    'nom': nom,
    'prenom': prenom,
    'dateNaissance': DossierCodec.dateToIso(dateNaissance),
    'age': age,
    'sexe': DossierCodec.encodeEnum(sexe),
    'poidsKg': poidsKg,
    'telephone': telephone,
    'profession': profession,
    'niveauInstruction': DossierCodec.encodeEnum(niveauInstruction),
    'terrainParticulier': terrainParticulier,
    'sourceInformation': sourceInformation,
    'medecinTraitant': medecinTraitant,
    'infirmier': infirmier,
    'residence': residence.toMap(),
  };

  factory PatientIdentity.fromMap(Map<String, dynamic> map) => PatientIdentity(
    nom: map['nom'] as String? ?? '',
    prenom: map['prenom'] as String? ?? '',
    dateNaissance: DossierCodec.parseDateTime(map['dateNaissance']),
    age: DossierCodec.asInt(map['age']),
    sexe: DossierCodec.decodeEnum(PatientGender.values, map['sexe']) ??
        PatientGender.masculin,
    poidsKg: DossierCodec.asDouble(map['poidsKg']),
    telephone: map['telephone'] as String?,
    profession: map['profession'] as String?,
    niveauInstruction:
        DossierCodec.decodeEnum(InstructionLevel.values, map['niveauInstruction']) ??
            InstructionLevel.nonPrecise,
    terrainParticulier: map['terrainParticulier'] as String?,
    sourceInformation: map['sourceInformation'] as String?,
    medecinTraitant: map['medecinTraitant'] as String?,
    infirmier: map['infirmier'] as String?,
    residence: Residence.fromMap(DossierCodec.subMap(map, 'residence') ?? {}),
  );
}
