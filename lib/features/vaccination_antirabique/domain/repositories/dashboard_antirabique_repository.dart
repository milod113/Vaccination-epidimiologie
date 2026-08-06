import '../../data/models/dashboard_antirabique_models.dart';

abstract class DashboardAntirabiqueRepository {
  Future<DashboardAntirabiqueData> getDashboardData();
}
