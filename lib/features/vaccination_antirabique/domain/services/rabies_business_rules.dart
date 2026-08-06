import '../models/dossier/dossier_enums.dart';
import '../models/dossier/exposure.dart';
import '../models/dossier/rabies_case_record.dart';
import '../models/dossier/rabies_clinical_alert.dart';
import '../models/dossier/vaccination.dart';
import 'rabies_alert_service.dart';
import 'rabies_decision_engine.dart';
import 'rabies_protocol_resolver.dart';

/// Règles métier pures du dossier antirabique (couche de compatibilité).
///
/// Ce service délègue désormais toute la logique de décision à
/// [`RabiesDecisionEngine`], [`RabiesProtocolResolver`] et
/// [`RabiesAlertService`]. Il est conservé pour la rétro-compatibilité des
/// écrans existants, afin qu'aucun widget ne contienne de logique métier.
class RabiesBusinessRules {
  const RabiesBusinessRules._();

  /// Calcul automatique de la catégorie de risque rabique (OMS).
  ///
  /// Délègue à `RabiesDecisionEngine.categorie`.
  static RabiesRiskCategory calculerCategorie(ExposureDetails exposition) =>
      RabiesDecisionEngine.categorie(exposition).categorie;

  /// Raison clinique justifiant la catégorie calculée.
  static String justificationCategorie(ExposureDetails exposition) =>
      RabiesDecisionEngine.categorie(exposition).raison;

  /// L'ERIG est indiquée pour toute exposition de catégorie III.
  static bool erigIndiquee(RabiesRiskCategory categorie) =>
      categorie == RabiesRiskCategory.categorieIII;

  /// Détecte un retard : dose non réalisée dont la date prévue est passée.
  static bool estEnRetard(VaccineDose dose, DateTime now) =>
      RabiesProtocolResolver.joursDeRetard(dose, now) > 0;

  /// Propose le protocole vaccinal en fonction de la catégorie et du statut.
  static VaccinationProtocolType? proposerProtocole(
    RabiesRiskCategory categorie, {
    bool dejaVaccine = false,
    bool immunodeprime = false,
  }) {
    final decision = RabiesDecisionEngine.protocole(
      categorie,
      dejaVaccine: dejaVaccine,
      immunodeprime: immunodeprime,
    );
    return decision?.type;
  }

  /// Détermine si un protocole de type « vaccin tissulaire » (grade II/III)
  /// est requis selon la catégorie.
  static VaccinationProtocolType? protocoleTissulaire(RabiesRiskCategory c) {
    switch (c) {
      case RabiesRiskCategory.categorieI:
        return null;
      case RabiesRiskCategory.categorieII:
        return VaccinationProtocolType.vaccinTissulaireGradeII;
      case RabiesRiskCategory.categorieIII:
        return VaccinationProtocolType.vaccinTissulaireGradeIII;
    }
  }

  /// Récapitule les statuts des doses du protocole à une date donnée.
  static void recalculerStatutsDoses(
    VaccinationProtocol protocole,
    DateTime now,
  ) {
    for (final dose in protocole.doses) {
      if (dose.estRealisee || dose.statut == DoseStatus.manquee) continue;
      if (estEnRetard(dose, now)) {
        dose.copyWith(statut: DoseStatus.enRetard);
      }
    }
  }

  /// Résumé clinique court et lisible du dossier.
  static String resumeClinique(RabiesCaseRecord record) {
    final b = StringBuffer();
    final id = record.identity;
    b.write('${id.nomComplet.isEmpty ? 'Patient' : id.nomComplet} · ');
    b.write('${record.exposition.nature.label} · ');
    b.write(record.classification.categorie.label);

    final proto = record.vaccination.protocole;
    if (proto.doses.isNotEmpty) {
      b.write(' · ${proto.type.label} '
          '(${proto.dosesRealisees}/${proto.totalDoses})');
    }
    if (record.aErigAdministree) {
      b.write(' · ERIG administrée');
    }
    if (record.aMpvi) {
      b.write(' · MPVI');
    }
    return b.toString();
  }

  /// Données critiques manquantes (compatibilité : ancien format de liste).
  static List<String> donneesCritiquesManquantes(RabiesCaseRecord record) {
    final alerts = RabiesAlertService.evaluer(record)
        .where((a) => a.severity == RabiesAlertSeverity.critical)
        .toList();
    return alerts.map((a) => '${a.titre} : ${a.message}').toList();
  }

  /// Problèmes de complétude ERIG (compatibilité : ancien format).
  static List<String> erigIncomplete(RabiesCaseRecord record) {
    final decision = RabiesDecisionEngine.erig(record);
    return decision.warnings.map((w) => w.message).toList();
  }
}
