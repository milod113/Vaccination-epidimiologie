import '../models/dossier/dossier_enums.dart';
import '../models/dossier/rabies_case_record.dart';
import '../models/dossier/rabies_clinical_alert.dart';
import '../models/dossier/rabies_decision_summary.dart';
import 'rabies_decision_engine.dart';
import 'rabies_protocol_resolver.dart';

/// Service de génération des alertes cliniques du dossier antirabique.
///
/// Produit une liste structurée de `RabiesClinicalAlert` à partir du dossier
/// et de la date courante. L'UI n'a qu'à les afficher.
class RabiesAlertService {
  const RabiesAlertService._();

  /// Évalue toutes les alertes du dossier.
  static List<RabiesClinicalAlert> evaluer(
    RabiesCaseRecord record, {
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    
    final summary = RabiesDecisionEngine.resumer(record, now: ref);

    return <RabiesClinicalAlert>[
      ..._donneesCritiquesManquantes(record),
      ...summary.erig.warnings,
      ..._protocoleAlerts(record, summary),
      ..._retardAlerts(record, summary, ref),
      ..._coherenceAlerts(record),
    ];
  }

  // ── Données critiques manquantes ──────────────────────────────────

  static List<RabiesClinicalAlert> _donneesCritiquesManquantes(
    RabiesCaseRecord record,
  ) {
    final alerts = <RabiesClinicalAlert>[];
    final id = record.identity;

    if (id.nom.isEmpty || id.prenom.isEmpty) {
      alerts.add(_critique(
        'IDENTITE',
        'Identité insuffisante',
        'Nom ou prénom manquant.',
        RabiesAlertSection.identite,
      ));
    }
    if (id.dateNaissance == null && id.age == null) {
      alerts.add(_critique(
        'AGE',
        'Âge / date de naissance manquante',
        'Impossible de calculer l\'âge du patient.',
        RabiesAlertSection.identite,
      ));
    }
    if (record.exposition.dateExposition == null) {
      alerts.add(_critique(
        'DATE-EXPO',
        'Date d\'exposition manquante',
        'Le délai depuis l\'exposition ne peut pas être évalué.',
        RabiesAlertSection.exposition,
      ));
    }
    if (record.exposition.heureExposition == null) {
      alerts.add(_alerte(
        'HEURE-EXPO',
        'Heure d\'exposition manquante',
        'Indispensable pour le calcul du délai (notamment ERIG).',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.exposition,
      ));
    }
    if (record.exposition.siegeLesions.isEmpty) {
      alerts.add(_critique(
        'SIEGE',
        'Siège des lésions manquant',
        'Nécessaire pour la classification (zones critiques).',
        RabiesAlertSection.exposition,
      ));
    }
    if (record.animal.espece == AnimalSpecies.autre &&
        (record.animal.autreEspecePrecision == null ||
            record.animal.autreEspecePrecision!.isEmpty)) {
      alerts.add(_alerte(
        'ESPECE-AUTRE',
        'Espèce animale non précisée',
        '« Autre » est sélectionné sans précision.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.animal,
      ));
    }
    if (record.vaccination.typeVaccin != RabiesVaccineType.non &&
        record.vaccination.protocole.doses.isEmpty) {
      alerts.add(_critique(
        'VACCIN-SANS-PROTOCOLE',
        'Vaccination sans protocole',
        'Le vaccin est renseigné mais aucun protocole n\'est généré.',
        RabiesAlertSection.vaccination,
      ));
    }
    if (record.animal.observationVeterinaire == ObservationStatus.oui &&
        record.animal.resultatObservation == ObservationResult.nonPrecise) {
      alerts.add(_alerte(
        'OBSERVATION-RESULTAT',
        'Résultat d\'observation manquant',
        'L\'observation vétérinaire est « oui » sans résultat.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.animal,
      ));
    }
    if (record.chirurgie.realise == SurgeryPerformed.oui &&
        record.chirurgie.suture == SutureTiming.non) {
      alerts.add(_alerte(
        'SUTURE-PRECISION',
        'Suture sans précision',
        'Chirurgie réalisée mais timing de suture non renseigné.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.chirurgie,
      ));
    }
    return alerts;
  }

  // ── Alertes protocole ─────────────────────────────────────────────

  static List<RabiesClinicalAlert> _protocoleAlerts(
    RabiesCaseRecord record,
    RabiesDecisionSummary summary,
  ) {
    final alerts = <RabiesClinicalAlert>[];

    final cat = summary.categorie.categorie;
    if (cat != RabiesRiskCategory.categorieI &&
        record.vaccination.typeVaccin == RabiesVaccineType.non) {
      alerts.add(_critique(
        'PPE-NON-INITIEE',
        'PPE non initiée',
        'Vaccination indiquée (${cat.label}) mais aucun vaccin renseigné.',
        RabiesAlertSection.vaccination,
      ));
    }
    return alerts;
  }

  // ── Alertes retard / suivi ────────────────────────────────────────

  static List<RabiesClinicalAlert> _retardAlerts(
    RabiesCaseRecord record,
    RabiesDecisionSummary summary,
    DateTime now,
  ) {
    final alerts = <RabiesClinicalAlert>[];
    final proto = record.vaccination.protocole;
    if (proto.doses.isEmpty) return alerts;

    final enRetard = RabiesProtocolResolver.dosesEnRetard(proto, now);
    if (enRetard.isNotEmpty) {
      final jours = RabiesProtocolResolver.retardMax(proto, now);
      alerts.add(RabiesClinicalAlert(
        id: 'DOSES-EN-RETARD',
        titre: '${enRetard.length} dose(s) en retard',
        message: 'Dose(s) prévues non administrées, '
            'retard maximal : J+$jours.',
        severity: jours >= 7
            ? RabiesAlertSeverity.critical
            : RabiesAlertSeverity.warning,
        category: RabiesAlertCategory.retard,
        section: RabiesAlertSection.protocole,
        recommendation: 'Rattraper la dose et reprendre le schéma.',
      ));
    }

    if (RabiesProtocolResolver.ruptureDeSuivi(proto, now)) {
      alerts.add(RabiesClinicalAlert(
        id: 'RUPTURE-SUIVI',
        titre: 'Rupture de suivi',
        message: 'Le patient n\'a pas honoré son rendez-vous de vaccination.',
        severity: RabiesAlertSeverity.critical,
        category: RabiesAlertCategory.suivi,
        section: RabiesAlertSection.protocole,
        blocking: true,
        recommendation: 'Contacter le patient et reprogrammer la dose.',
      ));
    }

    if (summary.prochaineDose != null && !summary.retard) {
      final next = summary.prochaineDose!;
      final date = next.datePrevue;
      if (date != null) {
        final today = DateTime(now.year, now.month, now.day);
        final jour = DateTime(date.year, date.month, date.day);
        final diff = jour.difference(today).inDays;
        if (diff == 0) {
          alerts.add(_alerte(
            'DOSE-AUJOURD-HUI',
            'Prochaine dose due aujourd\'hui',
            '${next.jourTheorique} est attendue aujourd\'hui.',
            RabiesAlertSeverity.warning,
            RabiesAlertSection.protocole,
          ));
        }
      }
    }
    return alerts;
  }

  // ── Alertes de cohérence ──────────────────────────────────────────

  static List<RabiesClinicalAlert> _coherenceAlerts(
    RabiesCaseRecord record,
  ) {
    final alerts = <RabiesClinicalAlert>[];
    final tr = record.tracabilite;

    if (tr.carteRemise && (tr.numeroCarte == null || tr.numeroCarte!.isEmpty)) {
      alerts.add(_alerte(
        'CARTE-NUMERO',
        'Numéro de carte manquant',
        'La carte de vaccination est remise sans numéro.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.tracabilite,
      ));
    }
    if (tr.patientRepertorie &&
        (tr.numeroRegistre == null || tr.numeroRegistre!.isEmpty)) {
      alerts.add(_alerte(
        'REGISTRE-NUMERO',
        'Numéro de registre manquant',
        'Le patient est inscrit au registre sans numéro.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.tracabilite,
      ));
    }
    if (record.mpvi.present &&
        (record.mpvi.manifestations == null ||
            record.mpvi.manifestations!.isEmpty)) {
      alerts.add(_alerte(
        'MPVI-MANIFESTATIONS',
        'MPVI sans manifestations',
        'Un effet indésirable est déclaré sans description.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.mpvi,
      ));
    }
    if (record.erig.reactionPostErig &&
        record.erig.typeReaction == null) {
      alerts.add(_alerte(
        'ERIG-REACTION-TYPE',
        'Type de réaction ERIG manquant',
        'Une réaction post-ERIG est notée sans type.',
        RabiesAlertSeverity.warning,
        RabiesAlertSection.erig,
      ));
    }
    return alerts;
  }

  // ── Fabriques ─────────────────────────────────────────────────────

  static RabiesClinicalAlert _critique(
    String id,
    String titre,
    String message,
    RabiesAlertSection section,
  ) {
    return RabiesClinicalAlert(
      id: id,
      titre: titre,
      message: message,
      severity: RabiesAlertSeverity.critical,
      category: RabiesAlertCategory.donneesManquantes,
      section: section,
      blocking: true,
    );
  }

  static RabiesClinicalAlert _alerte(
    String id,
    String titre,
    String message,
    RabiesAlertSeverity severity,
    RabiesAlertSection section, {
    String? recommendation,
  }) {
    return RabiesClinicalAlert(
      id: id,
      titre: titre,
      message: message,
      severity: severity,
      category: RabiesAlertCategory.coherence,
      section: section,
      recommendation: recommendation,
    );
  }
}
