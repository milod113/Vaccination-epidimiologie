import '../../data/models/patient_antirabique_model.dart';

abstract class PatientAntirabiqueRepository {
  Future<List<PatientAntirabiqueModel>> getPatients();
  Future<PatientAntirabiqueModel?> getPatientById(String id);

  /// Crée un patient (le repository génère l'id si absent) et renvoie l'enregistrement final.
  Future<PatientAntirabiqueModel> createPatient(PatientAntirabiqueModel patient);

  /// Insère ou met à jour un patient selon son id.
  Future<PatientAntirabiqueModel> savePatient(PatientAntirabiqueModel patient);
}
