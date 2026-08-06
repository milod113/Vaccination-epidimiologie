import 'package:get_it/get_it.dart';
import 'data/repositories/mock/mock_tetanus_repository.dart';
import 'domain/repositories/tetanus_repository.dart';

void initTetanusExposureModule(GetIt sl) {
  sl.registerLazySingleton<TetanusRepository>(() => MockTetanusRepository());
}
