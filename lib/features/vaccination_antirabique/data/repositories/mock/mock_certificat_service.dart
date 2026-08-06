import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/patient_antirabique_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/tracabilite/certificat_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/services/certificat_service.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/patient_antirabique_repository.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/protocole_repository.dart';
import 'package:epidemiology_antirabic/injection_container.dart' as di;

class MockCertificatService implements CertificatService {
  @override
  Future<CertificatModel> genererCertificat(String patientId) async {
    final patientRepo = di.sl<PatientAntirabiqueRepository>();
    final protocoleRepo = di.sl<ProtocoleRepository>();
    final patient = await patientRepo.getPatientById(patientId);
    final protocole = await protocoleRepo.getProtocole(patientId);
    final administrees = protocole.doses.where((d) => d.estAdministree).toList();
    return CertificatModel(
      id: 'CERT-${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      patientNom: patient?.nomComplet ?? 'N/R',
      patientAge: patient?.age ?? 0,
      dateExposition: patient?.dateExposition ?? '',
      typeExposition: patient?.typeExposition?.label ?? 'N/R',
      categorieExposition: patient?.categorieExposition?.label ?? 'N/R',
      protocole: protocole.type.label,
      doses: administrees.map((d) => DoseCertificat(
        numeroDose: d.numeroDose,
        dateAdministration: d.dateReelle ?? d.datePrevue,
        numeroLot: d.numeroLot ?? 'N/R',
        administrateur: d.administrateurNom ?? 'N/R',
        voie: d.voieAdministration ?? 'IM',
      )).toList(),
      rigAdministree: protocole.rigAdministree,
      rigLot: protocole.rigNumeroLot,
      centre: 'Centre Antirabique',
      medecinResponsable: 'Dr. Mansouri',
      dateEmission: DateTime.now().toIso8601String().split('T')[0],
      observations: patient?.observations,
    );
  }

  @override
  Future<String> genererHtml(CertificatModel c) async {
    final dosesHtml = c.doses.map((d) => '''
      <tr>
        <td style="padding:6px 12px;border:1px solid #ccc;text-align:center">${d.numeroDose}</td>
        <td style="padding:6px 12px;border:1px solid #ccc;text-align:center">${d.dateAdministration}</td>
        <td style="padding:6px 12px;border:1px solid #ccc;text-align:center">${d.numeroLot}</td>
        <td style="padding:6px 12px;border:1px solid #ccc;text-align:center">${d.administrateur}</td>
        <td style="padding:6px 12px;border:1px solid #ccc;text-align:center">${d.voie}</td>
      </tr>
    ''').join('\n');

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Certificat de Vaccination Antirabique</title>
  <style>
    body { font-family: 'Inter', 'Helvetica Neue', sans-serif; margin: 0; padding: 40px; color: #1A1515; }
    .header { text-align: center; margin-bottom: 32px; border-bottom: 3px solid #B71C1C; padding-bottom: 20px; }
    .header h1 { color: #B71C1C; font-size: 22px; margin: 8px 0; }
    .header h2 { font-size: 16px; color: #6B6565; font-weight: 400; margin: 4px 0; }
    .header .centre { font-size: 13px; color: #8C8787; }
    .badge-rig { display:inline-block; background:#F0FDF4; color:#16A34A; padding:2px 10px; border-radius:6px; font-size:12px; font-weight:600; }
    .info-table { width:100%; border-collapse: collapse; margin: 20px 0; }
    .info-table td { padding: 8px 12px; border: 1px solid #EDE7E7; font-size: 13px; }
    .info-table td:first-child { font-weight: 600; background: #F8F6F6; width: 30%; }
    table.doses { width:100%; border-collapse: collapse; margin: 20px 0; }
    table.doses th { background: #B71C1C; color: white; padding: 10px 12px; font-size: 13px; text-align: center; }
    .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #EDE7E7; font-size: 12px; color: #8C8787; }
    .signature { margin-top: 40px; }
    .signature .line { width: 250px; border-top: 1px solid #1A1515; margin-top: 50px; padding-top: 6px; font-size: 13px; }
  </style>
</head>
<body>
  <div class="header">
    <h1>RÉPUBLIQUE ALGÉRIENNE DÉMOCRATIQUE ET POPULAIRE</h1>
    <h2>Ministère de la Santé · Service d'Épidémiologie</h2>
    <div class="centre">${c.centre} — ${c.dateEmission}</div>
  </div>

  <h1 style="font-size:20px;color:#B71C1C;text-align:center;">CERTIFICAT DE VACCINATION ANTIRABIQUE</h1>

  <table class="info-table">
    <tr><td>Patient</td><td>${c.patientNom} (${c.patientAge} ans)</td></tr>
    <tr><td>Date d'exposition</td><td>${c.dateExposition}</td></tr>
    <tr><td>Type d'exposition</td><td>${c.typeExposition}</td></tr>
    <tr><td>Catégorie</td><td>${c.categorieExposition}</td></tr>
    <tr><td>Protocole vaccinal</td><td>${c.protocole} ${c.rigAdministree ? '<span class="badge-rig">RIG administrée</span>' : ''}</td></tr>
    ${c.rigAdministree && c.rigLot != null ? '<tr><td>Lot RIG</td><td>${c.rigLot}</td></tr>' : ''}
  </table>

  <h3 style="color:#B71C1C;font-size:15px;">Doses administrées</h3>
  <table class="doses">
    <thead><tr><th>N°</th><th>Date</th><th>Lot vaccin</th><th>Administrateur</th><th>Voie</th></tr></thead>
    <tbody>$dosesHtml</tbody>
  </table>

  ${c.observations != null ? '<p style="font-size:13px;color:#6B6565;"><strong>Observations :</strong> ${c.observations}</p>' : ''}

  <div class="signature">
    <div class="line">Cachet et signature du médecin responsable</div>
  </div>

  <div class="footer">
    <p>Ce certificat atteste que le patient a reçu la prophylaxie post-exposition antirabique complète conformément aux recommandations de l'OMS.</p>
    <p>Document émis le ${c.dateEmission} — ${c.medecinResponsable}</p>
  </div>
</body>
</html>
''';
  }
}
