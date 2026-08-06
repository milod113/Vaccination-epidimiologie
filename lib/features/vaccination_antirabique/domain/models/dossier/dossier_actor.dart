import 'dossier_codec.dart';
import 'dossier_enums.dart';

/// Acteur (personne) ayant réalisé ou validé une étape du dossier.
///
/// Prêt pour un futur système d'authentification réel : identifiant métier,
/// nom complet, rôle, service/centre et coordonnées facultatives. Aujourd'hui
/// l'acteur courant provient de `ActorContext` (mock).
class DossierActor {
  final String id;
  final String nomComplet;
  final ActorRole role;
  final String? service;
  final String? telephone;

  const DossierActor({
    required this.id,
    required this.nomComplet,
    required this.role,
    this.service,
    this.telephone,
  });

  /// Initiales calculées pour l'avatar (ignore les préfixes Dr./Pr./IDE).
  String get initiales {
    final cleaned = nomComplet
        .replaceAll(RegExp(r'^(Dr\.|Pr\.|IDE)\s+'), '')
        .trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  /// Nom sans les préfixes honorifiques (affichage compact).
  String get nomCourt =>
      nomComplet.replaceAll(RegExp(r'^(Dr\.|Pr\.|IDE)\s+'), '');

  DossierActor copyWith({
    String? id,
    String? nomComplet,
    ActorRole? role,
    String? service,
    String? telephone,
  }) {
    return DossierActor(
      id: id ?? this.id,
      nomComplet: nomComplet ?? this.nomComplet,
      role: role ?? this.role,
      service: service ?? this.service,
      telephone: telephone ?? this.telephone,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'nomComplet': nomComplet,
    'role': DossierCodec.encodeEnum(role),
    'service': service,
    'telephone': telephone,
  };

  factory DossierActor.fromMap(Map<String, dynamic> map) => DossierActor(
    id: map['id'] as String? ?? '',
    nomComplet: map['nomComplet'] as String? ?? '',
    role: DossierCodec.decodeEnum(ActorRole.values, map['role']) ??
        ActorRole.autre,
    service: map['service'] as String?,
    telephone: map['telephone'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is DossierActor && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
