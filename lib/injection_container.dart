import 'package:get_it/get_it.dart';
import 'features/epidemiology_home/epidemiology_home_injector.dart';
import 'features/hepatitis_b_exposure/hepatitis_b_exposure_injector.dart';
import 'features/tetanus_exposure/tetanus_exposure_injector.dart';
import 'features/travel_vaccination/travel_vaccination_injector.dart';
import 'features/vaccination_antirabique/vaccination_antirabique_injector.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  initEpidemiologyHomeModule(sl);
  initVaccinationAntirabiqueModule(sl);
  initTetanusExposureModule(sl);
  initHepatitisBExposureModule(sl);
  initTravelVaccinationModule(sl);
}
