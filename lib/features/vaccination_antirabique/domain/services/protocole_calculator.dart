import '../../data/models/patient_antirabique_model.dart';
import '../../data/models/protocole_vaccinal_model.dart';

/// Calcule les dates et génère les doses pour les protocoles vaccinaux antirabiques.
///
/// Les schémas OMS supportés :
/// - Essen 5 doses : J0, J3, J7, J14, J28 (voie IM)
/// - Essen réduit 4 doses : J0, J3, J7, J14-28 (voie IM)
/// - Zagreb 2-1-1 : J0 (×2 sites), J7, J21 (voie IM)
/// - IPC : J0 (×2 sites ID), J3 (×2 sites ID), J7 (×2 sites ID)
class ProtocoleCalculator {
  /// Génère la liste des doses prévues pour un protocole donné.
  static List<DoseModel> genererDoses({
    required ProtocoleType type,
    required String dateDebut,
    String patientId = '',
  }) {
    final debut = DateTime.tryParse(dateDebut);
    if (debut == null) return [];

    final doses = <DoseModel>[];
    int doseNum = 0;

    void ajouterDose(int jourOffset, {bool doubleInjection = false, String voie = 'IM'}) {
      doseNum++;
      final date = _formatDate(debut.add(Duration(days: jourOffset)));
      doses.add(DoseModel(
        id: '${patientId}_gen_${doses.length}_${DateTime.now().millisecondsSinceEpoch}',
        numeroDose: doseNum,
        jourTheorique: 'J${jourOffset}',
        datePrevue: date,
        injectionDouble: doubleInjection,
        voieAdministration: voie,
      ));
    }

    switch (type) {
      case ProtocoleType.essen:
        ajouterDose(0);  // J0 — Dose 1
        ajouterDose(3);  // J3 — Dose 2
        ajouterDose(7);  // J7 — Dose 3
        ajouterDose(14); // J14 — Dose 4
        ajouterDose(28); // J28 — Dose 5
        break;

      case ProtocoleType.essenReduit:
        ajouterDose(0);   // J0 — Dose 1
        ajouterDose(3);   // J3 — Dose 2
        ajouterDose(7);   // J7 — Dose 3
        ajouterDose(14);  // J14 — Dose 4
        break;

      case ProtocoleType.zagreb:
        ajouterDose(0, doubleInjection: true);   // J0 — Dose 1 (site 1)
        ajouterDose(0, doubleInjection: true);   // J0 — Dose 2 (site 2)
        ajouterDose(7);                           // J7 — Dose 3
        ajouterDose(21);                          // J21 — Dose 4
        break;

      case ProtocoleType.ipc:
        ajouterDose(0, voie: 'ID');  // J0 — Dose 1
        ajouterDose(0, voie: 'ID');  // J0 — Dose 2
        ajouterDose(3, voie: 'ID');  // J3 — Dose 3
        ajouterDose(3, voie: 'ID');  // J3 — Dose 4
        ajouterDose(7, voie: 'ID');  // J7 — Dose 5
        ajouterDose(7, voie: 'ID');  // J7 — Dose 6
        break;
    }

    return doses;
  }

  /// Calcule le nombre de jours depuis la date de début.
  static int joursDepuisDebut(String dateDebut) {
    final debut = DateTime.tryParse(dateDebut);
    if (debut == null) return 0;
    return DateTime.now().difference(debut).inDays;
  }

  /// Retourne le jour théorique actuel (ex: 12 pour J12).
  static int jourTheoriqueActuel(String dateDebut) {
    return joursDepuisDebut(dateDebut).clamp(0, 365);
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
