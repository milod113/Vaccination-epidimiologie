import 'package:flutter/material.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';

/// Helpers d'affichage partagés du module de traçabilité.
class TraceabilityUi {
  const TraceabilityUi._();

  /// Couleur sémantique d'un rôle d'acteur.
  static Color roleColor(ActorRole role) {
    switch (role) {
      case ActorRole.medecin:
        return EpidemiologyTheme.redPrimary;
      case ActorRole.infirmier:
        return EpidemiologyTheme.teal;
      case ActorRole.agentVaccination:
        return EpidemiologyTheme.indigo;
      case ActorRole.secretaire:
        return EpidemiologyTheme.slate500;
      case ActorRole.veterinaire:
        return EpidemiologyTheme.success;
      case ActorRole.administrateur:
        return EpidemiologyTheme.burgundy;
      case ActorRole.autre:
        return EpidemiologyTheme.slate500;
    }
  }

  /// Couleur d'un type d'action d'historique.
  static Color actionColor(DossierHistoryActionType type) {
    switch (type) {
      case DossierHistoryActionType.creationDossier:
        return EpidemiologyTheme.slate500;
      case DossierHistoryActionType.evaluationJ0Validee:
        return EpidemiologyTheme.redPrimary;
      case DossierHistoryActionType.categorieRecalculee:
        return EpidemiologyTheme.warning;
      case DossierHistoryActionType.protocoleChoisi:
        return EpidemiologyTheme.indigo;
      case DossierHistoryActionType.erigAdministree:
        return EpidemiologyTheme.burgundy;
      case DossierHistoryActionType.doseAdministree:
        return EpidemiologyTheme.success;
      case DossierHistoryActionType.doseReportee:
        return EpidemiologyTheme.warning;
      case DossierHistoryActionType.doseManquee:
        return EpidemiologyTheme.danger;
      case DossierHistoryActionType.mpviEnregistre:
        return EpidemiologyTheme.orange;
      case DossierHistoryActionType.observationVeterinaireMaj:
        return EpidemiologyTheme.teal;
      case DossierHistoryActionType.carteRemise:
        return EpidemiologyTheme.indigo;
      case DossierHistoryActionType.registreRenseigne:
        return EpidemiologyTheme.teal;
      case DossierHistoryActionType.dossierCloture:
        return EpidemiologyTheme.successDark;
      case DossierHistoryActionType.dossierModifie:
        return EpidemiologyTheme.slate500;
      case DossierHistoryActionType.autre:
        return EpidemiologyTheme.slate400;
    }
  }

  /// Icône représentant un type d'action.
  static IconData actionIcon(DossierHistoryActionType type) {
    switch (type) {
      case DossierHistoryActionType.creationDossier:
        return Icons.note_add_outlined;
      case DossierHistoryActionType.evaluationJ0Validee:
        return Icons.fact_check_outlined;
      case DossierHistoryActionType.categorieRecalculee:
        return Icons.category_outlined;
      case DossierHistoryActionType.protocoleChoisi:
        return Icons.timeline;
      case DossierHistoryActionType.erigAdministree:
        return Icons.science_outlined;
      case DossierHistoryActionType.doseAdministree:
        return Icons.vaccines_outlined;
      case DossierHistoryActionType.doseReportee:
        return Icons.event_repeat;
      case DossierHistoryActionType.doseManquee:
        return Icons.event_busy_outlined;
      case DossierHistoryActionType.mpviEnregistre:
        return Icons.warning_amber_rounded;
      case DossierHistoryActionType.observationVeterinaireMaj:
        return Icons.health_and_safety_outlined;
      case DossierHistoryActionType.carteRemise:
        return Icons.badge_outlined;
      case DossierHistoryActionType.registreRenseigne:
        return Icons.menu_book_outlined;
      case DossierHistoryActionType.dossierCloture:
        return Icons.flag_outlined;
      case DossierHistoryActionType.dossierModifie:
        return Icons.edit_outlined;
      case DossierHistoryActionType.autre:
        return Icons.help_outline;
    }
  }

  /// Couleur d'un statut de validation.
  static Color validationColor(ValidationStatus statut) {
    switch (statut) {
      case ValidationStatus.validee:
        return EpidemiologyTheme.success;
      case ValidationStatus.enCours:
        return EpidemiologyTheme.warning;
      case ValidationStatus.rejetee:
        return EpidemiologyTheme.danger;
      case ValidationStatus.annulee:
        return EpidemiologyTheme.slate400;
    }
  }

  /// Couleur d'un statut global de traçabilité.
  static Color traceabilityColor(TraceabilityStatus statut) {
    switch (statut) {
      case TraceabilityStatus.complete:
        return EpidemiologyTheme.success;
      case TraceabilityStatus.incomplete:
        return EpidemiologyTheme.warning;
      case TraceabilityStatus.nonDemarre:
        return EpidemiologyTheme.slate400;
    }
  }

  static IconData traceabilityIcon(TraceabilityStatus statut) {
    switch (statut) {
      case TraceabilityStatus.complete:
        return Icons.verified_outlined;
      case TraceabilityStatus.incomplete:
        return Icons.pending_outlined;
      case TraceabilityStatus.nonDemarre:
        return Icons.assignment_outlined;
    }
  }

  /// Formate `dd/MM/yyyy HH:mm`.
  static String dateHeure(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year} $hh:$min';
  }
}
