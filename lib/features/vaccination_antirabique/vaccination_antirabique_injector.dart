import 'package:get_it/get_it.dart';
import 'data/repositories/mock/mock_certificat_service.dart';
import 'data/repositories/mock/mock_dashboard_antirabique_repository.dart';
import 'data/repositories/mock/mock_evaluation_initiale_repository.dart';
import 'data/repositories/mock/mock_patient_antirabique_repository.dart';
import 'data/repositories/mock/mock_protocole_repository.dart';
import 'data/repositories/mock/mock_rabies_dossier_repository.dart';
import 'data/repositories/mock/mock_stock_repository.dart';
import 'data/repositories/mock/mock_suivi_clinique_repository.dart';
import 'domain/repositories/dashboard_antirabique_repository.dart';
import 'domain/repositories/evaluation_initiale_repository.dart';
import 'domain/repositories/patient_antirabique_repository.dart';
import 'domain/repositories/protocole_repository.dart';
import 'domain/repositories/rabies_dossier_repository.dart';
import 'domain/repositories/stock_repository.dart';
import 'domain/repositories/suivi_clinique_repository.dart';
import 'domain/services/certificat_service.dart';

void initVaccinationAntirabiqueModule(GetIt sl) {
  sl.registerLazySingleton<PatientAntirabiqueRepository>(
    () => MockPatientAntirabiqueRepository(),
  );
  sl.registerLazySingleton<ProtocoleRepository>(
    () => MockProtocoleRepository(),
  );
  sl.registerLazySingleton<SuiviCliniqueRepository>(
    () => MockSuiviCliniqueRepository(),
  );
  sl.registerLazySingleton<DashboardAntirabiqueRepository>(
    () => MockDashboardAntirabiqueRepository(),
  );
  sl.registerLazySingleton<StockRepository>(
    () => MockStockRepository(),
  );
  sl.registerLazySingleton<CertificatService>(
    () => MockCertificatService(),
  );
  sl.registerLazySingleton<EvaluationInitialeRepository>(
    () => MockEvaluationInitialeRepository(),
  );
  sl.registerLazySingleton<RabiesDossierRepository>(
    () => MockRabiesDossierRepository(),
  );
}
