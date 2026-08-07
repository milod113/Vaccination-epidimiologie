import 'package:flutter/material.dart';
import '../../../data/models/tetanus_models.dart';

/// Contexte tétanos : vraie date de blessure (format `dd/MM/yyyy`) ou ISO.
DateTime? parseTetanusDate(String? source) {
  final s = source?.trim();
  if (s == null || s.isEmpty) return null;
  if (s.contains('/')) {
    final parts = s.split('/');
    if (parts.length != 3) return null;
    final d = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final y = int.tryParse(parts[2]);
    if (d == null || m == null || y == null) return null;
    return DateTime(y, m, d);
  }
  final parsed = DateTime.tryParse(s);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

/// Comparateur « récent d'abord » selon la date de blessure.
int _compareRecence(TetanusPatientModel a, TetanusPatientModel b) {
  final da = parseTetanusDate(a.dateBlessure);
  final db = parseTetanusDate(b.dateBlessure);
  if (da == null || db == null) return 0;
  return db.compareTo(da);
}

/// Score d'urgence clinique : plaie tétanigène / VAT+Ig / corps étranger.
int scoreUrgenceTetanus(TetanusPatientModel p) {
  var score = 0;
  if (p.decision == TetanusDecision.vaccinationEtIg) score += 5;
  if (p.typePlaie == TetanusWoundType.tetanigene) score += 4;
  if (p.corpsEtranger) score += 2;
  if (p.plaieProfonde || p.plaieSouillee) score += 1;
  if (p.statutDossier == TetanusDossierStatut.perduDeVue) score += 1;
  return score;
}

/// Filtre principal (dossier) de la liste des cas tétaniques.
enum TetanusCaseStatusFilter {
  tout('Tous'),
  enCours('En cours'),
  urgent('Urgents'),
  aEvaluer('À évaluer'),
  acteEffectue('Acte effectué'),
  suiviClos('Suivi clos'),
  perduDeVue('Perdu de vue');

  const TetanusCaseStatusFilter(this.label);
  final String label;

  bool matches(TetanusPatientModel p) {
    switch (this) {
      case TetanusCaseStatusFilter.tout:
        return true;
      case TetanusCaseStatusFilter.enCours:
        return p.statutDossier == TetanusDossierStatut.enCours;
      case TetanusCaseStatusFilter.urgent:
        return p.estUrgent;
      case TetanusCaseStatusFilter.aEvaluer:
        return p.statutDossier == TetanusDossierStatut.enCours &&
            p.statutVaccinal == TetanusVaccinStatus.inconnu;
      case TetanusCaseStatusFilter.acteEffectue:
        return p.statutDossier == TetanusDossierStatut.acteEffectue;
      case TetanusCaseStatusFilter.suiviClos:
        return p.statutDossier == TetanusDossierStatut.suiviClos;
      case TetanusCaseStatusFilter.perduDeVue:
        return p.statutDossier == TetanusDossierStatut.perduDeVue;
    }
  }
}

/// Filtres rapides cliniques (type de plaie, prophylaxie requise).
enum TetanusCaseQuickFilter {
  tetanigene('Plaie tétanigène', Icons.warning_amber_rounded),
  corpsEtranger('Corps étranger', Icons.casino_outlined),
  vaccinRequis('Vaccin requis', Icons.vaccines_outlined),
  rappel('Rappel VAT', Icons.event_repeat_outlined),
  ig('Ig requises', Icons.bloodtype_outlined),
  surveillance('Simple surveillance', Icons.health_and_safety_outlined);

  const TetanusCaseQuickFilter(this.label, this.icon);
  final String label;
  final IconData icon;

  bool matches(TetanusPatientModel p) {
    switch (this) {
      case TetanusCaseQuickFilter.tetanigene:
        return p.typePlaie == TetanusWoundType.tetanigene;
      case TetanusCaseQuickFilter.corpsEtranger:
        return p.corpsEtranger;
      case TetanusCaseQuickFilter.vaccinRequis:
        return p.decision == TetanusDecision.vaccinationComplete ||
            p.decision == TetanusDecision.vaccinationEtIg ||
            p.decision == TetanusDecision.rappelIndique;
      case TetanusCaseQuickFilter.rappel:
        return p.decision == TetanusDecision.rappelIndique;
      case TetanusCaseQuickFilter.ig:
        return p.immunoglobulines || p.necessiteIg;
      case TetanusCaseQuickFilter.surveillance:
        return p.decision == TetanusDecision.simpleSurveillance;
    }
  }
}

/// Options de tri intelligentes de la liste des cas.
enum TetanusCaseSortOption {
  urgent('Urgent d\'abord'),
  recent('Blessure récente'),
  decision('Décision'),
  nom('Nom (A→Z)');

  const TetanusCaseSortOption(this.label);
  final String label;

  List<TetanusPatientModel> sort(List<TetanusPatientModel> source) {
    final list = List<TetanusPatientModel>.of(source);
    switch (this) {
      case TetanusCaseSortOption.urgent:
        list.sort((a, b) {
          final c = scoreUrgenceTetanus(b).compareTo(scoreUrgenceTetanus(a));
          if (c != 0) return c;
          return a.nomComplet.compareTo(b.nomComplet);
        });
      case TetanusCaseSortOption.recent:
        list.sort((a, b) {
          final c = _compareRecence(a, b);
          return c != 0 ? c : a.nomComplet.compareTo(b.nomComplet);
        });
      case TetanusCaseSortOption.decision:
        list.sort((a, b) => a.decision.label.compareTo(b.decision.label));
      case TetanusCaseSortOption.nom:
        list.sort((a, b) => a.nomComplet.compareTo(b.nomComplet));
    }
    return list;
  }
}
