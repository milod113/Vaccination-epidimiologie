enum LotStatut { disponible, epuise, expire, quarantine }

extension LotStatutX on LotStatut {
  String get label {
    switch (this) {
      case LotStatut.disponible:
        return 'Disponible';
      case LotStatut.epuise:
        return 'Épuisé';
      case LotStatut.expire:
        return 'Expiré';
      case LotStatut.quarantine:
        return 'En quarantaine';
    }
  }
}

class LotVaccinModel {
  final String id;
  final String numeroLot;
  final String vaccinNom;
  final String fabricant;
  final String dateFabrication;
  final String dateExpiration;
  final int quantiteInitiale;
  final int quantiteRestante;
  final LotStatut statut;
  final String? notes;

  const LotVaccinModel({
    required this.id,
    required this.numeroLot,
    required this.vaccinNom,
    required this.fabricant,
    required this.dateFabrication,
    required this.dateExpiration,
    required this.quantiteInitiale,
    required this.quantiteRestante,
    this.statut = LotStatut.disponible,
    this.notes,
  });

  bool get estExpire {
    final exp = DateTime.tryParse(dateExpiration);
    if (exp == null) return false;
    return exp.isBefore(DateTime.now());
  }

  bool get estPeremptible {
    final exp = DateTime.tryParse(dateExpiration);
    if (exp == null) return false;
    return exp.isBefore(DateTime.now().add(const Duration(days: 90)));
  }

  int get joursRestants {
    final exp = DateTime.tryParse(dateExpiration);
    if (exp == null) return 0;
    return exp.difference(DateTime.now()).inDays;
  }

  double get tauxUtilisation =>
      quantiteInitiale == 0 ? 0 : ((quantiteInitiale - quantiteRestante) / quantiteInitiale * 100);
}

class StockStats {
  final int lotsDisponibles;
  final int lotsExpires;
  final int lotsPeremptibles;
  final int dosesRestantes;
  final int dosesUtiliseesMois;

  const StockStats({
    required this.lotsDisponibles,
    required this.lotsExpires,
    required this.lotsPeremptibles,
    required this.dosesRestantes,
    required this.dosesUtiliseesMois,
  });
}
