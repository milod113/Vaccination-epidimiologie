import '../../data/models/tracabilite/lot_vaccin_model.dart';

abstract class StockRepository {
  Future<List<LotVaccinModel>> getLots();
  Future<LotVaccinModel?> getLotByNumero(String numeroLot);
  Future<StockStats> getStockStats();
  Future<void> utiliserDose(String lotId);
  Future<void> ajouterLot(LotVaccinModel lot);
}
