import 'package:flutter/material.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/services/rabies_protocol_resolver.dart';

/// Date de référence par défaut (aujourd'hui, sans l'heure).
DateTime _aujourdhui() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

/// Nombre de jours de retard max du protocole (0 si à jour).
int dossierJoursRetard(RabiesCaseRecord d, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  return RabiesProtocolResolver.retardMax(d.vaccination.protocole, ref);
}

/// Le protocole du dossier est-il en retard (dose prévue passée) ?
bool dossierEnRetard(RabiesCaseRecord d, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  return RabiesProtocolResolver.enRetard(d.vaccination.protocole, ref);
}

/// Une dose est-elle attendue aujourd'hui ?
bool dossierDueAujourdhui(RabiesCaseRecord d, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  return RabiesProtocolResolver.dosesAujourdHui(
    d.vaccination.protocole,
    ref,
  ).isNotEmpty;
}

/// Catégorie III → urgence clinique.
bool dossierUrgent(RabiesCaseRecord d) => d.estUrgent;

/// Statut global du protocole pour les cartes et le tableau.
enum DossierProtocoleStatut {
  sansProtocole,
  enCours,
  enRetard,
  termine;

  String get label {
    switch (this) {
      case DossierProtocoleStatut.sansProtocole:
        return 'Sans protocole';
      case DossierProtocoleStatut.enCours:
        return 'Protocole en cours';
      case DossierProtocoleStatut.enRetard:
        return 'Protocole en retard';
      case DossierProtocoleStatut.termine:
        return 'Protocole terminé';
    }
  }
}

DossierProtocoleStatut statutProtocole(RabiesCaseRecord d, [DateTime? today]) {
  final proto = d.vaccination.protocole;
  if (proto.doses.isEmpty) return DossierProtocoleStatut.sansProtocole;
  if (proto.estTermine) return DossierProtocoleStatut.termine;
  if (dossierEnRetard(d, today)) return DossierProtocoleStatut.enRetard;
  return DossierProtocoleStatut.enCours;
}

/// Couleur du statut du protocole.
Color couleurProtocole(DossierProtocoleStatut s) => switch (s) {
  DossierProtocoleStatut.sansProtocole => EpidemiologyTheme.warm400,
  DossierProtocoleStatut.enCours => EpidemiologyTheme.info,
  DossierProtocoleStatut.enRetard => EpidemiologyTheme.warning,
  DossierProtocoleStatut.termine => EpidemiologyTheme.success,
};

/// Libellé relatif de la prochaine dose (ex: « Aujourd'hui », « J+3 »,
/// « En retard de 4 j »).
String libelleProchaineDose(RabiesCaseRecord d, [DateTime? today]) {
  final ref = today ?? _aujourdhui();
  final proto = d.vaccination.protocole;
  if (proto.estTermine) return 'Protocole terminé';
  final dose = RabiesProtocolResolver.prochaineDose(proto);
  if (dose == null || dose.datePrevue == null) {
    return proto.doses.isEmpty ? 'Aucune dose planifiée' : 'En attente';
  }
  final date = dose.datePrevue!;
  final jour = DateTime(date.year, date.month, date.day);
  final diff = jour.difference(ref).inDays;
  if (diff == 0) return "Aujourd'hui · ${dose.etiquette}";
  if (diff == 1) return 'Demain · ${dose.etiquette}';
  if (diff > 1) return 'J+$diff · ${dose.etiquette}';
  final late = -diff;
  return 'En retard de $late j · ${dose.etiquette}';
}

/// Score d'urgence (tri « urgent d'abord ») : catégorie III, dose du jour,
/// retard.
int scoreUrgence(RabiesCaseRecord d, [DateTime? today]) {
  var score = 0;
  if (d.estUrgent) score += 4;
  if (dossierDueAujourdhui(d, today)) score += 3;
  if (dossierEnRetard(d, today)) score += 2;
  if (d.erig.indiquee && !d.erig.administree) score += 1;
  return score;
}

/// Filtre principal par statut clinique du dossier.
enum DossierStatusFilter {
  all('Tous'),
  actif('En cours'),
  enRetard('En retard'),
  termine('Terminés'),
  urgent('Urgents');

  const DossierStatusFilter(this.label);
  final String label;

  bool matches(RabiesCaseRecord d, [DateTime? today]) {
    switch (this) {
      case DossierStatusFilter.all:
        return true;
      case DossierStatusFilter.actif:
        return statutProtocole(d, today) == DossierProtocoleStatut.enCours;
      case DossierStatusFilter.enRetard:
        return dossierEnRetard(d, today);
      case DossierStatusFilter.termine:
        return statutProtocole(d, today) == DossierProtocoleStatut.termine;
      case DossierStatusFilter.urgent:
        return d.estUrgent;
    }
  }
}

/// Filtres rapides : catégorie de risque, protocole, ERIG, dose du jour.
enum DossierQuickFilter {
  categorieI('Catégorie I', Icons.looks_one_outlined),
  categorieII('Catégorie II', Icons.looks_two_outlined),
  categorieIII('Catégorie III', Icons.looks_3_outlined),
  essen('Essen', Icons.vaccines),
  zagreb('Zagreb', Icons.history_toggle_off),
  erig('ERIG', Icons.science_outlined),
  doseAujourdhui("Dose aujourd'hui", Icons.notifications_active_outlined);

  const DossierQuickFilter(this.label, this.icon);
  final String label;
  final IconData icon;

  bool matches(RabiesCaseRecord d, [DateTime? today]) {
    switch (this) {
      case DossierQuickFilter.categorieI:
        return d.categorie == RabiesRiskCategory.categorieI;
      case DossierQuickFilter.categorieII:
        return d.categorie == RabiesRiskCategory.categorieII;
      case DossierQuickFilter.categorieIII:
        return d.categorie == RabiesRiskCategory.categorieIII;
      case DossierQuickFilter.essen:
        return d.vaccination.protocole.type == VaccinationProtocolType.essen;
      case DossierQuickFilter.zagreb:
        return d.vaccination.protocole.type == VaccinationProtocolType.zagreb;
      case DossierQuickFilter.erig:
        return d.aErigAdministree;
      case DossierQuickFilter.doseAujourdhui:
        return dossierDueAujourdhui(d, today);
    }
  }
}

Color couleurQuickFilter(DossierQuickFilter f) => switch (f) {
  DossierQuickFilter.categorieIII => EpidemiologyTheme.danger,
  DossierQuickFilter.categorieI => EpidemiologyTheme.success,
  DossierQuickFilter.categorieII => EpidemiologyTheme.warning,
  DossierQuickFilter.erig => EpidemiologyTheme.teal,
  DossierQuickFilter.doseAujourdhui => EpidemiologyTheme.orange,
  _ => EpidemiologyTheme.info,
};

/// Options de tri intelligentes de la liste des dossiers.
enum DossierSortOption {
  urgence("Urgent d'abord"),
  retard('Retard d\'abord'),
  doseDuJour('Dose du jour'),
  recent('Dossier récent'),
  nom('Nom (A→Z)');

  const DossierSortOption(this.label);
  final String label;

  List<RabiesCaseRecord> sort(List<RabiesCaseRecord> list, [DateTime? today]) {
    final ref = today ?? _aujourdhui();
    final sorted = List<RabiesCaseRecord>.of(list);
    switch (this) {
      case DossierSortOption.urgence:
        sorted.sort((a, b) {
          final c = scoreUrgence(b, ref).compareTo(scoreUrgence(a, ref));
          if (c != 0) return c;
          return a.patientNomComplet.compareTo(b.patientNomComplet);
        });
      case DossierSortOption.retard:
        sorted.sort((a, b) {
          final ar = dossierEnRetard(a, ref);
          final br = dossierEnRetard(b, ref);
          if (ar != br) return ar ? -1 : 1;
          final c = dossierJoursRetard(
            b,
            ref,
          ).compareTo(dossierJoursRetard(a, ref));
          if (c != 0) return c;
          return a.patientNomComplet.compareTo(b.patientNomComplet);
        });
      case DossierSortOption.doseDuJour:
        sorted.sort((a, b) {
          final ad = dossierDueAujourdhui(a, ref);
          final bd = dossierDueAujourdhui(b, ref);
          if (ad != bd) return ad ? -1 : 1;
          return scoreUrgence(b, ref).compareTo(scoreUrgence(a, ref));
        });
      case DossierSortOption.recent:
        sorted.sort((a, b) {
          final da = a.dateCreation ?? DateTime.fromMillisecondsSinceEpoch(0);
          final db = b.dateCreation ?? DateTime.fromMillisecondsSinceEpoch(0);
          final c = db.compareTo(da);
          if (c != 0) return c;
          return a.patientNomComplet.compareTo(b.patientNomComplet);
        });
      case DossierSortOption.nom:
        sorted.sort((a, b) {
          final c = a.patientNomComplet.compareTo(b.patientNomComplet);
          if (c != 0) return c;
          return a.numeroDossier.compareTo(b.numeroDossier);
        });
    }
    return sorted;
  }
}

IconData _sortIcon(DossierSortOption o) => switch (o) {
  DossierSortOption.urgence => Icons.local_fire_department_outlined,
  DossierSortOption.retard => Icons.hourglass_bottom,
  DossierSortOption.doseDuJour => Icons.notifications_active_outlined,
  DossierSortOption.recent => Icons.access_time_filled,
  DossierSortOption.nom => Icons.sort_by_alpha,
};

IconData sortOptionIcon(DossierSortOption o) => _sortIcon(o);
