import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/patient_antirabique_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/patient_antirabique_repository.dart';

class MockPatientAntirabiqueRepository implements PatientAntirabiqueRepository {
  static final List<PatientAntirabiqueModel> _patients = [
    PatientAntirabiqueModel(
      id: 'PAT-001',
      nomComplet: 'Benali Ahmed',
      age: 34,
      sexe: 'Masculin',
      telephone: '0550 12 34 56',
      dateExposition: '2026-07-20',
      typeExposition: TypeExposition.morsureChien,
      categorieExposition: CategorieExposition.categorieIII,
      protocole: ProtocoleType.essen,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-30',
      animalSource: 'Chien errant',
      animalStatut: AnimauxStatut.inconnu,
      animalCapture: false,
      siteMorsure: 'Jambe droite - morsure profonde pénétrante',
      rigAdministree: true,
      immunocompromis: false,
      observations: 'Morsure profonde à la jambe droite. RIG administrée à J0. Patient sous antibiotiques.',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-002',
      nomComplet: 'Mokhtari Fatima',
      age: 28,
      sexe: 'Féminin',
      telephone: '0551 98 76 54',
      dateExposition: '2026-07-15',
      typeExposition: TypeExposition.griffure,
      categorieExposition: CategorieExposition.categorieII,
      protocole: ProtocoleType.zagreb,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-31',
      animalSource: 'Chat domestique',
      animalStatut: AnimauxStatut.observeSurveillance,
      animalCapture: true,
      siteMorsure: 'Bras gauche - griffures superficielles multiples',
      rigAdministree: false,
      immunocompromis: false,
      observations: 'Griffure au bras gauche. Chat sous surveillance vétérinaire 14 jours. Schéma Zagreb privilégié pour meilleure compliance.',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-003',
      nomComplet: 'Ziani Mohamed',
      age: 52,
      sexe: 'Masculin',
      telephone: '0552 34 56 78',
      dateExposition: '2026-07-10',
      typeExposition: TypeExposition.morsureChien,
      categorieExposition: CategorieExposition.categorieIII,
      protocole: ProtocoleType.essen,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-28',
      animalSource: 'Chien de garde',
      animalStatut: AnimauxStatut.observeSurveillance,
      animalCapture: true,
      siteMorsure: 'Avant-bras gauche - morsure multiple',
      rigAdministree: true,
      immunocompromis: false,
      observations: 'Morsure multiple à l\'avant-bras. Vaccin antitétanique administré. RIG infiltrée dans les plaies.',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-004',
      nomComplet: 'Belaid Sarra',
      age: 9,
      sexe: 'Féminin',
      telephone: '0553 45 67 89',
      dateExposition: '2026-07-22',
      typeExposition: TypeExposition.morsureChien,
      categorieExposition: CategorieExposition.categorieII,
      protocole: ProtocoleType.essenReduit,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-29',
      animalSource: 'Chien de voisinage',
      animalStatut: AnimauxStatut.suspect,
      animalCapture: false,
      siteMorsure: 'Main droite - 2 morsures modérées',
      rigAdministree: false,
      immunocompromis: false,
      observations: 'Morsure modérée à la main droite. Patiente pédiatrique 9 ans. Schéma Essen réduit 4 doses (recommandation OMS 2018 pour immunocompétents).',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-005',
      nomComplet: 'Hammouchi Rachid',
      age: 45,
      sexe: 'Masculin',
      telephone: '0554 56 78 90',
      dateExposition: '2026-07-05',
      typeExposition: TypeExposition.contactMuqueux,
      categorieExposition: CategorieExposition.categorieIII,
      protocole: ProtocoleType.zagreb,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-27',
      animalSource: 'Chien errant',
      animalStatut: AnimauxStatut.inconnu,
      animalCapture: false,
      siteMorsure: 'Œil droit - projection salivaire conjonctivale',
      rigAdministree: true,
      immunocompromis: false,
      observations: 'Contact salivaire au niveau conjonctival. Vétérinaire de profession. RIG administrée. Protocole Zagreb (meilleure compliance pour patient actif).',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-006',
      nomComplet: 'Khelifi Amira',
      age: 22,
      sexe: 'Féminin',
      telephone: '0555 67 89 01',
      dateExposition: '2026-06-28',
      typeExposition: TypeExposition.morsureChat,
      categorieExposition: CategorieExposition.categorieII,
      protocole: ProtocoleType.essenReduit,
      statut: StatutSuivi.termine,
      prochainRendezVous: null,
      animalSource: 'Chat errant',
      animalStatut: AnimauxStatut.inconnu,
      animalCapture: false,
      siteMorsure: 'Avant-bras droit - morsure unique',
      rigAdministree: false,
      immunocompromis: false,
      observations: 'Schéma vaccinal complet Essen réduit 4 doses. Suivi terminé. Patiente immunocompétente.',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-007',
      nomComplet: 'Guedjati Youcef',
      age: 67,
      sexe: 'Masculin',
      telephone: '0556 78 90 12',
      dateExposition: '2026-07-18',
      typeExposition: TypeExposition.morsureChien,
      categorieExposition: CategorieExposition.categorieIII,
      protocole: ProtocoleType.essen,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-25',
      animalSource: 'Chien de ferme',
      animalStatut: AnimauxStatut.suspect,
      animalCapture: false,
      siteMorsure: 'Mollet gauche - plaie profonde',
      rigAdministree: true,
      immunocompromis: true,
      observations: 'Patient diabétique type 2, immunocompromis. Morsure au mollet. Schéma Essen 5 doses (obligatoire pour immunodéprimé selon OMS). RIG administrée. Surveillance rapprochée.',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-008',
      nomComplet: 'Bouzid Nadia',
      age: 31,
      sexe: 'Féminin',
      telephone: '0557 89 01 23',
      dateExposition: '2026-07-25',
      typeExposition: TypeExposition.morsureChat,
      categorieExposition: CategorieExposition.categorieII,
      protocole: ProtocoleType.zagreb,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-08-01',
      animalSource: 'Chat domestique',
      animalStatut: AnimauxStatut.observeSurveillance,
      animalCapture: true,
      siteMorsure: 'Main gauche - 3 griffures',
      rigAdministree: false,
      immunocompromis: false,
      observations: 'Première dose (×2 sites) administrée J0. Prochaine dose J7. Chat sous surveillance 14 jours.',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-009',
      nomComplet: 'Messaoudi Khaled',
      age: 17,
      sexe: 'Masculin',
      telephone: '0558 90 12 34',
      dateExposition: '2026-07-12',
      typeExposition: TypeExposition.morsureAutreAnimal,
      categorieExposition: CategorieExposition.categorieIII,
      protocole: ProtocoleType.essen,
      statut: StatutSuivi.perduDeVue,
      prochainRendezVous: null,
      animalSource: 'Renard',
      animalStatut: AnimauxStatut.confirme,
      animalCapture: false,
      siteMorsure: 'Main droite - morsure profonde',
      rigAdministree: true,
      immunocompromis: false,
      observations: 'ALERTE — PATIENT EN RETARD. Mordue par renard confirmé rabique. RIG OK à J0. Dose J0 administrée. Ne s\'est pas présenté pour J3. Protocole ESSEN 5 doses obligatoire (animal confirmé).',
    ),
    PatientAntirabiqueModel(
      id: 'PAT-010',
      nomComplet: 'Cherifi Ines',
      age: 39,
      sexe: 'Féminin',
      telephone: '0559 01 23 45',
      dateExposition: '2026-07-08',
      typeExposition: TypeExposition.professionnelle,
      categorieExposition: CategorieExposition.categorieII,
      protocole: ProtocoleType.ipc,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-28',
      animalSource: 'Chien de laboratoire',
      animalStatut: AnimauxStatut.vaccine,
      animalCapture: true,
      siteMorsure: 'Main droite - griffure en manipulant prélèvement',
      rigAdministree: false,
      immunocompromis: false,
      observations: 'Technicienne de laboratoire. Exposition professionnelle. Schéma IPC voie ID (3 visites, 6 doses fractionnées) pour minimiser absentéisme. Chien vacciné à jour.',
    ),
    // PAT-011 : dose J3 due AUJOURD'HUI (30 juillet 2026)
    PatientAntirabiqueModel(
      id: 'PAT-011',
      nomComplet: 'Kadi Amel',
      age: 28,
      sexe: 'Féminin',
      telephone: '0559 98 76 54',
      dateExposition: '2026-07-27',
      typeExposition: TypeExposition.morsureChien,
      categorieExposition: CategorieExposition.categorieIII,
      protocole: ProtocoleType.essenReduit,
      statut: StatutSuivi.enCours,
      prochainRendezVous: '2026-07-30',
      animalSource: 'Chien errant',
      animalStatut: AnimauxStatut.inconnu,
      animalCapture: false,
      siteMorsure: 'Mollet gauche - morsure unique profonde, saignement abondant',
      rigAdministree: true,
      immunocompromis: false,
      observations: 'Mordue par un chien errant dans la rue. Catégorie III — RIG administrée aux urgences. Schéma Essen réduit (J0-J3-J7-J14). Dose J0 reçue le 27/07, dose J3 due aujourd\'hui 30/07.',
    ),
  ];

  @override
  Future<List<PatientAntirabiqueModel>> getPatients() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_patients);
  }

  @override
  Future<PatientAntirabiqueModel?> getPatientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _patients.where((p) => p.id == id).firstOrNull;
  }

  /// Génère le prochain identifiant PAT-XXX dans l'ordre numérique croissant.
  String _nextId() {
    final maxNum = _patients
        .map((p) => int.tryParse(p.id.replaceFirst('PAT-', '')))
        .whereType<int>()
        .fold<int>(0, (a, b) => a > b ? a : b);
    return 'PAT-${(maxNum + 1).toString().padLeft(3, '0')}';
  }

  @override
  Future<PatientAntirabiqueModel> createPatient(PatientAntirabiqueModel patient) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final created = patient.copyWith(
      id: patient.id.isEmpty ? _nextId() : patient.id,
      dateCreation: patient.dateCreation ?? DateTime.now().toIso8601String().split('T').first,
    );
    _patients.insert(0, created);
    return created;
  }

  @override
  Future<PatientAntirabiqueModel> savePatient(PatientAntirabiqueModel patient) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final index = _patients.indexWhere((p) => p.id == patient.id);
    if (index >= 0) {
      _patients[index] = patient;
      return patient;
    }
    return createPatient(patient);
  }
}
