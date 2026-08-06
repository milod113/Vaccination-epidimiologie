import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/suivi_clinique_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/suivi_clinique_repository.dart';

class MockSuiviCliniqueRepository implements SuiviCliniqueRepository {
  final Map<String, List<SuiviCliniqueModel>> _data = {};

  MockSuiviCliniqueRepository() {
    _initData();
  }

  void _initData() {
    _data['PAT-001'] = [
      SuiviCliniqueModel(
        id: 'SC-001-1',
        patientId: 'PAT-001',
        date: '2026-07-20',
        auteur: 'Dr. Mansouri',
        note: 'Première dose administrée sans incident. Patient légèrement anxieux. Bonne tolérance.',
        effetIndesirable: EffetIndesirableType.aucun,
      ),
      SuiviCliniqueModel(
        id: 'SC-001-2',
        patientId: 'PAT-001',
        date: '2026-07-23',
        auteur: 'Dr. Mansouri',
        note: 'Deuxième dose. Douleur légère au point d\'injection. Pas de signe d\'infection locale.',
        effetIndesirable: EffetIndesirableType.local,
        descriptionEffet: 'Érythème local 2 cm, résolutif spontanément.',
      ),
    ];

    _data['PAT-003'] = [
      SuiviCliniqueModel(
        id: 'SC-003-1',
        patientId: 'PAT-003',
        date: '2026-07-10',
        auteur: 'Dr. Mansouri',
        note: 'Morsure multiple avant-bras. Administration première dose. Pansement protecteur appliqué.',
        effetIndesirable: EffetIndesirableType.aucun,
      ),
      SuiviCliniqueModel(
        id: 'SC-003-2',
        patientId: 'PAT-003',
        date: '2026-07-17',
        auteur: 'Dr. Bensaid',
        note: 'Troisième dose. Patient signale des céphalées modérées depuis 24h. Pas de fièvre. Surveillance simple.',
        effetIndesirable: EffetIndesirableType.general,
        descriptionEffet: 'Céphalées modérées, sans fièvre. Paracétamol si besoin.',
      ),
    ];

    _data['PAT-007'] = [
      SuiviCliniqueModel(
        id: 'SC-007-1',
        patientId: 'PAT-007',
        date: '2026-07-18',
        auteur: 'Dr. Mansouri',
        note: 'Patient diabétique de type 2. Morsure mollet. Dose J0 administrée. Surveillance glycémique recommandée.',
        effetIndesirable: EffetIndesirableType.aucun,
      ),
      SuiviCliniqueModel(
        id: 'SC-007-2',
        patientId: 'PAT-007',
        date: '2026-07-21',
        auteur: 'Dr. Mansouri',
        note: 'Dose J3 reportée pour avis médical. Patient sous anticoagulants (AVK). Vérification INR nécessaire avant administration.',
        effetIndesirable: EffetIndesirableType.aucun,
        doseReportee: true,
        motifReport: 'Patient sous anticoagulants. INR à vérifier.',
        dateNouveauRdv: '2026-07-25',
      ),
    ];

    _data['PAT-005'] = [
      SuiviCliniqueModel(
        id: 'SC-005-1',
        patientId: 'PAT-005',
        date: '2026-07-05',
        auteur: 'Dr. Mansouri',
        note: 'Exposition professionnelle (vétérinaire). Contact salivaire oeil. Schéma Zagreb initié. RAS.',
        effetIndesirable: EffetIndesirableType.aucun,
      ),
      SuiviCliniqueModel(
        id: 'SC-005-2',
        patientId: 'PAT-005',
        date: '2026-07-12',
        auteur: 'Dr. Mansouri',
        note: 'Dose J7 (3e dose Zagreb). Patient signale une douleur locale. Examen sans particularité.',
        effetIndesirable: EffetIndesirableType.local,
        descriptionEffet: 'Douleur au site d\'injection EVA 2/10.',
      ),
    ];
  }

  @override
  Future<List<SuiviCliniqueModel>> getSuiviClinique(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_data[patientId] ?? []);
  }

  @override
  Future<void> ajouterNote(SuiviCliniqueModel note) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _data.putIfAbsent(note.patientId, () => []);
    _data[note.patientId]!.insert(0, note);
  }
}
