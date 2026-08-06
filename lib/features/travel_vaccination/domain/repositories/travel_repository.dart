import '../../data/models/travel_models.dart';

abstract class TravelRepository {
  List<TravelPatient> getProchainsDeparts();
  List<DestinationInfo> getDestinations();
  int get totalPatients;
  int get alertCount;
}
