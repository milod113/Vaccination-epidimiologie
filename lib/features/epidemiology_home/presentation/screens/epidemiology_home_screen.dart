import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/epidemiology_dashboard_model.dart';
import '../../domain/repositories/epidemiology_dashboard_repository.dart';
import '../../../vaccination_antirabique/presentation/layout/antirabique_dashboard_layout.dart';
import '../../../tetanus_exposure/presentation/layout/tetanus_dashboard_layout.dart';
import '../../../hepatitis_b_exposure/presentation/screens/hepatitis_b_home_screen.dart';
import '../../../travel_vaccination/presentation/screens/travel_vaccination_home_screen.dart';
import '../../../vaccination_antirabique/presentation/screens/create_patient_screen.dart';
import '../../../vaccination_antirabique/presentation/screens/tabs/scanner_lot_screen.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/dashboard/platform_hero_header.dart';
import '../widgets/dashboard/dashboard_kpi_card.dart';
import '../widgets/dashboard/dashboard_section_title.dart';
import '../widgets/dashboard/module_overview_card.dart';
import '../widgets/dashboard/dashboard_module_grid.dart';
import '../widgets/dashboard/quick_action_panel.dart';
import '../widgets/dashboard/recent_alerts_panel.dart';

class EpidemiologyHomeScreen extends StatefulWidget {
  const EpidemiologyHomeScreen({super.key});

  @override
  State<EpidemiologyHomeScreen> createState() =>
      _EpidemiologyHomeScreenState();
}

class _EpidemiologyHomeScreenState extends State<EpidemiologyHomeScreen>
    with SingleTickerProviderStateMixin {
  EpidemiologyDashboardData? _data;
  bool _loading = true;

  late final AnimationController _revealController;
  late final Animation<double> _revealAnimation;

  final _scrollController = ScrollController();
  final _modulesKey = GlobalKey();
  final _alertsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
    _load();
  }

  Future<void> _load() async {
    final repo = di.sl<EpidemiologyDashboardRepository>();
    final data = await repo.getDashboardData();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Révélation échelonnée d'une section ────────────────────────────
  Widget _reveal(int index, Widget child) {
    final start = (index * 0.14).clamp(0.0, 0.5);
    final end = (start + 0.5).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _revealAnimation,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
      child: child,
    );
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      alignment: 0.06,
    );
  }

  String get _dateLabel {
    final now = DateTime.now();
    const days = [
      'Dimanche', 'Lundi', 'Mardi', 'Mercredi',
      'Jeudi', 'Vendredi', 'Samedi',
    ];
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 44),
      children: [
        _reveal(
          0,
          PlatformHeroHeader(
            platformName: 'Plateforme Vaccination',
            subtitle: "Service d'Épidémiologie",
            dateLabel: _dateLabel,
            modulesActifs: data.modulesActifs,
            modulesTotal: 4,
            ctaLabel: 'Consulter les modules',
            onCta: () => _scrollTo(_modulesKey),
            servicesOperational: true,
          ),
        ),
        const SizedBox(height: 26),
        _reveal(1, _buildKpiSection(data)),
        const SizedBox(height: 26),
        _reveal(2, _buildMiddleBand(data)),
        const SizedBox(height: 30),
        _reveal(3, _buildModulesSection(data)),
        const SizedBox(height: 30),
        _reveal(4, _buildOverviewFooter(data)),
      ],
    );
  }

  // ── Indicateurs clés ───────────────────────────────────────────────
  Widget _buildKpiSection(EpidemiologyDashboardData data) {
    final items = [
      DashboardKpiCard(
        icon: Icons.people_outline,
        value: '${data.patientsTotal}',
        label: 'Patients en suivi',
        hint: "L'ensemble des dossiers",
        accent: EpidemiologyTheme.info,
      ),
      DashboardKpiCard(
        icon: Icons.vaccines_outlined,
        value: '${data.vaccinationsAujourdhui}',
        label: 'Vaccinations ajd',
        hint: 'Tous modules',
        accent: EpidemiologyTheme.redMedium,
      ),
      DashboardKpiCard(
        icon: Icons.folder_copy_outlined,
        value: '${data.dossiersActifs}',
        label: 'Dossiers actifs',
        hint: 'Protocoles en cours',
        accent: EpidemiologyTheme.indigo,
      ),
      DashboardKpiCard(
        icon: Icons.schedule,
        value: '${data.patientsEnRetard}',
        label: 'Patients en retard',
        hint: 'À relancer',
        accent: EpidemiologyTheme.orange,
        onTap: () => _scrollTo(_alertsKey),
      ),
      DashboardKpiCard(
        icon: Icons.warning_amber_outlined,
        value: '${data.alertesTotal}',
        label: 'Alertes actives',
        hint: 'Nécessitent une attention',
        accent: EpidemiologyTheme.danger,
        onTap: () => _scrollTo(_alertsKey),
      ),
      DashboardKpiCard(
        icon: Icons.hub_outlined,
        value: '${data.modulesActifs}',
        label: 'Modules opérationnels',
        hint: 'sur 4 modules',
        accent: EpidemiologyTheme.success,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;
        final cardW = (constraints.maxWidth - (cols - 1) * 12) / cols;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((c) => SizedBox(width: cardW, child: c)).toList(),
        );
      },
    );
  }

  // ── Bande centrale : accès rapides + alertes ───────────────────────
  Widget _buildMiddleBand(EpidemiologyDashboardData data) {
    final quickActions = <QuickAction>[
      QuickAction(
        icon: Icons.person_add_alt_1,
        label: 'Nouveau patient',
        description: 'Admission antirabique',
        color: EpidemiologyTheme.redMedium,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const CreatePatientScreen(),
        )),
      ),
      QuickAction(
        icon: Icons.qr_code_scanner,
        label: 'Scanner un lot',
        description: 'Traçabilité vaccin',
        color: EpidemiologyTheme.indigo,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ScannerLotScreen(),
        )),
      ),
      QuickAction(
        icon: Icons.grid_view_rounded,
        label: 'Modules',
        description: 'Voir les modules de vaccination',
        color: EpidemiologyTheme.teal,
        onTap: () => _scrollTo(_modulesKey),
      ),
      QuickAction(
        icon: Icons.notifications_none_rounded,
        label: 'Vigilance',
        description: 'Retards et alertes',
        color: EpidemiologyTheme.orange,
        onTap: () => _scrollTo(_alertsKey),
      ),
    ];

    final alerts = <RecentAlertItem>[
      RecentAlertItem(
        icon: Icons.schedule,
        title: '${data.patientsEnRetard} patient(s) en retard de protocole',
        subtitle: '${_retardCount(data)} répartis sur les modules actifs',
        color: EpidemiologyTheme.danger,
        time: 'Retard',
        onTap: () => _scrollTo(_modulesKey),
      ),
      RecentAlertItem(
        icon: Icons.notifications_active_outlined,
        title: '${data.alertesTotal} alertes actives',
        subtitle: 'Nécessitent une attention',
        color: EpidemiologyTheme.warning,
        time: "Aujourd'hui",
        onTap: () => _scrollTo(_modulesKey),
      ),
      RecentAlertItem(
        icon: Icons.vaccines_outlined,
        title: '${data.vaccinationsAujourdhui} vaccinations programmées',
        subtitle: 'Tous modules confondus',
        color: EpidemiologyTheme.redMedium,
        time: "Aujourd'hui",
      ),
      RecentAlertItem(
        icon: Icons.people_outline,
        title: '${data.patientsTotal} patients en suivi',
        subtitle: 'Répartis sur ${data.modulesActifs} modules actifs',
        color: EpidemiologyTheme.info,
        time: 'Général',
      ),
    ];

    final alertsPanel = KeyedSubtree(
      key: _alertsKey,
      child: RecentAlertsPanel(
        items: alerts,
        title: 'Alertes & activité',
        subtitle: _dateLabel,
        footerAction: _alertsFooter(),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 780) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: QuickActionPanel(actions: quickActions)),
              const SizedBox(width: 16),
              Expanded(flex: 3, child: alertsPanel),
            ],
          );
        }
        return Column(
          children: [
            QuickActionPanel(actions: quickActions),
            const SizedBox(height: 16),
            alertsPanel,
          ],
        );
      },
    );
  }

  int _retardCount(EpidemiologyDashboardData data) {
    return data.antirabique.patientsEnRetard +
        data.tetanos.patientsEnRetard +
        data.hepatiteB.patientsEnRetard +
        data.voyageur.patientsEnRetard;
  }

  Widget _alertsFooter() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AntirabiqueDashboardLayout(),
        )),
        style: FilledButton.styleFrom(
          backgroundColor: EpidemiologyTheme.redPrimary,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text('Accéder au module antirabique'),
      ),
    );
  }

  // ── Modules de vaccination ────────────────────────────────────────
  Widget _buildModulesSection(EpidemiologyDashboardData data) {
    final modules = <Widget>[
      KeyedSubtree(
        key: _modulesKey,
        child: ModuleOverviewCard(
          title: 'Vaccination antirabique',
          sousTitre: 'Schémas Essen, Zagreb, IPC',
          description:
              'Prise en charge post-exposition complète : évaluation initiale J0, protocole vaccinal, suivi clinique, certificats.',
          icon: Icons.biotech,
          color: EpidemiologyTheme.redMedium,
          patientsEnSuivi: data.antirabique.patientsEnSuivi,
          patientsEnRetard: data.antirabique.patientsEnRetard,
          alertes: data.antirabique.alertes,
          actif: data.antirabique.actif,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AntirabiqueDashboardLayout(),
          )),
        ),
      ),
      ModuleOverviewCard(
        title: 'Tétanos post-exposition',
        sousTitre: 'Prophylaxie antitétanique',
        description:
            'Évaluation des plaies tétanigènes, statut vaccinal, rappels VAT/Immunoglobulines, suivi des sérologies.',
        icon: Icons.healing,
        color: EpidemiologyTheme.amber,
        patientsEnSuivi: data.tetanos.patientsEnSuivi,
        patientsEnRetard: data.tetanos.patientsEnRetard,
        alertes: data.tetanos.alertes,
        actif: data.tetanos.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const TetanusDashboardLayout(),
        )),
      ),
      ModuleOverviewCard(
        title: 'Hépatite B post-exposition',
        sousTitre: 'Séroprophylaxie VHB',
        description:
            'Conduite à tenir après exposition au VHB : statut vaccinal, sérologies, immunoglobulines, suivi sérologique.',
        icon: Icons.bloodtype,
        color: EpidemiologyTheme.info,
        patientsEnSuivi: data.hepatiteB.patientsEnSuivi,
        patientsEnRetard: data.hepatiteB.patientsEnRetard,
        alertes: data.hepatiteB.alertes,
        actif: data.hepatiteB.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const HepatitisBHomeScreen(),
        )),
      ),
      ModuleOverviewCard(
        title: 'Vaccination du voyageur',
        sousTitre: 'Conseils et prophylaxie',
        description:
            'Consultation pré-voyage, vaccins recommandés par destination, rappels, carnet international.',
        icon: Icons.flight,
        color: EpidemiologyTheme.teal,
        patientsEnSuivi: data.voyageur.patientsEnSuivi,
        patientsEnRetard: data.voyageur.patientsEnRetard,
        alertes: data.voyageur.alertes,
        actif: data.voyageur.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const TravelVaccinationHomeScreen(),
        )),
      ),
      ModuleOverviewCard(
        title: 'Campagnes & riposte',
        sousTitre: 'Épidémies et programmes',
        description:
            'Gestion de campagnes vaccinales, riposte épidémique, vaccination de masse, suivi de couverture.',
        icon: Icons.flag,
        color: EpidemiologyTheme.warm400,
        patientsEnSuivi: 0,
        patientsEnRetard: 0,
        alertes: 0,
        actif: false,
        enPreparation: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionTitle(
          title: 'Modules de vaccination',
          subtitle: "Accédez à l'ensemble des parcours",
          icon: Icons.medical_services_outlined,
          accent: EpidemiologyTheme.redPrimary,
        ),
        DashboardModuleGrid(modules: modules),
      ],
    );
  }

  // ── Vue d'ensemble finale ─────────────────────────────────────────
  Widget _buildOverviewFooter(EpidemiologyDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.softGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 20,
                color: EpidemiologyTheme.redMedium,
              ),
              const SizedBox(width: 10),
              Text(
                'Synthèse opérationnelle',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.warm900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.78,
              minHeight: 8,
              color: EpidemiologyTheme.success,
              backgroundColor: EpidemiologyTheme.warm100,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Taux de suivi global : 78% — ${data.patientsEnRetard} dossier(s) à rattraper.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.warm500,
            ),
          ),
        ],
      ),
    );
  }
}