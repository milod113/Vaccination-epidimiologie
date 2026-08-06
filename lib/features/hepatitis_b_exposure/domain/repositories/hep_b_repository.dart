import '../../data/models/hep_b_models.dart';

abstract class HepBRepository {
  List<HepBExposurePatient> getPatients();
  HepBExposurePatient? getPatientById(String id);
  Map<String, int> getDashboardCounts();
}
