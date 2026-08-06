import '../../data/models/suivi_clinique_model.dart';

abstract class SuiviCliniqueRepository {
  Future<List<SuiviCliniqueModel>> getSuiviClinique(String patientId);
  Future<void> ajouterNote(SuiviCliniqueModel note);
}
