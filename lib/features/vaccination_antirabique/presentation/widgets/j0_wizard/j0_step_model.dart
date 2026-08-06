import 'package:flutter/material.dart';

import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/models/dossier/rabies_clinical_alert.dart';

/// Statut de complétude d'une étape du wizard J0.
enum J0StepStatus {
  notStarted,
  inProgress,
  complete,
  toReview;

  String get label {
    switch (this) {
      case J0StepStatus.notStarted:
        return 'Non commencée';
      case J0StepStatus.inProgress:
        return 'En cours';
      case J0StepStatus.complete:
        return 'Complète';
      case J0StepStatus.toReview:
        return 'À vérifier';
    }
  }
}

/// Définition déclarative d'une étape du parcours J0.
///
/// Chaque étape connaît son identité (numéro, titre, icône), les sections
/// du dossier qu'elle couvre et les prédicats métier qui déterminent si elle
/// est commencée ou complète. Aucune logique de calcul n'est dupliquée ici :
/// on lit simplement l'état courant du modèle.
class J0StepData {
  final String id;
  final String number;
  final String title;
  final String shortTitle;
  final IconData icon;
  final String subtitle;
  final List<RabiesAlertSection> sections;

  const J0StepData({
    required this.id,
    required this.number,
    required this.title,
    required this.shortTitle,
    required this.icon,
    required this.subtitle,
    required this.sections,
  });

  bool isComplete(RabiesCaseRecord r) {
    switch (id) {
      case 'patient':
        return r.identity.residence.commune.isNotEmpty &&
            r.identity.residence.wilaya.isNotEmpty &&
            (r.admission.heureArrivee?.isNotEmpty ?? false);
      case 'exposition':
        return r.exposition.siegeLesions.isNotEmpty &&
            (r.exposition.heureExposition?.isNotEmpty ?? false);
      case 'classification':
        return (r.classification.justification?.isNotEmpty ?? false) &&
            r.classification.mesuresFamiliales.isNotEmpty;
      case 'animal':
        return (r.animal.proprietaireNom?.isNotEmpty ?? false) ||
            r.animal.observationVeterinaire != ObservationStatus.nonPrecisee ||
            (r.animal.couleurPelage?.isNotEmpty ?? false);
      case 'priseEnCharge':
        if (r.erig.indiquee) return r.erig.administree;
        return r.soinsLocaux.realise == LocalCarePerformed.oui ||
            r.soinsLocaux.methodes.isNotEmpty;
      case 'vaccination':
        return r.vaccination.vaccinRealise &&
            r.vaccination.protocole.doses.isNotEmpty;
      case 'traitements':
        return r.tracabilite.carteRemise && r.tracabilite.patientRepertorie;
      case 'validation':
        return (r.evolution.observations?.isNotEmpty ?? false) ||
            r.evolution.estClos;
      default:
        return false;
    }
  }

  bool isStarted(RabiesCaseRecord r) {
    switch (id) {
      case 'patient':
        return (r.identity.telephone?.isNotEmpty ?? false) ||
            r.identity.residence.adresse.isNotEmpty ||
            r.identity.residence.commune.isNotEmpty ||
            r.identity.residence.daira.isNotEmpty ||
            r.identity.residence.wilaya.isNotEmpty ||
            (r.admission.heureArrivee?.isNotEmpty ?? false);
      case 'exposition':
        return r.exposition.siegeLesions.isNotEmpty ||
            (r.exposition.heureExposition?.isNotEmpty ?? false);
      case 'classification':
        return (r.classification.justification?.isNotEmpty ?? false);
      case 'animal':
        return r.animal.comportement == AnimalBehavior.suspect ||
            r.animal.observationVeterinaire != ObservationStatus.nonPrecisee ||
            (r.animal.proprietaireNom?.isNotEmpty ?? false) ||
            (r.animal.couleurPelage?.isNotEmpty ?? false);
      case 'priseEnCharge':
        return r.soinsLocaux.realise == LocalCarePerformed.oui ||
            (r.soinsLocaux.produitsAppliques?.isNotEmpty ?? false) ||
            r.erig.administree ||
            r.erig.numeroLot?.isNotEmpty == true ||
            r.chirurgie.realise == SurgeryPerformed.oui;
      case 'vaccination':
        return r.vaccination.vaccinRealise ||
            (r.vaccination.dci?.isNotEmpty ?? false) ||
            (r.vaccination.numeroLot?.isNotEmpty ?? false);
      case 'traitements':
        return r.mpvi.present ||
            r.antibiotiques.estPrescrit ||
            r.vaccinationTetanos.estRealisee ||
            r.autresTraitements.present ||
            r.tracabilite.carteRemise ||
            r.tracabilite.patientRepertorie;
      case 'validation':
        return (r.evolution.observations?.isNotEmpty ?? false) ||
            r.evolution.estClos;
      default:
        return false;
    }
  }

  static const List<J0StepData> tous = [
    J0StepData(
      id: 'patient',
      number: '01',
      title: 'Patient · Admission',
      shortTitle: 'Admission',
      icon: Icons.badge_outlined,
      subtitle: 'Identité, adresse et accueil à l’UAR.',
      sections: [RabiesAlertSection.identite, RabiesAlertSection.adresse, RabiesAlertSection.admission],
    ),
    J0StepData(
      id: 'exposition',
      number: '02',
      title: 'Exposition · Lésions',
      shortTitle: 'Exposition',
      icon: Icons.coronavirus_outlined,
      subtitle: 'Circonstances, heure, nature et siège des lésions.',
      sections: [RabiesAlertSection.exposition],
    ),
    J0StepData(
      id: 'classification',
      number: '03',
      title: 'Classification du risque',
      shortTitle: 'Risque',
      icon: Icons.offline_bolt_outlined,
      subtitle: 'Catégorie OMS, justification et mesures familiales.',
      sections: [RabiesAlertSection.classification],
    ),
    J0StepData(
      id: 'animal',
      number: '04',
      title: 'Animal en cause',
      shortTitle: 'Animal',
      icon: Icons.pets_outlined,
      subtitle: 'Espèce, statut, observation vétérinaire et laboratoire.',
      sections: [RabiesAlertSection.animal],
    ),
    J0StepData(
      id: 'priseEnCharge',
      number: '05',
      title: 'Soins locaux · ERIG',
      shortTitle: 'Soins · ERIG',
      icon: Icons.local_hospital_outlined,
      subtitle: 'Désinfection, immunoglobulines et chirurgie.',
      sections: [RabiesAlertSection.soinsLocaux, RabiesAlertSection.erig, RabiesAlertSection.chirurgie],
    ),
    J0StepData(
      id: 'vaccination',
      number: '06',
      title: 'Vaccination · Protocole',
      shortTitle: 'Vaccination',
      icon: Icons.vaccines_outlined,
      subtitle: 'Type de vaccin, protocole et calendrier des doses.',
      sections: [RabiesAlertSection.vaccination, RabiesAlertSection.protocole],
    ),
    J0StepData(
      id: 'traitements',
      number: '07',
      title: 'Traitements associés · Traçabilité',
      shortTitle: 'Traitements',
      icon: Icons.medication_outlined,
      subtitle: 'Antibiotiques, VAT, MPVI et traçabilité réglementaire.',
      sections: [RabiesAlertSection.mpvi, RabiesAlertSection.antibiotiques, RabiesAlertSection.tetanos, RabiesAlertSection.autresTraitements, RabiesAlertSection.tracabilite],
    ),
    J0StepData(
      id: 'validation',
      number: '08',
      title: 'Résumé clinique · Validation',
      shortTitle: 'Validation',
      icon: Icons.verified_outlined,
      subtitle: 'Synthèse clinique, observations et validation de la fiche J0.',
      sections: [RabiesAlertSection.evolution],
    ),
  ];

  J0StepData stepById(String id) => tous.firstWhere((s) => s.id == id);
}
