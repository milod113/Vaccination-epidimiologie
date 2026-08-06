import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import 'j0_step_model.dart';

/// Helpers d'affichage partagés du module wizard J0.
class J0Ui {
  const J0Ui._();

  /// Texte Cairo standardisé pour le wizard.
  static TextStyle text({
    double size = 14,
    FontWeight weight = FontWeight.w600,
    Color color = EpidemiologyTheme.warm800,
    double height = 1.3,
    double? letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Couleur sémantique d'un statut de complétude.
  static Color statusColor(J0StepStatus status) {
    switch (status) {
      case J0StepStatus.notStarted:
        return EpidemiologyTheme.warm300;
      case J0StepStatus.inProgress:
        return EpidemiologyTheme.redPrimary;
      case J0StepStatus.complete:
        return EpidemiologyTheme.success;
      case J0StepStatus.toReview:
        return EpidemiologyTheme.warning;
    }
  }

  static IconData statusIcon(J0StepStatus status) {
    switch (status) {
      case J0StepStatus.notStarted:
        return Icons.circle_outlined;
      case J0StepStatus.inProgress:
        return Icons.adjust;
      case J0StepStatus.complete:
        return Icons.check_circle_rounded;
      case J0StepStatus.toReview:
        return Icons.error_outline_rounded;
    }
  }

  /// Couleur de la catégorie de risque rabique.
  static Color categoryColor(RabiesRiskCategory category) {
    switch (category) {
      case RabiesRiskCategory.categorieI:
        return EpidemiologyTheme.success;
      case RabiesRiskCategory.categorieII:
        return EpidemiologyTheme.warning;
      case RabiesRiskCategory.categorieIII:
        return EpidemiologyTheme.danger;
    }
  }
}
