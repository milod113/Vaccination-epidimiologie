import '../../data/models/tetanus_models.dart';

/// Niveau de risque tétanique estimé à partir de l'étude de la plaie et du
/// contexte d'exposition.
enum TetanusRiskLevel {
  faible('Faible', 'Exposition propre, faible probabilité d\'inoculation.'),
  moyen('Moyen', 'Plaie modérée ou souillée, risque significatif.'),
  eleve('Élevé', 'Exposition tétanigène, risque important d\'infection.');

  const TetanusRiskLevel(this.label, this.description);
  final String label;
  final String description;
}

/// Données d'entrée de l'évaluation tétanique.
class TetanusEvaluationInput {
  final TetanusWoundType typePlaie;
  final String localisation;
  final bool profond;
  final bool souillee;
  final bool corpsEtranger;
  final bool soinsLocaux;
  final String delai;
  final TetanusVaccinStatus statutVaccinal;
  final int? nombreDoses;
  final String? derniereDose;
  final bool immunodeprime;
  final bool grossesse;
  final bool allergieVat;
  final bool antecedentTetanos;
  final bool traitementDejaRecu;

  const TetanusEvaluationInput({
    this.typePlaie = TetanusWoundType.propre,
    this.localisation = '',
    this.profond = false,
    this.souillee = false,
    this.corpsEtranger = false,
    this.soinsLocaux = false,
    this.delai = '< 6h',
    this.statutVaccinal = TetanusVaccinStatus.inconnu,
    this.nombreDoses,
    this.derniereDose,
    this.immunodeprime = false,
    this.grossesse = false,
    this.allergieVat = false,
    this.antecedentTetanos = false,
    this.traitementDejaRecu = false,
  });
}

/// Décision / conduite à tenir issue de l'évaluation.
class TetanusDecisionResolution {
  final TetanusRiskLevel risk;
  final TetanusDecision decision;
  final String recommandation;
  const TetanusDecisionResolution({
    required this.risk,
    required this.decision,
    required this.recommandation,
  });
}

/// Moteur de calcul du risque et de la décision prophylactique.
class TetanusEvaluationService {
  const TetanusEvaluationService();

  /// Constitue l'entrée d'évaluation à partir d'un dossier patient existant.
  TetanusEvaluationInput inputForPatient(TetanusPatientModel p) {
    return TetanusEvaluationInput(
      typePlaie: p.typePlaie,
      localisation: p.localisation,
      profond: p.plaieProfonde,
      souillee: p.plaieSouillee,
      corpsEtranger: p.corpsEtranger,
      soinsLocaux: p.soinsLocauxRealises,
      delai: p.delaiConsultation,
      statutVaccinal: p.statutVaccinal,
      nombreDoses: p.nombreDosesConnues,
      derniereDose: p.derniereDoseDate,
      traitementDejaRecu: p.historique.isNotEmpty,
    );
  }

  TetanusRiskLevel riskFor(TetanusPatientModel p) =>
      computeRisk(inputForPatient(p));

  TetanusDecisionResolution resolveFor(TetanusPatientModel p) =>
      resolve(inputForPatient(p));

  bool _highRisk(TetanusEvaluationInput i) {
    if (i.typePlaie == TetanusWoundType.tetanigene) return true;
    if (i.corpsEtranger) return true;
    if (i.profond && i.souillee) return true;
    return false;
  }

  bool _mediumRisk(TetanusEvaluationInput i) {
    if (i.typePlaie == TetanusWoundType.aRisque) return true;
    if (i.profond || i.souillee) return true;
    return false;
  }

  TetanusRiskLevel computeRisk(TetanusEvaluationInput i) {
    final base = _highRisk(i)
        ? TetanusRiskLevel.eleve
        : _mediumRisk(i)
        ? TetanusRiskLevel.moyen
        : TetanusRiskLevel.faible;
    if (i.immunodeprime && base != TetanusRiskLevel.eleve) {
      return base == TetanusRiskLevel.moyen ? TetanusRiskLevel.eleve : base;
    }
    return base;
  }

  TetanusDecisionResolution resolve(TetanusEvaluationInput i) {
    final risk = computeRisk(i);
    final vaccin = i.statutVaccinal;
    final isJour = vaccin == TetanusVaccinStatus.aJour;

    if (i.immunodeprime && risk == TetanusRiskLevel.eleve) {
      return TetanusDecisionResolution(
        risk: risk,
        decision: TetanusDecision.avisSpecialise,
        recommandation:
            'Contexte à risque élevé chez un patient immunodéprimé. '
            'Un avis médical spécialisé est requis avant toute décision prophylactique.',
      );
    }

    if (i.allergieVat && (risk == TetanusRiskLevel.eleve || !isJour)) {
      return TetanusDecisionResolution(
        risk: risk,
        decision: TetanusDecision.avisSpecialise,
        recommandation:
            'Allergie connue à l\'anatoxine tétanique. '
            'Avis spécialisé indispensable avant administration.',
      );
    }

    switch (risk) {
      case TetanusRiskLevel.eleve:
        if (isJour) {
          return TetanusDecisionResolution(
            risk: risk,
            decision: TetanusDecision.rappelIndique,
            recommandation:
                'Plaie tétanigène : un rappel VAT est recommandé si la dernière dose '
                'remonte à plus de 5 ans. Aucune immunoglobuline nécessaire si vaccination à jour.',
          );
        }
        return TetanusDecisionResolution(
          risk: risk,
          decision: TetanusDecision.vaccinationEtIg,
          recommandation:
              'Plaie à haut risque et vaccination incomplète/inconnue : '
              'vaccination VAT ET immunoglobulines antitétaniques à administrer sans délai.',
        );
      case TetanusRiskLevel.moyen:
        if (isJour) {
          return TetanusDecisionResolution(
            risk: risk,
            decision: TetanusDecision.simpleSurveillance,
            recommandation:
                'Vaccination à jour pour une plaie modérée : simple surveillance, '
                'aucun acte prophylactique nécessaire.',
          );
        }
        return TetanusDecisionResolution(
          risk: risk,
          decision: TetanusDecision.vaccinationComplete,
          recommandation:
              'Plaie modérée et vaccination non à jour : initier ou compléter '
              'le schéma vaccinal VAT.',
        );
      case TetanusRiskLevel.faible:
        if (isJour) {
          return TetanusDecisionResolution(
            risk: risk,
            decision: TetanusDecision.simpleSurveillance,
            recommandation:
                'Exposition propre avec vaccination à jour. Simple surveillance, '
                'aucun acte nécessaire.',
          );
        }
        return TetanusDecisionResolution(
          risk: risk,
          decision: TetanusDecision.vaccinationComplete,
          recommandation:
              'Vaccination à compléter (schéma VAT) même en l\'absence de risque élevé.',
        );
    }
  }

  /// Vérifie si le dossier d'évaluation est prêt à être validé.
  bool isDossierPret(TetanusEvaluationInput i) {
    return i.typePlaie != TetanusWoundType.propre &&
        i.localisation.isNotEmpty &&
        i.statutVaccinal != TetanusVaccinStatus.inconnu;
  }
}
