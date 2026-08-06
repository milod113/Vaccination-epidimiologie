import 'package:epidemiology_antirabic/features/epidemiology_home/data/models/epidemiology_dashboard_model.dart';
import 'package:epidemiology_antirabic/features/epidemiology_home/domain/repositories/epidemiology_dashboard_repository.dart';

class MockEpidemiologyDashboardRepository implements EpidemiologyDashboardRepository {
  @override
  Future<EpidemiologyDashboardData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const EpidemiologyDashboardData(
      patientsTotal: 27,
      vaccinationsAujourdhui: 8,
      alertesTotal: 5,
      modulesActifs: 3,
      antirabique: ModuleStatus(patientsEnSuivi: 11, alertes: 3, actif: true),
      tetanos: ModuleStatus(patientsEnSuivi: 5, alertes: 1, actif: true),
      hepatiteB: ModuleStatus(patientsEnSuivi: 4, alertes: 0, actif: false),
      voyageur: ModuleStatus(patientsEnSuivi: 7, alertes: 1, actif: false),
    );
  }
}
