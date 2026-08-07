import '../../data/models/tetanus_models.dart';

abstract class TetanusRepository {
  List<TetanusPatientModel> getPatients();
  TetanusPatientModel? getPatientById(String id);
  Map<String, int> getDashboardCounts();

  /// Enregistre un nouvel acte médical et le rattache à son dossier patient.
  bool addAct(TetanusActeModel acte);

  /// Tous les actes enregistrés (historique consolidé), triés du plus récent au plus ancien.
  List<TetanusActeModel> getAllActes();
}
