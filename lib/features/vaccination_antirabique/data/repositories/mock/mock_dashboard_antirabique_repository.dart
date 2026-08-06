import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/dashboard_antirabique_models.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/dashboard_antirabique_repository.dart';

class MockDashboardAntirabiqueRepository implements DashboardAntirabiqueRepository {
  @override
  Future<DashboardAntirabiqueData> getDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DashboardAntirabiqueData(
      patientsEnSuivi: 9,
      vaccinationsDuJour: 5,
      patientsEnRetard: 2,
      alertesCritiques: 3,
      repartitionProtocole: const RepartitionProtocole(essen: 4, essenReduit: 3, zagreb: 3, ipc: 1),
      alertes: [
        AlerteAntirabiqueModel(
          type: 'Perdu de vue',
          message: 'Patient Messaoudi Khaled (PAT-009) non revenu depuis J0. Risque de rupture de suivi.',
          severite: AlerteSeverite.haute,
          patientNom: 'Messaoudi Khaled',
        ),
        AlerteAntirabiqueModel(
          type: 'Dose reportée',
          message: 'Patient Guedjati Youcef (PAT-007) : dose J3 reportée, avis médical requis pour comorbidité.',
          severite: AlerteSeverite.haute,
          patientNom: 'Guedjati Youcef',
        ),
        AlerteAntirabiqueModel(
          type: 'Prochain RDV',
          message: 'Patient Ziani Mohamed (PAT-003) : dose J14 prévue aujourd\'hui.',
          severite: AlerteSeverite.moyenne,
          patientNom: 'Ziani Mohamed',
        ),
        AlerteAntirabiqueModel(
          type: 'Animal errant',
          message: 'Patient Benali Ahmed (PAT-001) : animal non capturé, vérifier statut épidémiologique.',
          severite: AlerteSeverite.moyenne,
          patientNom: 'Benali Ahmed',
        ),
      ],
      vaccinationsDuJourList: [
        VaccinationDuJour(patientNom: 'Ziani Mohamed', protocole: 'Essen', numeroDose: 4, statut: 'Prévu'),
        VaccinationDuJour(patientNom: 'Guedjati Youcef', protocole: 'Essen', numeroDose: 3, statut: 'À confirmer'),
        VaccinationDuJour(patientNom: 'Belaid Sarra', protocole: 'Essen', numeroDose: 2, statut: 'Prévu'),
        VaccinationDuJour(patientNom: 'Cherifi Ines', protocole: 'IPC', numeroDose: 5, statut: 'Prévu'),
        VaccinationDuJour(patientNom: 'Kadi Amel', protocole: 'Essen réduit', numeroDose: 2, statut: "Aujourd'hui"),
      ],
    );
  }
}
