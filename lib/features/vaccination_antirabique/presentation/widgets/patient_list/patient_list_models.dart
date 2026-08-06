import 'package:flutter/material.dart';
import '../../../data/models/patient_antirabique_model.dart';

/// Date de référence par défaut (aujourd'hui).
DateTime _aujourdhui() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Parse une date ISO `yyyy-MM-dd` (format utilisé dans le modèle patient).
DateTime? parseDateIso(String? iso) {
  if (iso == null || iso.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

String formatDateIso(String? iso) {
  final d = parseDateIso(iso);
  if (d == null) return '—';
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd/$mm/${d.year}';
}

/// Un patient est « en retard » si son suivi est marqué comme perdu de vue,
/// ou si un rendez-vous programmé est passé sans être soldé.
bool patientEnRetard(PatientAntirabiqueModel p, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  if (p.statut == StatutSuivi.perduDeVue) return true;
  if (p.statut != StatutSuivi.enCours) return false;
  final rdv = parseDateIso(p.prochainRendezVous);
  if (rdv == null) return false;
  return rdv.isBefore(ref);
}

/// Le patient a un rendez-vous (dose) prévu aujourd'hui.
bool patientDueAujourdhui(PatientAntirabiqueModel p, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  if (p.statut != StatutSuivi.enCours) return false;
  final rdv = parseDateIso(p.prochainRendezVous);
  if (rdv == null) return false;
  return rdv.year == ref.year && rdv.month == ref.month && rdv.day == ref.day;
}

/// Nombre de jours de retard du prochain rendez-vous (0 si non en retard).
int joursDeRetard(PatientAntirabiqueModel p, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  final rdv = parseDateIso(p.prochainRendezVous);
  if (rdv == null) return 0;
  final diff = ref.difference(rdv).inDays;
  return diff > 0 ? diff : 0;
}

/// Libellé relatif du prochain rendez-vous (ex: « Aujourd'hui », « J+3 »,
/// « En retard de 4 j »).
String libelleRendezVous(PatientAntirabiqueModel p, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  final rdv = parseDateIso(p.prochainRendezVous);
  if (rdv == null) return 'Non planifié';
  final diff = rdv.difference(ref).inDays;
  if (diff == 0) return 'Aujourd\'hui';
  if (diff == 1) return 'Demain';
  if (diff > 1) return 'Dans $diff j';
  final late = -diff;
  if (p.statut == StatutSuivi.perduDeVue) return 'Rendez-vous dépassé';
  return 'En retard de $late j';
}

/// Score d'urgence (tri « urgent d'abord ») : catégorie III, dose du jour,
/// rendez-vous dépassé.
int scoreUrgence(PatientAntirabiqueModel p, [DateTime? today]) {
  var score = 0;
  if (p.categorieExposition == CategorieExposition.categorieIII) score += 4;
  if (patientDueAujourdhui(p, today)) score += 3;
  if (patientEnRetard(p, today)) score += 2;
  if (p.immunocompromis) score += 1;
  return score;
}

/// Filtre principal par statut (Tous / En cours / En retard / Terminés /
/// Perdus de vue / Transférés).
enum PatientStatusFilter {
  all('Tous'),
  enCours('En cours'),
  enRetard('En retard'),
  termine('Terminés'),
  perduDeVue('Perdus de vue'),
  transfere('Transférés');

  const PatientStatusFilter(this.label);
  final String label;

  bool matches(PatientAntirabiqueModel p, [DateTime? today]) {
    switch (this) {
      case PatientStatusFilter.all:
        return true;
      case PatientStatusFilter.enCours:
        return p.statut == StatutSuivi.enCours;
      case PatientStatusFilter.enRetard:
        return patientEnRetard(p, today);
      case PatientStatusFilter.termine:
        return p.statut == StatutSuivi.termine;
      case PatientStatusFilter.perduDeVue:
        return p.statut == StatutSuivi.perduDeVue;
      case PatientStatusFilter.transfere:
        return p.statut == StatutSuivi.transfere;
    }
  }
}

/// Filtres rapides complémentaires (catégorie, protocole, RIG, dose du jour).
enum PatientQuickFilter {
  categorieI('Catégorie I', Icons.looks_one_outlined),
  categorieII('Catégorie II', Icons.looks_two_outlined),
  categorieIII('Catégorie III', Icons.looks_3_outlined),
  aEvaluer('À évaluer (J0)', Icons.rule_outlined),
  essen('Essen', Icons.vaccines),
  essenReduit('Essen réduit', Icons.vaccines_outlined),
  zagreb('Zagreb', Icons.history_toggle_off),
  ipc('IPC', Icons.grain),
  rig('ERIG administrée', Icons.science_outlined),
  doseAujourdhui('Dose aujourd\'hui', Icons.notifications_active_outlined);

  const PatientQuickFilter(this.label, this.icon);
  final String label;
  final IconData icon;

  bool matches(PatientAntirabiqueModel p, [DateTime? today]) {
    switch (this) {
      case PatientQuickFilter.categorieI:
        return p.categorieExposition == CategorieExposition.categorieI;
      case PatientQuickFilter.categorieII:
        return p.categorieExposition == CategorieExposition.categorieII;
      case PatientQuickFilter.categorieIII:
        return p.categorieExposition == CategorieExposition.categorieIII;
      case PatientQuickFilter.aEvaluer:
        return p.enAttenteEvaluation;
      case PatientQuickFilter.essen:
        return p.protocole == ProtocoleType.essen;
      case PatientQuickFilter.essenReduit:
        return p.protocole == ProtocoleType.essenReduit;
      case PatientQuickFilter.zagreb:
        return p.protocole == ProtocoleType.zagreb;
      case PatientQuickFilter.ipc:
        return p.protocole == ProtocoleType.ipc;
      case PatientQuickFilter.rig:
        return p.rigAdministree;
      case PatientQuickFilter.doseAujourdhui:
        return patientDueAujourdhui(p, today);
    }
  }
}

/// Options de tri intelligentes de la liste patient.
enum PatientSortOption {
  urgent('Urgent d\'abord'),
  retard('Retard d\'abord'),
  doseDuJour('Dose du jour'),
  nom('Nom (A→Z)'),
  recent('Exposition récente');

  const PatientSortOption(this.label);
  final String label;

  List<PatientAntirabiqueModel> sort(List<PatientAntirabiqueModel> list,
      [DateTime? today]) {
    final ref = today ?? _aujourdhui();
    final sorted = List<PatientAntirabiqueModel>.of(list);
    switch (this) {
      case PatientSortOption.urgent:
        sorted.sort((a, b) {
          final c = scoreUrgence(b, ref).compareTo(scoreUrgence(a, ref));
          if (c != 0) return c;
          return a.nomComplet.compareTo(b.nomComplet);
        });
      case PatientSortOption.retard:
        sorted.sort((a, b) {
          final ar = patientEnRetard(a, ref);
          final br = patientEnRetard(b, ref);
          if (ar != br) return ar ? -1 : 1;
          final da = joursDeRetard(a, ref);
          final db = joursDeRetard(b, ref);
          final c = db.compareTo(da);
          if (c != 0) return c;
          return a.nomComplet.compareTo(b.nomComplet);
        });
      case PatientSortOption.doseDuJour:
        sorted.sort((a, b) {
          final ad = patientDueAujourdhui(a, ref);
          final bd = patientDueAujourdhui(b, ref);
          if (ad != bd) return ad ? -1 : 1;
          return scoreUrgence(b, ref).compareTo(scoreUrgence(a, ref));
        });
      case PatientSortOption.nom:
        sorted.sort((a, b) => a.nomComplet.compareTo(b.nomComplet));
      case PatientSortOption.recent:
        sorted.sort((a, b) {
          final da = parseDateIso(a.dateExposition);
          final db = parseDateIso(b.dateExposition);
          if (da == null || db == null) return 0;
          return db.compareTo(da);
        });
    }
    return sorted;
  }
}
