import 'dart:convert';

/// Helpers de sérialisation pour le dossier antirabique.
///
/// Le format de persistance choisi est JSON simple (sans code generation) :
/// - `DateTime` → chaîne ISO-8601 `yyyy-MM-dd` ou `yyyy-MM-dd HH:mm`
/// - `enum` → son nom Dart (`Enum.name`)
/// - `List<enum>` → liste de noms
/// - nombres, booléens, chaînes → natifs
class DossierCodec {
  const DossierCodec._();

  // ── Dates ──────────────────────────────────────────────────────────────

  /// Formate une date en `yyyy-MM-dd` (ou null).
  static String? dateToIso(DateTime? date) {
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Formate une date-heure en `yyyy-MM-dd HH:mm` (ou null).
  static String? dateTimeToIso(DateTime? date) {
    if (date == null) return null;
    final d = dateToIso(date);
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$d $hh:$mm';
  }

  /// Parse `yyyy-MM-dd` ou `yyyy-MM-dd HH:mm` → DateTime (ou null).
  static DateTime? parseDateTime(Object? value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    if (s.length == 10) {
      return DateTime.tryParse('$s 00:00:00');
    }
    if (s.length == 16) {
      return DateTime.tryParse('$s:00');
    }
    return DateTime.tryParse(s);
  }

  /// Extrait une heure `HH:mm` depuis une date (ou null).
  static String? timeOfDay(DateTime? date) {
    if (date == null) return null;
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  /// Parse `HH:mm` → minutes depuis minuit (ou null).
  static int? timeToMinutes(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  // ── Enums ──────────────────────────────────────────────────────────────

  /// Sérialise un enum en son `name` (ou null).
  static String? encodeEnum(Enum? value) => value?.name;

  /// Désérialise un enum depuis son `name` (tolérant, retourne null si inconnu).
  static T? decodeEnum<T extends Enum>(List<T> values, Object? name) {
    if (name == null) return null;
    final target = name.toString();
    for (final value in values) {
      if (value.name == target) return value;
    }
    return null;
  }

  /// Désérialise une liste d'enums depuis une liste de noms.
  static List<T> decodeEnumList<T extends Enum>(List<T> values, Object? list) {
    if (list is! List) return const [];
    return list
        .map((e) => decodeEnum(values, e))
        .whereType<T>()
        .toList();
  }

  // ── Primitifs ──────────────────────────────────────────────────────────

  static int? asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? asDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool asBool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return fallback;
  }

  /// Sérialise une map de sous-objet (ou null).
  static Map<String, dynamic>? encodeSub(Map<String, dynamic>? map) => map;

  /// Lit un sous-objet depuis une map (ou null).
  static Map<String, dynamic>? subMap(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

/// Extension pratique pour la sérialisation JSON d'un modèle.
mixin JsonSerializableModel {
  Map<String, dynamic> toMap();

  String toJson() => jsonEncode(toMap());
}
