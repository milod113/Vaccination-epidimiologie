import '../../data/models/protocole_vaccinal_model.dart';

abstract class ProtocoleRepository {
  Future<ProtocoleVaccinalModel> getProtocole(String patientId);
  Future<void> validerDose(String patientId, String doseId, {
    required String dateReelle,
    required String numeroLot,
    String? dateExpirationLot,
    String? administrateurNom,
    String? centre,
    String? salle,
    String? observations,
    String? effetsIndesirables,
  });
  Future<void> reporterDose(String patientId, String doseId, {
    required String motifReport,
    String? dateNouveauRdv,
  });
}
