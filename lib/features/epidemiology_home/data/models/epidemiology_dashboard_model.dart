class ModuleStatus {
  final int patientsEnSuivi;
  final int patientsEnRetard;
  final int alertes;
  final bool actif;

  const ModuleStatus({
    this.patientsEnSuivi = 0,
    this.patientsEnRetard = 0,
    this.alertes = 0,
    this.actif = false,
  });
}

class EpidemiologyDashboardData {
final int patientsTotal;
  final int vaccinationsAujourdhui;
  final int alertesTotal;
  final int patientsEnRetard;
  final int dossiersActifs;
  final int modulesActifs;
  final ModuleStatus antirabique;
  final ModuleStatus tetanos;
  final ModuleStatus hepatiteB;
  final ModuleStatus voyageur;

  const EpidemiologyDashboardData({
    this.patientsTotal = 0,
    this.vaccinationsAujourdhui = 0,
    this.alertesTotal = 0,
    this.patientsEnRetard = 0,
    this.dossiersActifs = 0,
    this.modulesActifs = 0,
    this.antirabique = const ModuleStatus(),
    this.tetanos = const ModuleStatus(),
    this.hepatiteB = const ModuleStatus(),
    this.voyageur = const ModuleStatus(),
  });
}
