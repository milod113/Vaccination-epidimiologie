import 'package:flutter/material.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';

/// Couleur d'accent dédiée à chaque type d'acte.
Color tetanusActColor(TetanusActType type) {
  switch (type) {
    case TetanusActType.vaccination:
      return EpidemiologyTheme.redPrimary;
    case TetanusActType.serumIg:
      return EpidemiologyTheme.indigo;
    case TetanusActType.soinsLocaux:
      return EpidemiologyTheme.teal;
    case TetanusActType.evaluationMedicale:
      return EpidemiologyTheme.info;
    case TetanusActType.prescription:
      return EpidemiologyTheme.orange;
    case TetanusActType.controleSuivi:
      return EpidemiologyTheme.warning;
    case TetanusActType.clotureDossier:
      return EpidemiologyTheme.success;
  }
}

/// Icône utile à chaque type d'acte.
IconData tetanusActIcon(TetanusActType type) {
  switch (type) {
    case TetanusActType.vaccination:
      return Icons.vaccines_rounded;
    case TetanusActType.serumIg:
      return Icons.bloodtype_rounded;
    case TetanusActType.soinsLocaux:
      return Icons.clean_hands_rounded;
    case TetanusActType.evaluationMedicale:
      return Icons.medical_services_rounded;
    case TetanusActType.prescription:
      return Icons.fact_check_outlined;
    case TetanusActType.controleSuivi:
      return Icons.monitor_heart_outlined;
    case TetanusActType.clotureDossier:
      return Icons.check_circle_rounded;
  }
}

/// Voies d'administration proposées pour un produit vaccinal / sérique.
const List<String> tetanusVoieChoices = ['IM', 'SC', 'IV', 'Locale', 'Orale'];

/// Types de profil pour la traçabilité.
const List<String> tetanusRoles = [
  'Médecin',
  'Infirmier',
  'Pharmacien',
  'Technicien de laboratoire',
  'Autre',
];
