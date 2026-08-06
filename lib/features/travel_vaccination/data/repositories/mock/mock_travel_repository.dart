import '../../../domain/repositories/travel_repository.dart';
import '../../models/travel_models.dart';

class MockTravelRepository implements TravelRepository {
  @override
  List<TravelPatient> getProchainsDeparts() => _mockPatients;

  @override
  List<DestinationInfo> getDestinations() => _mockDestinations;

  @override
  int get totalPatients => 22;

  @override
  int get alertCount => 2;

  static final DateTime _now = DateTime.now();

  static final List<TravelPatient> _mockPatients = [
    TravelPatient(
      nom: 'Ahmed',
      prenom: 'Karim',
      destination: 'Sénégal',
      region: 'Afrique subsaharienne',
      depart: _now.add(const Duration(days: 12)),
      vaccins: const [
        VaccinRecommandation(nom: 'Fièvre jaune', obligatoire: true, statut: TravelVaccinationStatus.administre),
        VaccinRecommandation(nom: 'Rage', statut: TravelVaccinationStatus.planifie),
        VaccinRecommandation(nom: 'Hépatite A+B', statut: TravelVaccinationStatus.administre),
        VaccinRecommandation(nom: 'Typhoïde', statut: TravelVaccinationStatus.planifie),
      ],
      conseils: 'Antipaludéen à prescrire (chloroquine-résistance). Rappel DTP à vérifier.',
    ),
    TravelPatient(
      nom: 'Benali',
      prenom: 'Leila',
      destination: 'Thaïlande',
      region: 'Asie du Sud-Est',
      depart: _now.add(const Duration(days: 5)),
      vaccins: const [
        VaccinRecommandation(nom: 'Hépatite A+B', statut: TravelVaccinationStatus.administre),
        VaccinRecommandation(nom: 'Typhoïde', statut: TravelVaccinationStatus.planifie),
        VaccinRecommandation(nom: 'Rage', statut: TravelVaccinationStatus.enRetard),
        VaccinRecommandation(nom: 'Encéphalite japonaise', statut: TravelVaccinationStatus.nonRequis),
      ],
      conseils: 'Risque de dengue en saison humide. Recommander moustiquaire et répulsif.',
    ),
    TravelPatient(
      nom: 'Boumediene',
      prenom: 'Omar',
      destination: 'Brésil',
      region: 'Amérique du Sud',
      depart: _now.add(const Duration(days: 20)),
      vaccins: const [
        VaccinRecommandation(nom: 'Fièvre jaune', obligatoire: true, statut: TravelVaccinationStatus.planifie),
        VaccinRecommandation(nom: 'Rage', statut: TravelVaccinationStatus.planifie),
        VaccinRecommandation(nom: 'Hépatite A+B', statut: TravelVaccinationStatus.administre),
      ],
      conseils: 'Fièvre jaune obligatoire pour l\'entrée. Zones de paludisme à risque modéré.',
    ),
    TravelPatient(
      nom: 'Khelifi',
      prenom: 'Hania',
      destination: 'Inde',
      region: 'Asie du Sud',
      depart: _now.add(const Duration(days: 3)),
      vaccins: const [
        VaccinRecommandation(nom: 'Rage', statut: TravelVaccinationStatus.enRetard),
        VaccinRecommandation(nom: 'Hépatite A+B', statut: TravelVaccinationStatus.enRetard),
        VaccinRecommandation(nom: 'Typhoïde', statut: TravelVaccinationStatus.planifie),
        VaccinRecommandation(nom: 'Encéphalite japonaise', statut: TravelVaccinationStatus.nonRequis),
      ],
      conseils: 'URGENT : Vaccins Rage et Hépatite A+B en retard. Prescrire antipaludéen pour les zones rurales.',
    ),
    TravelPatient(
      nom: 'Mansouri',
      prenom: 'Sofiane',
      destination: 'Vietnam',
      region: 'Asie du Sud-Est',
      depart: _now.add(const Duration(days: 30)),
      vaccins: const [
        VaccinRecommandation(nom: 'Hépatite A+B', statut: TravelVaccinationStatus.administre),
        VaccinRecommandation(nom: 'Typhoïde', statut: TravelVaccinationStatus.planifie),
        VaccinRecommandation(nom: 'Rage', statut: TravelVaccinationStatus.administre),
        VaccinRecommandation(nom: 'Encéphalite japonaise', statut: TravelVaccinationStatus.planifie),
      ],
      conseils: 'Encéphalite japonaise recommandée si séjour > 1 mois en zone rurale.',
    ),
  ];

  static final List<DestinationInfo> _mockDestinations = [
    DestinationInfo(
      pays: 'Sénégal',
      region: 'Afrique subsaharienne',
      vaccinsObligatoires: ['Fièvre jaune'],
      vaccinsRecommandes: ['Hépatite A+B', 'Typhoïde', 'Rage', 'Méningocoque'],
      niveauAlerte: TravelAlertLevel.info,
      messageAlerte: 'Paludisme présent toute l\'année — prophylaxie recommandée',
    ),
    DestinationInfo(
      pays: 'Inde',
      region: 'Asie du Sud',
      vaccinsObligatoires: [],
      vaccinsRecommandes: ['Hépatite A+B', 'Typhoïde', 'Rage', 'Encéphalite japonaise'],
      niveauAlerte: TravelAlertLevel.warning,
      messageAlerte: 'Épidémie de dengue en cours — protection antivectorielle renforcée',
    ),
    DestinationInfo(
      pays: 'Brésil',
      region: 'Amérique du Sud',
      vaccinsObligatoires: ['Fièvre jaune'],
      vaccinsRecommandes: ['Hépatite A+B', 'Typhoïde', 'Rage'],
      niveauAlerte: TravelAlertLevel.info,
      messageAlerte: 'Fièvre jaune obligatoire — vérifier le carnet international',
    ),
    DestinationInfo(
      pays: 'Thaïlande',
      region: 'Asie du Sud-Est',
      vaccinsObligatoires: [],
      vaccinsRecommandes: ['Hépatite A+B', 'Typhoïde', 'Rage'],
      niveauAlerte: TravelAlertLevel.urgent,
      messageAlerte: 'Alerte sanitaire : cas de rage humaine signalés dans le Nord',
    ),
  ];
}
