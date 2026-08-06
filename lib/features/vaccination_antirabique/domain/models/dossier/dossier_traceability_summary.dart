import 'dossier_actor.dart';
import 'dossier_enums.dart';

/// Résumé exploitable de la traçabilité réglementaire d'un dossier.
///
/// Produit par `RabiesTraceabilityService.resume` et consommé par l'UI
/// (carte de synthèse, fiche J0, détail dossier, écran de suivi).
class RabiesTraceabilitySummary {
  final bool carteRemise;
  final String? numeroCarte;
  final bool registreRenseigne;
  final String? numeroRegistre;
  final String? remarques;
  final int nombreEvenements;
  final DossierActor? dernierActeur;
  final DateTime? derniereModification;
  final TraceabilityStatus statut;
  final double completude;
  final DossierActor? carteRemisePar;
  final DateTime? dateCarteRemise;
  final DossierActor? registreRenseignePar;
  final DateTime? dateInscriptionRegistre;

  const RabiesTraceabilitySummary({
    required this.carteRemise,
    this.numeroCarte,
    required this.registreRenseigne,
    this.numeroRegistre,
    this.remarques,
    required this.nombreEvenements,
    this.dernierActeur,
    this.derniereModification,
    required this.statut,
    required this.completude,
    this.carteRemisePar,
    this.dateCarteRemise,
    this.registreRenseignePar,
    this.dateInscriptionRegistre,
  });

  int get completudePourcent => (completude * 100).round().clamp(0, 100);

  /// Nombre de volets de traçabilité renseignés (0..2).
  int get pointsOk => (carteRemise ? 1 : 0) + (registreRenseigne ? 1 : 0);

  int get totalPoints => 2;
}