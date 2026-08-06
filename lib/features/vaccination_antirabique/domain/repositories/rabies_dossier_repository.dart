import '../models/dossier/rabies_case_record.dart';

/// Repository du dossier antirabique complet.
///
/// Abstrait la source de données (mock aujourd'hui, API/base locale dans le
/// futur). Le frontend ne consomme que `RabiesCaseRecord`.
abstract class RabiesDossierRepository {
  Future<List<RabiesCaseRecord>> getDossiers();

  Future<RabiesCaseRecord?> getDossierById(String id);

  /// Création / mise à jour d'un dossier (mock = en mémoire).
  Future<RabiesCaseRecord> saveDossier(RabiesCaseRecord dossier);
}