import 'dossier_actor.dart';
import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// Entrée de l'historique réglementaire d'un dossier antirabique.
///
/// Trace « qui a fait quoi, quand, sur quelle section, avec quelle valeur ».
/// Chaque action importante du dossier (création, validation J0, ERIG, dose,
/// carte remise, registre, clôture…) produit une entrée horodatée et signée
/// par un [DossierActor].
class RabiesDossierHistoryEntry {
  final String id;
  final DateTime dateHeure;
  final DossierHistoryActionType typeAction;
  final String titre;
  final String? description;
  final DossierSectionType sectionConcernee;
  final DossierActor acteur;
  final ValidationStepType? etapeValidee;
  final ValidationStatus statut;
  final String? ancienneValeur;
  final String? nouvelleValeur;
  final String? origine;

  const RabiesDossierHistoryEntry({
    required this.id,
    required this.dateHeure,
    required this.typeAction,
    required this.titre,
    required this.sectionConcernee,
    required this.acteur,
    this.description,
    this.etapeValidee,
    this.statut = ValidationStatus.validee,
    this.ancienneValeur,
    this.nouvelleValeur,
    this.origine,
  });

  RabiesDossierHistoryEntry copyWith({
    String? id,
    DateTime? dateHeure,
    DossierHistoryActionType? typeAction,
    String? titre,
    String? description,
    DossierSectionType? sectionConcernee,
    DossierActor? acteur,
    ValidationStepType? etapeValidee,
    ValidationStatus? statut,
    String? ancienneValeur,
    String? nouvelleValeur,
    String? origine,
  }) {
    return RabiesDossierHistoryEntry(
      id: id ?? this.id,
      dateHeure: dateHeure ?? this.dateHeure,
      typeAction: typeAction ?? this.typeAction,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      sectionConcernee: sectionConcernee ?? this.sectionConcernee,
      acteur: acteur ?? this.acteur,
      etapeValidee: etapeValidee ?? this.etapeValidee,
      statut: statut ?? this.statut,
      ancienneValeur: ancienneValeur ?? this.ancienneValeur,
      nouvelleValeur: nouvelleValeur ?? this.nouvelleValeur,
      origine: origine ?? this.origine,
    );
  }

  /// `ancienneValeur → nouvelleValeur` (ou null).
  String? get deltaValeurs {
    if (ancienneValeur == null && nouvelleValeur == null) return null;
    final from = ancienneValeur?.trim().isNotEmpty == true
        ? ancienneValeur!.trim()
        : '—';
    final to = nouvelleValeur?.trim().isNotEmpty == true
        ? nouvelleValeur!.trim()
        : '—';
    if (from == to) return '→ $to';
    return '$from → $to';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'dateHeure': DossierCodec.dateTimeToIso(dateHeure),
    'typeAction': DossierCodec.encodeEnum(typeAction),
    'titre': titre,
    'description': description,
    'sectionConcernee': DossierCodec.encodeEnum(sectionConcernee),
    'acteur': acteur.toMap(),
    'etapeValidee': DossierCodec.encodeEnum(etapeValidee),
    'statut': DossierCodec.encodeEnum(statut),
    'ancienneValeur': ancienneValeur,
    'nouvelleValeur': nouvelleValeur,
    'origine': origine,
  };

  factory RabiesDossierHistoryEntry.fromMap(Map<String, dynamic> map) =>
      RabiesDossierHistoryEntry(
        id: map['id'] as String? ?? '',
        dateHeure: DossierCodec.parseDateTime(map['dateHeure']) ??
            DateTime.now(),
        typeAction: DossierCodec.decodeEnum(
            DossierHistoryActionType.values, map['typeAction']) ??
            DossierHistoryActionType.autre,
        titre: map['titre'] as String? ?? '',
        description: map['description'] as String?,
        sectionConcernee: DossierCodec.decodeEnum(
            DossierSectionType.values, map['sectionConcernee']) ??
            DossierSectionType.dossier,
        acteur: DossierActor.fromMap(
            DossierCodec.subMap(map, 'acteur') ?? const {}),
        etapeValidee: DossierCodec.decodeEnum(
            ValidationStepType.values, map['etapeValidee']),
        statut: DossierCodec.decodeEnum(ValidationStatus.values, map['statut']) ??
            ValidationStatus.validee,
        ancienneValeur: map['ancienneValeur'] as String?,
        nouvelleValeur: map['nouvelleValeur'] as String?,
        origine: map['origine'] as String?,
      );
}
