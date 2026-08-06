import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/epidemiology_dashboard_model.dart';
import '../../domain/repositories/epidemiology_dashboard_repository.dart';
import '../../../vaccination_antirabique/presentation/layout/antirabique_dashboard_layout.dart';
import '../../../tetanus_exposure/presentation/screens/tetanus_home_screen.dart';
import '../../../hepatitis_b_exposure/presentation/screens/hepatitis_b_home_screen.dart';
import '../../../travel_vaccination/presentation/screens/travel_vaccination_home_screen.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/module_card.dart';

class EpidemiologyHomeScreen extends StatefulWidget {
  const EpidemiologyHomeScreen({super.key});

  @override
  State<EpidemiologyHomeScreen> createState() => _EpidemiologyHomeScreenState();
}

class _EpidemiologyHomeScreenState extends State<EpidemiologyHomeScreen> {
  EpidemiologyDashboardData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = di.sl<EpidemiologyDashboardRepository>();
    final data = await repo.getDashboardData();
    setState(() { _data = data; _loading = false; });
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
    final isWide = MediaQuery.of(context).size.width > 600;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        _buildHeroHeader(data),
        const SizedBox(height: 28),
        _buildKpiRow(data),
        const SizedBox(height: 32),
        _buildSectionTitle('Modules de vaccination'),
        const SizedBox(height: 16),
        _buildModuleGrid(isWide, data),
        const SizedBox(height: 32),
        _buildSectionTitle('Activité récente'),
        const SizedBox(height: 16),
        _buildActivitySection(data),
      ],
    );
  }

  // ── Hero ──────────────────────────────────────────────────────────
  Widget _buildHeroHeader(EpidemiologyDashboardData data) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: EpidemiologyTheme.redDeep.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 10)),
          BoxShadow(color: EpidemiologyTheme.redDeep.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.local_hospital, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Service d'Épidémiologie",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.75), letterSpacing: 0.3)),
                    const SizedBox(height: 1),
                    Text('Plateforme Vaccination',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: -0.3)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 13, color: Colors.white.withValues(alpha: 0.85)),
                    const SizedBox(width: 6),
                    Text(
                      '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _heroStat('${data.patientsTotal}', 'Patients\ntotaux'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.18)),
              ),
              _heroStat('${data.vaccinationsAujourdhui}', "Vaccinations\naujourd'hui"),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.18)),
              ),
              const SizedBox(width: 28),
              _heroStat('${data.modulesActifs}', 'Modules\nactifs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800,
          color: Colors.white, height: 1.0, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.75), height: 1.25)),
      ],
    );
  }

  // ── KPI row ───────────────────────────────────────────────────────
  Widget _buildKpiRow(EpidemiologyDashboardData data) {
    final items = [
      _kpiItem(Icons.people, '${data.patientsTotal}', 'Patients', EpidemiologyTheme.teal),
      _kpiItem(Icons.vaccines, '${data.vaccinationsAujourdhui}', 'Aujourd\'hui', EpidemiologyTheme.redMedium),
      _kpiItem(Icons.warning_amber, '${data.alertesTotal}', 'Alertes', EpidemiologyTheme.warning),
      _kpiItem(Icons.dashboard, '${data.modulesActifs}', 'Modules', EpidemiologyTheme.indigo),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Row(children: items.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: w))).toList());
        }
        return Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((w) => SizedBox(width: (constraints.maxWidth - 8) / 2, child: w)).toList(),
        );
      },
    );
  }

  Widget _kpiItem(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: EpidemiologyTheme.blackWith(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800,
                color: EpidemiologyTheme.warm900, height: 1.0, letterSpacing: -0.3)),
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: EpidemiologyTheme.warm400)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(width: 3, height: 18,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.redPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title, style: EpidemiologyTheme.h2(color: EpidemiologyTheme.warm900)),
        ],
      ),
    );
  }

  // ── Module grid ──────────────────────────────────────────────────
  Widget _buildModuleGrid(bool isWide, EpidemiologyDashboardData data) {
    final modules = [
      ModuleCard(
        title: 'Vaccination antirabique',
        sousTitre: 'Schémas Essen, Zagreb, IPC',
        description: 'Prise en charge post-exposition complète : évaluation initiale J0, protocole vaccinal, suivi clinique, certificats.',
        icon: Icons.biotech,
        color: EpidemiologyTheme.redMedium,
        patientsEnSuivi: data.antirabique.patientsEnSuivi,
        alertes: data.antirabique.alertes,
        actif: data.antirabique.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const AntirabiqueDashboardLayout(),
        )),
      ),
      ModuleCard(
        title: 'Tétanos post-exposition',
        sousTitre: 'Prophylaxie antitétanique',
        description: 'Évaluation des plaies tétanigènes, statut vaccinal, rappels VAT/Immunoglobulines, suivi des sérologies.',
        icon: Icons.healing,
        color: EpidemiologyTheme.amber,
        patientsEnSuivi: data.tetanos.patientsEnSuivi,
        alertes: data.tetanos.alertes,
        actif: data.tetanos.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const TetanusHomeScreen(),
        )),
      ),
      ModuleCard(
        title: 'Hépatite B post-exposition',
        sousTitre: 'Séroprophylaxie VHB',
        description: 'Conduite à tenir après exposition au VHB : statut vaccinal, sérologies, immunoglobulines, suivi sérologique.',
        icon: Icons.bloodtype,
        color: EpidemiologyTheme.info,
        patientsEnSuivi: data.hepatiteB.patientsEnSuivi,
        alertes: data.hepatiteB.alertes,
        actif: data.hepatiteB.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const HepatitisBHomeScreen(),
        )),
      ),
      ModuleCard(
        title: 'Vaccination du voyageur',
        sousTitre: 'Conseils et prophylaxie',
        description: 'Consultation pré-voyage, vaccins recommandés par destination, rappels, carnet international.',
        icon: Icons.flight,
        color: EpidemiologyTheme.teal,
        patientsEnSuivi: data.voyageur.patientsEnSuivi,
        alertes: data.voyageur.alertes,
        actif: data.voyageur.actif,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const TravelVaccinationHomeScreen(),
        )),
      ),
      ModuleCard(
        title: 'Campagnes & riposte',
        sousTitre: 'Épidémies et programmes',
        description: 'Gestion de campagnes vaccinales, riposte épidémique, vaccination de masse, suivi de couverture.',
        icon: Icons.flag,
        color: EpidemiologyTheme.warm400,
        patientsEnSuivi: 0,
        alertes: 0,
        actif: false,
        enPreparation: true,
      ),
    ];

    if (isWide) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: modules[0]),
              const SizedBox(width: 12),
              Expanded(child: modules[1]),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: modules[2]),
              const SizedBox(width: 12),
              Expanded(child: modules[3]),
            ],
          ),
          const SizedBox(height: 12),
          modules[4],
        ],
      );
    }

    return Column(children: modules.map((m) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: m,
    )).toList());
  }

  // ── Activité récente ──────────────────────────────────────────────
  Widget _buildActivitySection(EpidemiologyDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, size: 18, color: EpidemiologyTheme.warm500),
              const SizedBox(width: 8),
              Text('Aperçu du jour', style: EpidemiologyTheme.subtitle(color: EpidemiologyTheme.warm800)),
            ],
          ),
          const SizedBox(height: 16),
          _activityRow(Icons.vaccines, '${data.vaccinationsAujourdhui} vaccinations programmées',
            'Tous modules confondus', EpidemiologyTheme.redMedium),
          const Divider(height: 20, thickness: 1, color: EpidemiologyTheme.warm100),
          _activityRow(Icons.warning_amber, '${data.alertesTotal} alertes actives',
            'Nécessitent une attention', EpidemiologyTheme.warning),
          const Divider(height: 20, thickness: 1, color: EpidemiologyTheme.warm100),
          _activityRow(Icons.people, '${data.patientsTotal} patients en suivi',
            'Répartis sur ${data.modulesActifs} modules', EpidemiologyTheme.teal),
        ],
      ),
    );
  }

  Widget _activityRow(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm800)),
              Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: EpidemiologyTheme.warm400)),
            ],
          ),
        ),
      ],
    );
  }
}
