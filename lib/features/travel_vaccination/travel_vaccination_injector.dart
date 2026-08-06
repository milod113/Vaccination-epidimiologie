import 'package:get_it/get_it.dart';
import 'data/repositories/mock/mock_travel_repository.dart';
import 'domain/repositories/travel_repository.dart';

void initTravelVaccinationModule(GetIt sl) {
  sl.registerLazySingleton<TravelRepository>(() => MockTravelRepository());
}
