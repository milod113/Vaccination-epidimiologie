import '../../data/models/tracabilite/certificat_model.dart';

abstract class CertificatService {
  Future<CertificatModel> genererCertificat(String patientId);
  Future<String> genererHtml(CertificatModel certificat);
}
