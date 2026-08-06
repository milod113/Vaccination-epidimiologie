import '../models/dossier/dossier_enums.dart';
import '../models/dossier/vaccination.dart';

/// Résolution et génération de la timeline vaccinale antirabique.
///
/// Logique pure (sans UI) des schémas OMS utilisés en Algérie :
/// - Essen 5 doses      : J0, J3, J7, J14, J28 (IM)
/// - Essen réduit        : J0, J3, J7, J14     (géré via tissulaire grade II)
/// - Zagreb 2-1-1        : J0 (×2 sites), J7, J21 (IM)
/// - Rappel J0/J3        : J0, J3
/// - Vaccin tissulaire   : même calendrier qu'Essen (grade II/III)
class RabiesProtocolResolver {
  const RabiesProtocolResolver._();

  /// Offset (en jours) de chaque dose du protocole.
  static List<int> offsets(VaccinationProtocolType type) {
    switch (type) {
      case VaccinationProtocolType.essen:
      case VaccinationProtocolType.vaccinTissulaireGradeII:
      case VaccinationProtocolType.vaccinTissulaireGradeIII:
        return const [0, 3, 7, 14, 28];
      case VaccinationProtocolType.zagreb:
        return const [0, 0, 7, 21];
      case VaccinationProtocolType.rappelJ0J3:
        return const [0, 3];
      case VaccinationProtocolType.autre:
        return const [0];
    }
  }

  /// Étiquette des jours théoriques (ex: `["J0", "J0", "J7", "J21"]`).
  static List<String> joursTheoriques(VaccinationProtocolType type) =>
      offsets(type).map((o) => o == 0 ? 'J0' : 'J$o').toList();

  /// `true` si la dose est une injection double (Zagreb J0 ×2).
  static bool doubleInjection(VaccinationProtocolType type, int index) =>
      type == VaccinationProtocolType.zagreb && index < 2;

  /// Voie par défaut du protocole.
  static AdministrationRoute voieParDefaut(VaccinationProtocolType type) =>
      AdministrationRoute.intramusculaire;

  /// Durée totale du schéma (en jours).
  static int dureeJours(VaccinationProtocolType type) {
    final offsetsList = offsets(type);
    return offsetsList.isEmpty ? 0 : offsetsList.last;
  }

  /// Nombre total de doses prévues par le schéma.
  static int nombreDoses(VaccinationProtocolType type) => offsets(type).length;

  /// Génère la liste des doses prévues du protocole à partir d'une date.
  static List<VaccineDose> genererDoses({
    required VaccinationProtocolType type,
    required DateTime dateDebut,
    bool premiereRealisee = false,
  }) {
    final offsetsList = offsets(type);
    return List.generate(offsetsList.length, (index) {
      final offset = offsetsList[index];
      return VaccineDose(
        numero: index + 1,
        jourTheorique: index == 0 ? 'J0' : 'J$offset',
        datePrevue: DateTime(
          dateDebut.year,
          dateDebut.month,
          dateDebut.day + offset,
        ),
        statut: (premiereRealisee && index == 0)
            ? DoseStatus.realisee
            : DoseStatus.prevue,
        voie: voieParDefaut(type),
        notes: doubleInjection(type, index)
            ? 'Injection double (2 sites)'
            : null,
      );
    });
  }

  /// Description lisible du schéma (ex: "J0 ×2, J7, J21").
  static String schema(VaccinationProtocolType type) {
    final jours = joursTheoriques(type);
    final buffer = <String>[];
    var index = 0;
    while (index < jours.length) {
      final jour = jours[index];
      if (doubleInjection(type, index)) {
        buffer.add('$jour ×2');
        index += 2;
      } else {
        buffer.add(jour);
        index += 1;
      }
    }
    return buffer.join(', ');
  }

  // ── Helpers de suivi des doses ──────────────────────────────────────

  /// Prochaine dose à administrer (prévue ou en retard, la plus proche).
  static VaccineDose? prochaineDose(VaccinationProtocol protocole) {
    final pending = protocole.doses
        .where((d) =>
            d.statut == DoseStatus.prevue || d.statut == DoseStatus.enRetard)
        .toList()
      ..sort((a, b) => (a.datePrevue ?? DateTime(9999))
          .compareTo(b.datePrevue ?? DateTime(9999)));
    return pending.isEmpty ? null : pending.first;
  }

  /// Doses attendues aujourd'hui (prévues, date = maintenant).
  static List<VaccineDose> dosesAujourdHui(
    VaccinationProtocol protocole,
    DateTime now,
  ) {
    return protocole.doses.where((d) {
      if (d.estRealisee || d.statut == DoseStatus.manquee) return false;
      final date = d.datePrevue;
      if (date == null) return false;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  /// Toutes les doses en attente (non réalisées).
  static List<VaccineDose> dosesEnAttente(VaccinationProtocol protocole) =>
      protocole.doses.where((d) => !d.estRealisee).toList();

  /// Doses en retard : non réalisées dont la date prévue est passée.
  static List<VaccineDose> dosesEnRetard(
    VaccinationProtocol protocole,
    DateTime now,
  ) {
    return protocole.doses.where((d) {
      if (d.estRealisee || d.statut == DoseStatus.manquee) return false;
      final date = d.datePrevue;
      if (date == null) return false;
      final jourPrevu = DateTime(date.year, date.month, date.day);
      final jourActuel = DateTime(now.year, now.month, now.day);
      return jourActuel.isAfter(jourPrevu);
    }).toList();
  }

  /// Nombre de jours de retard d'une dose (0 si pas en retard).
  static int joursDeRetard(VaccineDose dose, DateTime now) {
    final date = dose.datePrevue;
    if (date == null || dose.estRealisee) return 0;
    final jourPrevu = DateTime(date.year, date.month, date.day);
    final jourActuel = DateTime(now.year, now.month, now.day);
    final diff = jourActuel.difference(jourPrevu).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Retard maximum (en jours) parmi les doses en attente.
  static int retardMax(VaccinationProtocol protocole, DateTime now) {
    var max = 0;
    for (final dose in dosesEnRetard(protocole, now)) {
      final d = joursDeRetard(dose, now);
      if (d > max) max = d;
    }
    return max;
  }

  /// Le protocole est-il en retard ?
  static bool enRetard(VaccinationProtocol protocole, DateTime now) =>
      dosesEnRetard(protocole, now).isNotEmpty;

  /// Le suivi est-il rompu (dose en retard, protocole non terminé) ?
  static bool ruptureDeSuivi(VaccinationProtocol protocole, DateTime now) =>
      enRetard(protocole, now) && !protocole.estTermine;
}
