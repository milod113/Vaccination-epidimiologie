import 'patient_antirabique_model.dart';

enum DoseStatut {
  prevue,
  administree,
  reportee,
  nonEffectuee,
}

extension DoseStatutX on DoseStatut {
  String get label {
    switch (this) {
      case DoseStatut.prevue:
        return 'Prévue';
      case DoseStatut.administree:
        return 'Administrée';
      case DoseStatut.reportee:
        return 'Reportée';
      case DoseStatut.nonEffectuee:
        return 'Non effectuée';
    }
  }
}

/// Statut enrichi calculé pour l'affichage UI
enum DoseStatutDetaille {
  realisee,
  prevueAujourdhui,
  aVenir,
  enRetard,
  reportee,
  nonEffectuee,
}

extension DoseStatutDetailleX on DoseStatutDetaille {
  String get label {
    switch (this) {
      case DoseStatutDetaille.realisee:
        return 'Réalisée';
      case DoseStatutDetaille.prevueAujourdhui:
        return "Aujourd'hui";
      case DoseStatutDetaille.aVenir:
        return 'À venir';
      case DoseStatutDetaille.enRetard:
        return 'En retard';
      case DoseStatutDetaille.reportee:
        return 'Reportée';
      case DoseStatutDetaille.nonEffectuee:
        return 'Non effectuée';
    }
  }
}

class DoseModel {
  final String id;
  final int numeroDose;
  final String jourTheorique; // "J0", "J3", "J7", "J14", "J28"
  final String datePrevue;
  final String? dateReelle;
  final DoseStatut statut;
  final String? numeroLot;
  final String? dateExpirationLot;
  final String? administrateurNom;
  final String? centre;
  final String? salle;
  final String? observations;
  final String? effetsIndesirables;
  final String? motifReport;
  final bool injectionDouble;
  final String? voieAdministration;

  const DoseModel({
    required this.id,
    required this.numeroDose,
    this.jourTheorique = '',
    required this.datePrevue,
    this.dateReelle,
    this.statut = DoseStatut.prevue,
    this.numeroLot,
    this.dateExpirationLot,
    this.administrateurNom,
    this.centre,
    this.salle,
    this.observations,
    this.effetsIndesirables,
    this.motifReport,
    this.injectionDouble = false,
    this.voieAdministration = 'IM',
  });

  bool get estAdministree => statut == DoseStatut.administree;
  bool get estRealisee => estAdministree;

  bool get estAujourdhui {
    if (estAdministree) return false;
    final now = DateTime.now();
    final prevue = DateTime.tryParse(datePrevue);
    if (prevue == null) return false;
    return prevue.year == now.year && prevue.month == now.month && prevue.day == now.day;
  }

  bool get estAVenir {
    if (estAdministree || statut == DoseStatut.nonEffectuee) return false;
    final now = DateTime.now();
    final prevue = DateTime.tryParse(datePrevue);
    if (prevue == null) return false;
    return prevue.isAfter(now);
  }

  bool get estEnRetard {
    if (statut == DoseStatut.administree || statut == DoseStatut.nonEffectuee) return false;
    final now = DateTime.now();
    final prevue = DateTime.tryParse(datePrevue);
    if (prevue == null) return false;
    return now.isAfter(prevue.add(const Duration(days: 1)));
  }

  /// Statut enrichi calculé en temps réel
  DoseStatutDetaille get statutDetaille {
    if (statut == DoseStatut.administree) return DoseStatutDetaille.realisee;
    if (statut == DoseStatut.reportee) return DoseStatutDetaille.reportee;
    if (statut == DoseStatut.nonEffectuee) return DoseStatutDetaille.nonEffectuee;
    if (estEnRetard) return DoseStatutDetaille.enRetard;
    if (estAujourdhui) return DoseStatutDetaille.prevueAujourdhui;
    return DoseStatutDetaille.aVenir;
  }

  String get etiquetteDose {
    final sb = StringBuffer('Dose $numeroDose');
    if (jourTheorique.isNotEmpty) {
      sb.write(' · $jourTheorique');
    }
    if (injectionDouble) {
      sb.write(' (×2)');
    }
    return sb.toString();
  }

  DoseModel copyWith({
    String? id,
    int? numeroDose,
    String? jourTheorique,
    String? datePrevue,
    String? dateReelle,
    DoseStatut? statut,
    String? numeroLot,
    String? dateExpirationLot,
    String? administrateurNom,
    String? centre,
    String? salle,
    String? observations,
    String? effetsIndesirables,
    String? motifReport,
    bool? injectionDouble,
    String? voieAdministration,
  }) {
    return DoseModel(
      id: id ?? this.id,
      numeroDose: numeroDose ?? this.numeroDose,
      jourTheorique: jourTheorique ?? this.jourTheorique,
      datePrevue: datePrevue ?? this.datePrevue,
      dateReelle: dateReelle ?? this.dateReelle,
      statut: statut ?? this.statut,
      numeroLot: numeroLot ?? this.numeroLot,
      dateExpirationLot: dateExpirationLot ?? this.dateExpirationLot,
      administrateurNom: administrateurNom ?? this.administrateurNom,
      centre: centre ?? this.centre,
      salle: salle ?? this.salle,
      observations: observations ?? this.observations,
      effetsIndesirables: effetsIndesirables ?? this.effetsIndesirables,
      motifReport: motifReport ?? this.motifReport,
      injectionDouble: injectionDouble ?? this.injectionDouble,
      voieAdministration: voieAdministration ?? this.voieAdministration,
    );
  }
}

class ProtocoleVaccinalModel {
  final String patientId;
  final ProtocoleType type;
  final String dateDebut;
  final List<DoseModel> doses;
  final bool rigIndiquee;
  final bool rigAdministree;
  final String? rigNumeroLot;
  final String? rigDateAdministration;

  const ProtocoleVaccinalModel({
    required this.patientId,
    required this.type,
    this.dateDebut = '',
    required this.doses,
    this.rigIndiquee = false,
    this.rigAdministree = false,
    this.rigNumeroLot,
    this.rigDateAdministration,
  });

  int get dosesAdministrees => doses.where((d) => d.estAdministree).length;
  int get dosesRestantes => doses.where((d) => d.statut == DoseStatut.prevue || d.statut == DoseStatut.reportee).length;
  int get totalDoses => doses.length;
  bool get estTermine => doses.every((d) => d.estAdministree);
  DoseModel? get prochaineDose => doses.where((d) =>
    d.statut == DoseStatut.prevue || d.statut == DoseStatut.reportee
  ).firstOrNull;

  /// Prochaine dose non réalisée la plus urgente
  DoseModel? get prochaineDoseUrgente => doses.where((d) =>
    (d.statut == DoseStatut.prevue || d.statut == DoseStatut.reportee) && !d.estAVenir
  ).firstOrNull;

  List<DoseModel> get dosesEnRetard => doses.where((d) => d.estEnRetard).toList();

  /// Doses dont la date prévue tombe aujourd'hui
  List<DoseModel> get dosesAujourdhui => doses.where((d) => d.estAujourdhui).toList();

  bool get aDoseAujourdhui => dosesAujourdhui.isNotEmpty;
  bool get aRetard => dosesEnRetard.isNotEmpty;
  bool get estEnCours => !estTermine && doses.any((d) => d.estAdministree);
}
