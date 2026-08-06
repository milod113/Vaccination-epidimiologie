import '../../data/models/epidemiology_dashboard_model.dart';

abstract class EpidemiologyDashboardRepository {
  Future<EpidemiologyDashboardData> getDashboardData();
}
