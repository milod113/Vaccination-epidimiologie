import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../screens/create_patient_screen.dart';
import '../screens/dashboard_antirabique.dart';
import '../screens/patient_list_antirabique.dart';
import '../screens/patient_detail_antirabique.dart';
import '../screens/rabies_dossier_detail_screen.dart';
import '../screens/rabies_dossier_list_screen.dart';
import '../screens/tabs/stock_dashboard.dart';
import '../screens/tabs/scanner_lot_screen.dart';

class AntirabiqueDashboardLayout extends StatefulWidget {
  const AntirabiqueDashboardLayout({super.key});

  @override
  State<AntirabiqueDashboardLayout> createState() => _AntirabiqueDashboardLayoutState();
}

class _AntirabiqueDashboardLayoutState extends State<AntirabiqueDashboardLayout> {
  String? _selectedPatientId;
  String? _selectedDossierId;
  int _currentNavIndex = 0;
  int _reloadToken = 0;

  /// Ouvre l'écran d'admission ; à la création, rafraîchit la liste et
  /// sélectionne le nouveau patient.
  Future<void> _openCreatePatient() async {
    final created = await Navigator.of(context).push<PatientAntirabiqueModel>(
      MaterialPageRoute(builder: (_) => const CreatePatientScreen()),
    );
    if (created == null || !mounted) return;
    setState(() {
      _reloadToken++;
      _selectedPatientId = created.id;
      final isWide = MediaQuery.of(context).size.width > 800;
      _currentNavIndex = isWide ? 0 : 1;
    });
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
            child: SafeArea(
              child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
            ),
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
            children: [
              SizedBox(
                width: 380,
                child: Column(
                  children: [
                    _buildSidebarHeader(),
                    Container(height: 1, color: EpidemiologyTheme.warm100),
                    Expanded(
                      child: _currentNavIndex == 1
                          ? RabiesDossierListScreen(
                              onDossierSelected: (id) => setState(() => _selectedDossierId = id),
                            )
                          : PatientListAntirabique(
                              onPatientSelected: (id) => setState(() => _selectedPatientId = id),
                              onCreatePatient: _openCreatePatient,
                              reloadToken: _reloadToken,
                            ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: EpidemiologyTheme.warm150),
              Expanded(
                child: _currentNavIndex == 1
                    ? _selectedDossierId != null
                        ? RabiesDossierDetailScreen(
                            dossierId: _selectedDossierId!,
                            onBack: () => setState(() => _selectedDossierId = null),
                          )
                        : DashboardAntirabique(onAdmitPatient: _openCreatePatient)
                    : _selectedPatientId != null
                        ? PatientDetailAntirabique(
                            patientId: _selectedPatientId!,
                            onBack: () => setState(() => _selectedPatientId = null),
                          )
                        : DashboardAntirabique(onAdmitPatient: _openCreatePatient),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Narrow layout (≤800px) ────────────────────────────────────────
  Widget _buildNarrowLayout() {
    return Column(
      children: [
        _buildMobileNavBar(),
        Expanded(
          child: IndexedStack(
            index: _currentNavIndex,
            children: [
              DashboardAntirabique(
                onNavigateToListe: () => setState(() => _currentNavIndex = 1),
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

  // ── Sidebar header ──────────────────────────────────────────────
  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(gradient: EpidemiologyTheme.primaryGradientWarm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.biotech, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text('Vaccination\nAntirabique',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2))),
              GestureDetector(
                onTap: () => setState(() => _selectedPatientId = null),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.dashboard, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _sidebarBadge(Icons.people, 'Patients', active: _currentNavIndex == 0, onTap: () => setState(() => _currentNavIndex = 0)),
              const SizedBox(width: 8),
              _sidebarBadge(Icons.folder_copy, 'Dossiers', active: _currentNavIndex == 1, onTap: () => setState(() => _currentNavIndex = 1)),
              const SizedBox(width: 8),
              _sidebarBadge(Icons.inventory_2, 'Stocks', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockDashboard()))),
              const SizedBox(width: 8),
              _sidebarBadge(Icons.qr_code_scanner, 'Scanner', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScannerLotScreen()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sidebarBadge(IconData icon, String label, {VoidCallback? onTap, bool active = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.85)),
            const SizedBox(width: 5),
            Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85))),
          ],
        ),
      ),
    );
  }

  // ── Mobile nav bar ──────────────────────────────────────────────
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
                _navButton(Icons.dashboard, 'Dashboard', 0),
                _navButton(Icons.people, 'Patients', 1),
                _navButton(Icons.folder_copy, 'Dossiers', 2),
                _navIcon(Icons.inventory_2, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockDashboard()))),
                _navIcon(Icons.qr_code_scanner, () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScannerLotScreen()))),
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

  Widget _navButton(IconData icon, String label, int index) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
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
