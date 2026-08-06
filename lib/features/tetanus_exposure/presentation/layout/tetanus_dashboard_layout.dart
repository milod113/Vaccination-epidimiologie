import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../core/widgets/premium_sidebar/premium_sidebar.dart';
import '../../../../core/widgets/premium_sidebar/premium_sidebar_models.dart';
import '../navigation/tetanus_destination.dart';
import '../screens/tetanus_historique_screen.dart';
import '../screens/tetanus_home_screen.dart';
import '../screens/tetanus_evaluation_screen.dart';
import '../screens/tetanus_patient_list_screen.dart';
import '../../domain/repositories/tetanus_repository.dart';

/// Layout principal du module « Tétanos post-exposition ».
///
/// Reprend exactement la logique de la plateforme (identique au module
/// antirabique) : sidebar premium (login, identité de module, navigation,
/// actions rapides, résumé du centre), zone de contenu et layout étroit avec
/// barre de navigation mobile.
class TetanusDashboardLayout extends StatefulWidget {
  const TetanusDashboardLayout({super.key});

  @override
  State<TetanusDashboardLayout> createState() => _TetanusDashboardLayoutState();
}

class _TetanusDashboardLayoutState extends State<TetanusDashboardLayout> {
  final _repo = GetIt.instance<TetanusRepository>();
  Map<String, int> _counts = const {};
  TetanusDestination _currentDest = TetanusDestination.dashboard;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _counts = _repo.getDashboardCounts();
  }

  int get _total => _counts['total'] ?? 0;
  int get _enCours => _counts['enCours'] ?? 0;
  int get _urgent => _counts['urgent'] ?? 0;
  int get _clos => _counts['clos'] ?? 0;

  void _openRoute(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _handleNavigate(TetanusDestination dest) {
    switch (dest) {
      case TetanusDestination.dashboard:
        setState(() => _currentDest = TetanusDestination.dashboard);
      case TetanusDestination.patients:
        _openRoute(const TetanusPatientListScreen());
      case TetanusDestination.checklist:
        _openRoute(const TetanusEvaluationScreen());
      case TetanusDestination.historique:
      case TetanusDestination.suivi:
        _openRoute(const TetanusHistoriqueScreen());
      case TetanusDestination.parametres:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paramètres : bientôt disponible')),
        );
    }
  }

  List<SidebarSection<TetanusDestination>> _buildSections() {
    return [
      const SidebarSection('Navigation', [
        SidebarNavItemModel(
          label: 'Dashboard',
          icon: Icons.space_dashboard,
          destination: TetanusDestination.dashboard,
        ),
      ]),
      SidebarSection('Dossiers cliniques', [
        SidebarNavItemModel(
          label: 'Patients',
          icon: Icons.people_outline,
          destination: TetanusDestination.patients,
          badge: _total,
        ),
      ]),
      const SidebarSection('Suivi & prévention', [
        SidebarNavItemModel(
          label: 'Évaluation',
          icon: Icons.assignment_outlined,
          destination: TetanusDestination.checklist,
        ),
        SidebarNavItemModel(
          label: 'Historique',
          icon: Icons.timeline_rounded,
          destination: TetanusDestination.historique,
        ),
        SidebarNavItemModel(
          label: 'Suivi',
          icon: Icons.follow_the_signs,
          destination: TetanusDestination.suivi,
        ),
      ]),
      const SidebarSection('Système', [
        SidebarNavItemModel(
          label: 'Paramètres',
          icon: Icons.settings_outlined,
          destination: TetanusDestination.parametres,
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
        onTap: () => _openRoute(const TetanusEvaluationScreen()),
      ),
      SidebarQuickAction(
        label: 'Liste des cas',
        icon: Icons.list_alt_rounded,
        color: EpidemiologyTheme.redPrimary,
        onTap: () => _openRoute(const TetanusPatientListScreen()),
      ),
      SidebarQuickAction(
        label: 'Enregistrer acte',
        icon: Icons.vaccines_outlined,
        color: EpidemiologyTheme.warning,
        onTap: () => _openRoute(const TetanusHistoriqueScreen()),
      ),
      SidebarQuickAction(
        label: 'Suivi rapide',
        icon: Icons.follow_the_signs,
        color: EpidemiologyTheme.indigo,
        onTap: () => _openRoute(const TetanusHistoriqueScreen()),
      ),
    ];
  }

  List<SidebarStatsEntry> _buildStats() {
    return [
      SidebarStatsEntry(
        value: '$_total',
        label: 'Patients en suivi',
        icon: Icons.people,
        color: EpidemiologyTheme.success,
      ),
      SidebarStatsEntry(
        value: '$_enCours',
        label: 'Dossiers en cours',
        icon: Icons.pending_outlined,
        color: EpidemiologyTheme.redMedium,
      ),
      SidebarStatsEntry(
        value: '$_urgent',
        label: 'Prise en charge urgente',
        icon: Icons.warning_amber_rounded,
        color: EpidemiologyTheme.danger,
      ),
      SidebarStatsEntry(
        value: '$_clos',
        label: 'Dossiers clos',
        icon: Icons.check_circle_outline,
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
              PremiumSidebar<TetanusDestination>(
                identity: const SidebarIdentity(
                  title: 'Tétanos\npost-exposition',
                  subtitle: "Service d'épidémiologie",
                  centerLabel: 'Centre de Tétanos',
                  icon: Icons.healing,
                ),
                sections: _buildSections(),
                current: _currentDest,
                onNavigate: _handleNavigate,
                quickActions: _buildQuickActions(),
                stats: _buildStats(),
                statsTitle: 'RÉSUMÉ DU CENTRE',
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
      case TetanusDestination.dashboard:
      default:
        return const TetanusDashboardBody();
    }
  }

  // ── Narrow layout (≤800px) ────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildMobileNavBar(),
        const Expanded(child: TetanusDashboardBody()),
      ],
    );
  }

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
            child: const Icon(Icons.healing, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text('Tétanos post-exposition',
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2)),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _navIcon(Icons.people, () => _openRoute(const TetanusPatientListScreen())),
                _navIcon(Icons.assignment_outlined, () => _openRoute(const TetanusEvaluationScreen())),
                _navIcon(Icons.history_rounded, () => _openRoute(const TetanusHistoriqueScreen())),
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
}