import '../../../domain/repositories/tetanus_repository.dart';
import '../../models/tetanus_models.dart';

class MockTetanusRepository implements TetanusRepository {
  final List<TetanusPatientModel> _patients;

  MockTetanusRepository()
      : _patients = _generateMockPatients();

  @override
  List<TetanusPatientModel> getPatients() => _patients;

  @override
  TetanusPatientModel? getPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, int> getDashboardCounts() {
    return {
      'total': _patients.length,
      'enCours': _patients.where((p) => p.statutDossier == TetanusDossierStatut.enCours).length,
      'urgent': _patients.where((p) => p.estUrgent).length,
      'clos': _patients.where((p) => p.statutDossier == TetanusDossierStatut.suiviClos).length,
    };
  }
}

List<TetanusPatientModel> _generateMockPatients() {
  return [
    _patient1Ajour(),
    _patient2Incomplet(),
    _patient3Inconnu(),
    _patient4Risque(),
    _patient5Clos(),
    _patient6TetaniegeneSuivi(),
  ];
}

// Cas 1 : Patient à jour, plaie propre → simple surveillance
TetanusPatientModel _patient1Ajour() {
  return TetanusPatientModel(
    id: 'TET-001',
    nomComplet: 'Kadi Amel',
    age: 34,
    sexe: 'F',
    dateBlessure: '28/07/2026',
    typePlaie: TetanusWoundType.propre,
    localisation: 'Avant-bras droit',
    plaieProfonde: false,
    plaieSouillee: false,
    corpsEtranger: false,
    soinsLocauxRealises: true,
    delaiConsultation: '< 6h',
    statutVaccinal: TetanusVaccinStatus.aJour,
    derniereDoseDate: '2023-03-15',
    nombreDosesConnues: 5,
    decision: TetanusDecision.simpleSurveillance,
    statutDossier: TetanusDossierStatut.enCours,
    immunoglobulines: false,
    observations: 'Patiente à jour. Dernier rappel en mars 2023. Plaie propre superficielle.',
    dateCreation: '28/07/2026',
    historique: [
      TetanusActeModel(
        id: 'ACT-001', patientId: 'TET-001',
        dateActe: '2020-04-10', typeActe: 'Rappel VAT',
        vaccin: 'VAT (Anatoxine tétanique)',
        numeroLot: 'L20T045', dateExpiration: '2024-04-10',
        administrateur: 'Dr. Benali', centre: 'EPSP Alger',
      ),
      TetanusActeModel(
        id: 'ACT-002', patientId: 'TET-001',
        dateActe: '2023-03-15', typeActe: 'Rappel VAT',
        vaccin: 'VAT (Anatoxine tétanique)',
        numeroLot: 'L23T102', dateExpiration: '2026-03-15',
        administrateur: 'Dr. Benali', centre: 'EPSP Alger',
      ),
    ],
  );
}

// Cas 2 : Statut incomplet, plaie à risque → rappel indiqué
TetanusPatientModel _patient2Incomplet() {
  return TetanusPatientModel(
    id: 'TET-002',
    nomComplet: 'Messaoud Sofiane',
    age: 52,
    sexe: 'M',
    dateBlessure: '29/07/2026',
    typePlaie: TetanusWoundType.aRisque,
    localisation: 'Main gauche',
    plaieProfonde: false,
    plaieSouillee: true,
    corpsEtranger: false,
    soinsLocauxRealises: true,
    delaiConsultation: '< 12h',
    statutVaccinal: TetanusVaccinStatus.incomplet,
    derniereDoseDate: '2018-11-20',
    nombreDosesConnues: 3,
    decision: TetanusDecision.rappelIndique,
    statutDossier: TetanusDossierStatut.enCours,
    immunoglobulines: false,
    observations: 'Patient avec 3 doses documentées. Dernier rappel > 5 ans. Plaie souillée modérée.',
    dateCreation: '29/07/2026',
    historique: [
      TetanusActeModel(
        id: 'ACT-003', patientId: 'TET-002',
        dateActe: '2005-06-01', typeActe: 'Primovaccination 1',
        vaccin: 'VAT', numeroLot: 'L05T011', administrateur: 'Dr. Rahmani',
        centre: 'Polyclinique Bab El Oued',
      ),
      TetanusActeModel(
        id: 'ACT-004', patientId: 'TET-002',
        dateActe: '2018-11-20', typeActe: 'Rappel VAT',
        vaccin: 'VAT', numeroLot: 'L18T087', administrateur: 'Dr. Rahmani',
        centre: 'Polyclinique Bab El Oued',
      ),
    ],
  );
}

// Cas 3 : Statut vaccinal inconnu, plaie propre → VAT
TetanusPatientModel _patient3Inconnu() {
  return TetanusPatientModel(
    id: 'TET-003',
    nomComplet: 'Benameur Nadia',
    age: 68,
    sexe: 'F',
    dateBlessure: '27/07/2026',
    typePlaie: TetanusWoundType.propre,
    localisation: 'Jambe droite',
    plaieProfonde: false,
    plaieSouillee: true,
    corpsEtranger: false,
    soinsLocauxRealises: true,
    delaiConsultation: '< 24h',
    statutVaccinal: TetanusVaccinStatus.inconnu,
    derniereDoseDate: null,
    nombreDosesConnues: null,
    decision: TetanusDecision.vaccinationComplete,
    statutDossier: TetanusDossierStatut.enCours,
    immunoglobulines: false,
    observations: 'Patiente âgée sans carnet de vaccination. Plaie propre avec souillure minime.',
    dateCreation: '27/07/2026',
    historique: [],
  );
}

// Cas 4 : Plaie tétanigène, statut inconnu → VAT + Ig urgent
TetanusPatientModel _patient4Risque() {
  return TetanusPatientModel(
    id: 'TET-004',
    nomComplet: 'Toumi Rabeh',
    age: 45,
    sexe: 'M',
    dateBlessure: '30/07/2026',
    typePlaie: TetanusWoundType.tetanigene,
    localisation: 'Pied gauche',
    plaieProfonde: true,
    plaieSouillee: true,
    corpsEtranger: true,
    soinsLocauxRealises: false,
    delaiConsultation: '< 6h',
    statutVaccinal: TetanusVaccinStatus.inconnu,
    derniereDoseDate: null,
    nombreDosesConnues: null,
    decision: TetanusDecision.vaccinationEtIg,
    statutDossier: TetanusDossierStatut.enCours,
    immunoglobulines: true,
    observations: 'Plaie perforante du pied avec corps étranger+++, souillée par terre agricole. '
        'Statut vaccinal inconnu. Urgence : VAT + Ig immédiat.',
    dateCreation: '30/07/2026',
    historique: [],
  );
}

// Cas 5 : Acte déjà administré, suivi clos
TetanusPatientModel _patient5Clos() {
  return TetanusPatientModel(
    id: 'TET-005',
    nomComplet: 'Zitouni Farida',
    age: 29,
    sexe: 'F',
    dateBlessure: '15/07/2026',
    typePlaie: TetanusWoundType.aRisque,
    localisation: 'Coude droit',
    plaieProfonde: false,
    plaieSouillee: true,
    corpsEtranger: false,
    soinsLocauxRealises: true,
    delaiConsultation: '< 12h',
    statutVaccinal: TetanusVaccinStatus.incomplet,
    derniereDoseDate: '2019-02-10',
    nombreDosesConnues: 3,
    decision: TetanusDecision.rappelIndique,
    statutDossier: TetanusDossierStatut.suiviClos,
    immunoglobulines: false,
    observations: 'Rappel VAT administré le 15/07/2026. Suivi terminé.',
    dateCreation: '15/07/2026',
    historique: [
      TetanusActeModel(
        id: 'ACT-005', patientId: 'TET-005',
        dateActe: '2019-02-10', typeActe: 'Rappel VAT',
        vaccin: 'VAT', numeroLot: 'L19T023', administrateur: 'Dr. Merabet',
        centre: 'EPSP Alger',
      ),
      TetanusActeModel(
        id: 'ACT-006', patientId: 'TET-005',
        dateActe: '15/07/2026', typeActe: 'Rappel VAT',
        vaccin: 'VAT (Anatoxine tétanique)',
        numeroLot: 'L26T058', dateExpiration: '2028-07-15',
        administrateur: 'Dr. Merabet', centre: 'EPSP Alger',
        observations: 'Rappel post-exposition administré sans complication.',
      ),
    ],
  );
}

// Cas 6 : Plaie tétanigène, vaccin à jour partiel, rappel effectué, suivi en cours
TetanusPatientModel _patient6TetaniegeneSuivi() {
  return TetanusPatientModel(
    id: 'TET-006',
    nomComplet: 'Haddad Samir',
    age: 37,
    sexe: 'M',
    dateBlessure: '25/07/2026',
    typePlaie: TetanusWoundType.tetanigene,
    localisation: 'Avant-bras gauche',
    plaieProfonde: true,
    plaieSouillee: true,
    corpsEtranger: true,
    soinsLocauxRealises: true,
    delaiConsultation: '< 12h',
    statutVaccinal: TetanusVaccinStatus.incomplet,
    derniereDoseDate: '2020-08-05',
    nombreDosesConnues: 4,
    decision: TetanusDecision.vaccinationEtIg,
    statutDossier: TetanusDossierStatut.enCours,
    immunoglobulines: true,
    observations: 'Plaie tétanigène avec corps étranger. 4 doses antérieures, dernier rappel > 5 ans. '
        'VAT + Ig administrées le jour même. À surveiller.',
    dateCreation: '25/07/2026',
    historique: [
      TetanusActeModel(
        id: 'ACT-007', patientId: 'TET-006',
        dateActe: '2020-08-05', typeActe: 'Rappel VAT',
        vaccin: 'VAT', numeroLot: 'L20T091', administrateur: 'Dr. Ouahab',
        centre: 'Polyclinique Kouba',
      ),
      TetanusActeModel(
        id: 'ACT-008', patientId: 'TET-006',
        dateActe: '25/07/2026', typeActe: 'VAT + Ig',
        vaccin: 'VAT + Immunoglobulines antitétaniques',
        numeroLot: 'L26T071', dateExpiration: '2028-07-25',
        administrateur: 'Dr. Ouahab', centre: 'Polyclinique Kouba',
        observations: 'VAT IM + Ig dose unique administrée en urgence.',
      ),
    ],
  );
}
