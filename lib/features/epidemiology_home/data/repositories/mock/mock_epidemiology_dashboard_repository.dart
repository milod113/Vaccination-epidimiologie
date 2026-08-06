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
      patientsEnRetard: 4,
      dossiersActifs: 12,
      modulesActifs: 3,
      antirabique: ModuleStatus(
          patientsEnSuivi: 11, patientsEnRetard: 3, alertes: 3, actif: true),
      tetanos: ModuleStatus(
          patientsEnSuivi: 5, patientsEnRetard: 1, alertes: 1, actif: true),
      hepatiteB: ModuleStatus(
          patientsEnSuivi: 4, patientsEnRetard: 0, alertes: 0, actif: false),
      voyageur: ModuleStatus(
          patientsEnSuivi: 7, patientsEnRetard: 0, alertes: 1, actif: false),
    );
  }
}
