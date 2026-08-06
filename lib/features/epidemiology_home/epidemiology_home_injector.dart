import 'package:get_it/get_it.dart';
import 'data/repositories/mock/mock_epidemiology_dashboard_repository.dart';
import 'domain/repositories/epidemiology_dashboard_repository.dart';

void initEpidemiologyHomeModule(GetIt sl) {
  sl.registerLazySingleton<EpidemiologyDashboardRepository>(
    () => MockEpidemiologyDashboardRepository(),
  );
}
