import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/dashboard_antirabique_models.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../domain/repositories/dashboard_antirabique_repository.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../../domain/repositories/stock_repository.dart';
import '../screens/create_patient_screen.dart';
import '../screens/dashboard_antirabique.dart';
import '../screens/evaluation_initiale_screen.dart';
import '../screens/patient_detail_antirabique.dart';
import '../screens/patient_list_antirabique.dart';
import '../screens/rabies_dossier_detail_screen.dart';
import '../screens/rabies_dossier_list_screen.dart';
import '../screens/rabies_follow_up_screen.dart';
import '../screens/rabies_j0_form_screen.dart';
import '../screens/rabies_traceability_screen.dart';
import '../screens/rabies_vaccination_book_screen.dart';
import '../screens/tabs/certificat_screen.dart';
import '../screens/tabs/protocole_vaccinal_tab.dart';
import '../screens/tabs/scanner_lot_screen.dart';
import '../screens/tabs/stock_dashboard.dart';
import '../screens/tabs/suivi_clinique_tab.dart';
import '../widgets/sidebar/antirabique_sidebar.dart';
import '../widgets/sidebar/sidebar_models.dart';

class AntirabiqueDashboardLayout extends StatefulWidget {
  const AntirabiqueDashboardLayout({super.key});

  @override
  State<AntirabiqueDashboardLayout> createState() => _AntirabiqueDashboardLayoutState();
}

class _AntirabiqueDashboardLayoutState extends State<AntirabiqueDashboardLayout> {
  String? _selectedPatientId;
  String? _selectedDossierId;
  AntirabiqueDestination _currentDest = AntirabiqueDestination.dashboard;
  int _reloadToken = 0;
  bool _collapsed = false;

  DashboardAntirabiqueData? _dash;
  int _dossierCount = 0;
  int _stockAlertes = 0;

  String get _resolvedPatientId => _selectedPatientId ?? 'PAT-001';
  String get _resolvedDossierId => _selectedDossierId ?? 'RAB-001';

  @override
  void initState() {
    super.initState();
    _loadSidebarData();
  }

  /// Charge les compteurs / indicateurs affichés dans la sidebar (mock data).
  Future<void> _loadSidebarData() async {
    try {
      final dash = await di.sl<DashboardAntirabiqueRepository>().getDashboardData();
      final dossiers = await di.sl<RabiesDossierRepository>().getDossiers();
      final stock = await di.sl<StockRepository>().getStockStats();
      if (!mounted) return;
      setState(() {
        _dash = dash;
        _dossierCount = dossiers.length;
        _stockAlertes = stock.lotsPeremptibles + stock.lotsExpires;
      });
    } catch (_) {
      // Les valeurs par défaut restent appliquées si le chargement mock échoue.
    }
  }

  /// Ouvre l'écran d'admission ; à la création, bascule sur la liste des
  /// patients avec sélection du nouveau patient.
  Future<void> _openCreatePatient() async {
    final created = await Navigator.of(context).push<PatientAntirabiqueModel>(
      MaterialPageRoute(builder: (_) => const CreatePatientScreen()),
    );
    if (created == null || !mounted) return;
    setState(() {
      _reloadToken++;
      _selectedPatientId = created.id;
      _currentDest = AntirabiqueDestination.patients;
    });
  }

  void _openRoute(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _pushPatient(
      Widget Function(String patientId, String nomComplet) builder) async {
    final id = _resolvedPatientId;
    String nom = id;
    try {
      final p = await di.sl<PatientAntirabiqueRepository>().getPatientById(id);
      nom = p?.nomComplet ?? id;
    } catch (_) {}
    if (!mounted) return;
    _openRoute(builder(id, nom));
  }

  Widget _standalonePage(String title, Widget child) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: child,
    );
  }

  void _handleNavigate(AntirabiqueDestination dest) {
    switch (dest) {
      case AntirabiqueDestination.dashboard:
        setState(() {
          _currentDest = AntirabiqueDestination.dashboard;
          _selectedPatientId = null;
          _selectedDossierId = null;
        });
      case AntirabiqueDestination.patients:
        setState(() => _currentDest = AntirabiqueDestination.patients);
      case AntirabiqueDestination.dossiers:
        setState(() => _currentDest = AntirabiqueDestination.dossiers);
      case AntirabiqueDestination.evaluation:
        _pushPatient((id, _) => EvaluationInitialeScreen(patientId: id));
      case AntirabiqueDestination.carnet:
        _pushPatient((id, _) => RabiesVaccinationBookScreen(patientId: id));
      case AntirabiqueDestination.protocoles:
        _pushPatient((id, _) => ProtocoleVaccinalTab(patientId: id));
      case AntirabiqueDestination.suivi:
        _pushPatient((id, _) => _standalonePage('Suivi clinique', SuiviCliniqueTab(patientId: id)));
      case AntirabiqueDestination.tracabilite:
        _openRoute(RabiesTraceabilityScreen(dossierId: _resolvedDossierId));
      case AntirabiqueDestination.certificats:
        _pushPatient((id, nom) => CertificatScreen(patientId: id, patientNom: nom));
      case AntirabiqueDestination.stocks:
        _openRoute(const StockDashboard());
      case AntirabiqueDestination.scanner:
        _openRoute(const ScannerLotScreen());
      case AntirabiqueDestination.parametres:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres : bientôt disponible')),
        );
    }
  }

  // ── Sections & données de la sidebar ────────────────────────────────
  List<SidebarSection> _buildSections() {
    return [
      const SidebarSection('Navigation', [
        SidebarNavItemModel(
          label: 'Dashboard',
          icon: Icons.space_dashboard,
          destination: AntirabiqueDestination.dashboard,
        ),
      ]),
      SidebarSection('Dossiers cliniques', [
        SidebarNavItemModel(
          label: 'Patients',
          icon: Icons.people_outline,
          destination: AntirabiqueDestination.patients,
          badge: _dash?.patientsEnSuivi ?? 9,
        ),
        SidebarNavItemModel(
          label: 'Dossiers',
          icon: Icons.folder_copy_outlined,
          destination: AntirabiqueDestination.dossiers,
          badge: _dossierCount > 0 ? _dossierCount : 11,
        ),
      ]),
      const SidebarSection('Suivi & protocole', [
        SidebarNavItemModel(
          label: 'Évaluation J0',
          icon: Icons.assignment,
          destination: AntirabiqueDestination.evaluation,
        ),
        SidebarNavItemModel(
          label: 'Carnet vaccinal',
          icon: Icons.menu_book_outlined,
          destination: AntirabiqueDestination.carnet,
        ),
        SidebarNavItemModel(
          label: 'Protocoles',
          icon: Icons.schedule_outlined,
          destination: AntirabiqueDestination.protocoles,
          badge: 2,
          badgeTone: SidebarBadgeTone.warning,
        ),
        SidebarNavItemModel(
          label: 'Suivi clinique',
          icon: Icons.checklist_rtl,
          destination: AntirabiqueDestination.suivi,
          badge: 3,
          badgeTone: SidebarBadgeTone.danger,
        ),
        SidebarNavItemModel(
          label: 'Traçabilité',
          icon: Icons.account_tree_outlined,
          destination: AntirabiqueDestination.tracabilite,
        ),
      ]),
      SidebarSection('Approvisionnement', [
        SidebarNavItemModel(
          label: 'Stocks',
          icon: Icons.inventory_2_outlined,
          destination: AntirabiqueDestination.stocks,
          badge: _stockAlertes > 0 ? _stockAlertes : null,
          badgeTone: SidebarBadgeTone.warning,
        ),
        const SidebarNavItemModel(
          label: 'Scanner',
          icon: Icons.qr_code_scanner,
          destination: AntirabiqueDestination.scanner,
        ),
        const SidebarNavItemModel(
          label: 'Certificats',
          icon: Icons.verified_outlined,
          destination: AntirabiqueDestination.certificats,
        ),
      ]),
    ];
  }

  List<SidebarQuickAction> _buildQuickActions() {
    return [
      SidebarQuickAction(
        label: 'Nouveau patient',
        icon: Icons.person_add_alt,
        color: EpidemiologyTheme.success,
        onTap: _openCreatePatient,
      ),
      SidebarQuickAction(
        label: 'Créer dossier',
        icon: Icons.note_add,
        color: EpidemiologyTheme.redPrimary,
        onTap: () => _openRoute(RabiesJ0FormScreen(dossierId: _resolvedDossierId)),
      ),
      SidebarQuickAction(
        label: 'Lancer J0',
        icon: Icons.play_circle_outline,
        color: EpidemiologyTheme.warning,
        onTap: () => _openRoute(RabiesFollowUpScreen(dossierId: _resolvedDossierId)),
      ),
      SidebarQuickAction(
        label: 'Scanner lot',
        icon: Icons.qr_code_scanner,
        color: EpidemiologyTheme.indigo,
        onTap: () => _openRoute(const ScannerLotScreen()),
      ),
    ];
  }

  List<SidebarStatsEntry> _buildStats() {
    return [
      SidebarStatsEntry(
        value: '${_dash?.patientsEnSuivi ?? 9}',
        label: 'Patients en suivi',
        icon: Icons.people,
        color: EpidemiologyTheme.success,
      ),
      SidebarStatsEntry(
        value: '${_dash?.vaccinationsDuJour ?? 5}',
        label: 'Doses du jour',
        icon: Icons.vaccines,
        color: EpidemiologyTheme.redMedium,
      ),
      SidebarStatsEntry(
        value: '${_dash?.alertesCritiques ?? 3}',
        label: 'Alertes critiques',
        icon: Icons.error_outline,
        color: EpidemiologyTheme.danger,
      ),
      SidebarStatsEntry(
        value: '${_dash?.patientsEnRetard ?? 2}',
        label: 'En retard',
        icon: Icons.warning_amber,
        color: EpidemiologyTheme.warning,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        return Scaffold(
          backgroundColor: EpidemiologyTheme.warm50,
          body: Container(
            decoration: BoxDecoration(gradient: EpidemiologyTheme.surfaceGradient),
            child: SafeArea(child: isWide ? _buildWideLayout() : _buildNarrowLayout()),
          ),
        );
      },
    );
  }

  // ── Wide layout (≥800px) ──────────────────────────────────────────
  Widget _buildWideLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: EpidemiologyTheme.blackWith(0.08), blurRadius: 30, offset: const Offset(0, 6)),
            BoxShadow(color: EpidemiologyTheme.warmShadow(0.04), blurRadius: 14, offset: const Offset(0, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AntirabiqueSidebar(
                sections: _buildSections(),
                current: _currentDest,
                onNavigate: _handleNavigate,
                quickActions: _buildQuickActions(),
                stats: _buildStats(),
                collapsed: _collapsed,
                onToggleCollapsed: () => setState(() => _collapsed = !_collapsed),
              ),
              Container(width: 1, color: EpidemiologyTheme.warm150.withValues(alpha: 0.8)),
              Expanded(child: _buildMainContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentDest) {
      case AntirabiqueDestination.patients:
        return _selectedPatientId != null
            ? PatientDetailAntirabique(
                patientId: _selectedPatientId!,
                onBack: () => setState(() => _selectedPatientId = null),
              )
            : PatientListAntirabique(
                onPatientSelected: (id) => setState(() => _selectedPatientId = id),
                onCreatePatient: _openCreatePatient,
                reloadToken: _reloadToken,
              );
      case AntirabiqueDestination.dossiers:
        return _selectedDossierId != null
            ? RabiesDossierDetailScreen(
                dossierId: _selectedDossierId!,
                onBack: () => setState(() => _selectedDossierId = null),
              )
            : RabiesDossierListScreen(
                onDossierSelected: (id) => setState(() => _selectedDossierId = id),
              );
      case AntirabiqueDestination.dashboard:
      default:
        return DashboardAntirabique(
          onNavigateToListe: () => setState(() => _currentDest = AntirabiqueDestination.patients),
          onAdmitPatient: _openCreatePatient,
        );
    }
  }

  // ── Narrow layout (≤800px) ────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildMobileNavBar(),
        Expanded(
          child: IndexedStack(
            index: _narrowIndex,
            children: [
              DashboardAntirabique(
                onNavigateToListe: () => setState(() => _currentDest = AntirabiqueDestination.patients),
                onAdmitPatient: _openCreatePatient,
              ),
              PatientListAntirabique(
                onPatientSelected: (id) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Scaffold(body: PatientDetailAntirabique(patientId: id)),
                  ));
                },
                onCreatePatient: _openCreatePatient,
                reloadToken: _reloadToken,
              ),
              RabiesDossierListScreen(
                onDossierSelected: (id) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => Scaffold(body: RabiesDossierDetailScreen(dossierId: id)),
                  ));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  int get _narrowIndex => switch (_currentDest) {
    AntirabiqueDestination.patients => 1,
    AntirabiqueDestination.dossiers => 2,
    _ => 0,
  };

  // ── Mobile nav bar ───────────────────────────────────────────────
  Widget _buildMobileNavBar() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 12, top: MediaQuery.of(context).padding.top + 8, bottom: 8),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        boxShadow: [BoxShadow(color: EpidemiologyTheme.redDeep.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.biotech, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text('Vaccination Antirabique',
            style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2))),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _navButton(Icons.dashboard, 'Dashboard', AntirabiqueDestination.dashboard),
                _navButton(Icons.people, 'Patients', AntirabiqueDestination.patients),
                _navButton(Icons.folder_copy, 'Dossiers', AntirabiqueDestination.dossiers),
                _navIcon(Icons.inventory_2, () => _openRoute(const StockDashboard())),
                _navIcon(Icons.qr_code_scanner, () => _openRoute(const ScannerLotScreen())),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _navButton(IconData icon, String label, AntirabiqueDestination dest) {
    final isActive = _currentDest == dest;
    return GestureDetector(
      onTap: () => _handleNavigate(dest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            if (isActive) ...[
              const SizedBox(width: 5),
              Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }
}