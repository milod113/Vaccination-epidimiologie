import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/tracabilite/lot_vaccin_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/stock_repository.dart';

class MockStockRepository implements StockRepository {
  List<LotVaccinModel> _lots = [];

  MockStockRepository() {
    _lots = [
      LotVaccinModel(
        id: 'LOT-001',
        numeroLot: 'RAB-24A-001',
        vaccinNom: 'Rabipur (PVRV)',
        fabricant: 'CSL Behring',
        dateFabrication: '2025-06-01',
        dateExpiration: '2027-06-01',
        quantiteInitiale: 50,
        quantiteRestante: 42,
        statut: LotStatut.disponible,
        notes: 'Lot principal centre antirabique',
      ),
      LotVaccinModel(
        id: 'LOT-002',
        numeroLot: 'RAB-24A-003',
        vaccinNom: 'Rabipur (PVRV)',
        fabricant: 'CSL Behring',
        dateFabrication: '2025-03-15',
        dateExpiration: '2027-03-15',
        quantiteInitiale: 50,
        quantiteRestante: 38,
        statut: LotStatut.disponible,
      ),
      LotVaccinModel(
        id: 'LOT-003',
        numeroLot: 'RAB-24B-002',
        vaccinNom: 'Verorab (PVRV)',
        fabricant: 'Sanofi Pasteur',
        dateFabrication: '2025-08-01',
        dateExpiration: '2028-08-01',
        quantiteInitiale: 30,
        quantiteRestante: 24,
        statut: LotStatut.disponible,
      ),
      LotVaccinModel(
        id: 'LOT-004',
        numeroLot: 'RAB-24B-005',
        vaccinNom: 'Verorab (PVRV)',
        fabricant: 'Sanofi Pasteur',
        dateFabrication: '2025-08-01',
        dateExpiration: '2028-08-01',
        quantiteInitiale: 30,
        quantiteRestante: 22,
        statut: LotStatut.disponible,
      ),
      LotVaccinModel(
        id: 'LOT-005',
        numeroLot: 'RAB-24A-007',
        vaccinNom: 'Rabipur (PVRV)',
        fabricant: 'CSL Behring',
        dateFabrication: '2024-11-01',
        dateExpiration: '2026-11-01',
        quantiteInitiale: 50,
        quantiteRestante: 3,
        statut: LotStatut.disponible,
        notes: 'Lot bientôt épuisé — commander réapprovisionnement',
      ),
      LotVaccinModel(
        id: 'LOT-006',
        numeroLot: 'RAB-24C-010',
        vaccinNom: 'Speeda (PVRV) — voie ID',
        fabricant: 'Liaoning Cheng Da',
        dateFabrication: '2025-10-01',
        dateExpiration: '2027-10-01',
        quantiteInitiale: 100,
        quantiteRestante: 88,
        statut: LotStatut.disponible,
        notes: 'Lot pour protocole IPC intradermique (0.1 mL/site)',
      ),
      LotVaccinModel(
        id: 'LOT-007',
        numeroLot: 'RAB-23Z-099',
        vaccinNom: 'Rabipur (PVRV)',
        fabricant: 'CSL Behring',
        dateFabrication: '2023-01-01',
        dateExpiration: '2025-01-01',
        quantiteInitiale: 50,
        quantiteRestante: 12,
        statut: LotStatut.expire,
        notes: 'LOT EXPIRÉ — Retrait du stock effectué',
      ),
      LotVaccinModel(
        id: 'LOT-008',
        numeroLot: 'RIG-24A-001',
        vaccinNom: 'Immunoglobuline antirabique humaine',
        fabricant: 'Sanofi Pasteur',
        dateFabrication: '2025-09-01',
        dateExpiration: '2027-09-01',
        quantiteInitiale: 20,
        quantiteRestante: 14,
        statut: LotStatut.disponible,
        notes: 'RIG — 20 UI/kg — usage Cat III uniquement',
      ),
      LotVaccinModel(
        id: 'LOT-009',
        numeroLot: 'RIG-24B-005',
        vaccinNom: 'Immunoglobuline antirabique humaine',
        fabricant: 'Sanofi Pasteur',
        dateFabrication: '2025-11-01',
        dateExpiration: '2027-11-01',
        quantiteInitiale: 15,
        quantiteRestante: 10,
        statut: LotStatut.disponible,
      ),
      LotVaccinModel(
        id: 'LOT-010',
        numeroLot: 'RAB-24B-008',
        vaccinNom: 'Verorab (PVRV)',
        fabricant: 'Sanofi Pasteur',
        dateFabrication: '2025-06-15',
        dateExpiration: '2026-09-20',
        quantiteInitiale: 30,
        quantiteRestante: 30,
        statut: LotStatut.disponible,
        notes: 'NOUVEAU LOT — Non entamé',
      ),
    ];
  }

  @override
  Future<List<LotVaccinModel>> getLots() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_lots);
  }

  @override
  Future<LotVaccinModel?> getLotByNumero(String numeroLot) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _lots.where((l) => l.numeroLot == numeroLot).firstOrNull;
  }

  @override
  Future<StockStats> getStockStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final disponibles = _lots.where((l) => l.statut == LotStatut.disponible).length;
    final expires = _lots.where((l) => l.statut == LotStatut.expire || l.estExpire).length;
    final peremptibles = _lots.where((l) => l.statut == LotStatut.disponible && l.estPeremptible).length;
    final doses = _lots.fold(0, (sum, l) => sum + l.quantiteRestante);
    return StockStats(
      lotsDisponibles: disponibles,
      lotsExpires: expires,
      lotsPeremptibles: peremptibles,
      dosesRestantes: doses,
      dosesUtiliseesMois: 12,
    );
  }

  @override
  Future<void> utiliserDose(String lotId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _lots.indexWhere((l) => l.id == lotId);
    if (idx == -1) return;
    final lot = _lots[idx];
    final nouvelleQte = lot.quantiteRestante - 1;
    _lots[idx] = LotVaccinModel(
      id: lot.id,
      numeroLot: lot.numeroLot,
      vaccinNom: lot.vaccinNom,
      fabricant: lot.fabricant,
      dateFabrication: lot.dateFabrication,
      dateExpiration: lot.dateExpiration,
      quantiteInitiale: lot.quantiteInitiale,
      quantiteRestante: nouvelleQte,
      statut: nouvelleQte <= 0 ? LotStatut.epuise : lot.statut,
      notes: lot.notes,
    );
  }

  @override
  Future<void> ajouterLot(LotVaccinModel lot) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _lots.insert(0, lot);
  }
}
