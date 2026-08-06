import 'package:get_it/get_it.dart';
import 'data/repositories/mock/mock_hep_b_repository.dart';
import 'domain/repositories/hep_b_repository.dart';

void initHepatitisBExposureModule(GetIt sl) {
  sl.registerLazySingleton<HepBRepository>(() => MockHepBRepository());
}
