import '../../data/models/tetanus_models.dart';

abstract class TetanusRepository {
  List<TetanusPatientModel> getPatients();
  TetanusPatientModel? getPatientById(String id);
  Map<String, int> getDashboardCounts();
}
