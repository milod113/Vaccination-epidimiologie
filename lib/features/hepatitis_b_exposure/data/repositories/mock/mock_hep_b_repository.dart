import '../../../domain/repositories/hep_b_repository.dart';
import '../../models/hep_b_models.dart';

class MockHepBRepository implements HepBRepository {
  static final _now = DateTime.now();

  static final List<HepBExposurePatient> _mockPatients = [
    HepBExposurePatient(
      id: 'HEPB-001',
      nom: 'Rania',
      prenom: 'Amira',
      age: 28,
      typeExposition: HepBExposureType.aes,
      dateExposition: _now.subtract(const Duration(days: 2)),
      sourceExposition: 'Aiguille souillée (patient Ag HBs+)',
      statutVaccinal: HepBVaccinationStatus.nonVaccine,
      serologieInitiale: const HepBSerologie(
        fait: true,
        datePrelevement: null,
        agHbs: 'Négatif',
        acAntiHbs: '< 2 UI/L',
        acAntiHbc: 'Négatif',
        interpretation: 'Non immun, non infecté',
      ),
      niveauRisque: HepBRiskLevel.urgent,
      decision: 'Vaccination post-exposition + Ig VHB dans les 72h',
      prochaineAction: 'Administrer Ig VHB + Dose 1 vaccin VHB',
      doses: [
        const HepBDose(numero: 1, produit: 'Engerix B 20µg', statut: HepBDoseStatus.planifie),
        const HepBDose(numero: 2, produit: 'Engerix B 20µg', statut: HepBDoseStatus.planifie),
        const HepBDose(numero: 3, produit: 'Engerix B 20µg', statut: HepBDoseStatus.planifie),
      ],
      statutDossier: HepBDossierStatut.enCours,
      dateCreation: _now.subtract(const Duration(days: 2)),
    ),
    HepBExposurePatient(
      id: 'HEPB-002',
      nom: 'Yacine',
      prenom: 'Brahim',
      age: 45,
      typeExposition: HepBExposureType.contactSanguin,
      dateExposition: _now.subtract(const Duration(days: 14)),
      sourceExposition: 'Projection sanguine sur muqueuse oculaire',
      statutVaccinal: HepBVaccinationStatus.vaccineReponseConnue,
      serologieInitiale: const HepBSerologie(
        fait: true,
        agHbs: 'Négatif',
        acAntiHbs: '> 1 000 UI/L',
        acAntiHbc: 'Négatif',
        interpretation: 'Immunisé (réponse vaccinale protectrice)',
      ),
      niveauRisque: HepBRiskLevel.standard,
      decision: 'Aucune vaccination nécessaire. Contrôle sérologique à 1 mois.',
      prochaineAction: 'Planifier sérologie M1',
      doses: [
        const HepBDose(numero: 1, produit: 'HBVAXPRO 40µg', statut: HepBDoseStatus.administre, dateAdministration: null),
        const HepBDose(numero: 2, produit: 'HBVAXPRO 40µg', statut: HepBDoseStatus.administre, dateAdministration: null),
        const HepBDose(numero: 3, produit: 'HBVAXPRO 40µg', statut: HepBDoseStatus.administre, dateAdministration: null),
      ],
      statutDossier: HepBDossierStatut.enCours,
      dateCreation: _now.subtract(const Duration(days: 14)),
    ),
    HepBExposurePatient(
      id: 'HEPB-003',
      nom: 'Fatima',
      prenom: 'Dalila',
      age: 32,
      typeExposition: HepBExposureType.mereAgHbsPlus,
      dateExposition: _now.subtract(const Duration(days: 45)),
      sourceExposition: 'Mère Ag HBs+ (dépistage prénatal)',
      statutVaccinal: HepBVaccinationStatus.inconnu,
      niveauRisque: HepBRiskLevel.eleve,
      decision: 'Sérologie urgente + vaccination immédiate selon résultats',
      prochaineAction: 'Effectuer sérologie VHB en urgence',
      doses: [],
      statutDossier: HepBDossierStatut.enCours,
      dateCreation: _now.subtract(const Duration(days: 45)),
    ),
    HepBExposurePatient(
      id: 'HEPB-004',
      nom: 'Karim',
      prenom: 'Hocine',
      age: 37,
      typeExposition: HepBExposureType.aes,
      dateExposition: _now.subtract(const Duration(days: 90)),
      sourceExposition: 'Blessure par scalpel en chirurgie',
      statutVaccinal: HepBVaccinationStatus.vaccineIncomplet,
      serologieInitiale: const HepBSerologie(
        fait: true,
        agHbs: 'Négatif',
        acAntiHbs: '45 UI/L',
        acAntiHbc: 'Négatif',
        interpretation: 'Réponse vaccinale faible (non protectrice < 100 UI/L)',
      ),
      serologieM3: const HepBSerologie(
        fait: true,
        agHbs: 'Négatif',
        acAntiHbs: '780 UI/L',
        acAntiHbc: 'Négatif',
        interpretation: 'Bonne réponse après rappel — immunisé',
      ),
      niveauRisque: HepBRiskLevel.eleve,
      decision: 'Rappel vaccin VHB + contrôle sérologique à M3',
      prochaineAction: 'Suivi terminé — bonne réponse vaccinale',
      doses: [
        const HepBDose(numero: 1, produit: 'Engerix B 20µg', statut: HepBDoseStatus.administre, dateAdministration: null),
        const HepBDose(numero: 2, produit: 'Engerix B 20µg', statut: HepBDoseStatus.administre, dateAdministration: null),
        const HepBDose(numero: 3, produit: 'Engerix B 20µg', statut: HepBDoseStatus.administre, dateAdministration: null),
      ],
      statutDossier: HepBDossierStatut.suiviTermine,
      dateCreation: _now.subtract(const Duration(days: 90)),
    ),
    HepBExposurePatient(
      id: 'HEPB-005',
      nom: 'Said',
      prenom: 'Nassim',
      age: 52,
      typeExposition: HepBExposureType.aes,
      dateExposition: _now.subtract(const Duration(days: 7)),
      sourceExposition: 'Piqûre avec aiguille de suture',
      statutVaccinal: HepBVaccinationStatus.vaccineReponseInconnue,
      niveauRisque: HepBRiskLevel.standard,
      decision: 'Sérologie initiale + vaccination si non immun',
      prochaineAction: 'Prélever sérologie VHB (Ag HBs, Ac anti-HBs, Ac anti-HBc)',
      doses: [],
      statutDossier: HepBDossierStatut.enCours,
      dateCreation: _now.subtract(const Duration(days: 7)),
    ),
  ];

  @override
  List<HepBExposurePatient> getPatients() => _mockPatients;

  @override
  HepBExposurePatient? getPatientById(String id) {
    try {
      return _mockPatients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, int> getDashboardCounts() => {
    'total': _mockPatients.length,
    'enCours': _mockPatients.where((p) => p.statutDossier == HepBDossierStatut.enCours).length,
    'urgent': _mockPatients.where((p) => p.niveauRisque == HepBRiskLevel.urgent).length,
    'serologieEnAttente': _mockPatients.where((p) => p.serologieEnAttente).length,
    'suiviTermine': _mockPatients.where((p) => p.statutDossier == HepBDossierStatut.suiviTermine).length,
    'perduDeVue': _mockPatients.where((p) => p.statutDossier == HepBDossierStatut.perduDeVue).length,
  };
}
