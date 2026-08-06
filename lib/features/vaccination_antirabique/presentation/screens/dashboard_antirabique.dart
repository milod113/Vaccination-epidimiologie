import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/dashboard_antirabique_models.dart';
import '../../domain/repositories/dashboard_antirabique_repository.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/kpi_card.dart';
import '../widgets/alert_card.dart';

class DashboardAntirabique extends StatefulWidget {
  final VoidCallback? onNavigateToListe;
  final VoidCallback? onNavigateToPatient;

  /// Action « Admettre un nouveau patient ».
  final VoidCallback? onAdmitPatient;

  const DashboardAntirabique({
    super.key,
    this.onNavigateToListe,
    this.onNavigateToPatient,
    this.onAdmitPatient,
  });

  @override
  State<DashboardAntirabique> createState() => _DashboardAntirabiqueState();
}

class _DashboardAntirabiqueState extends State<DashboardAntirabique> {
  DashboardAntirabiqueData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = di.sl<DashboardAntirabiqueRepository>();
    final data = await repo.getDashboardData();
    setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? const _LoadingSkeleton() : _buildContent();
  }

  Widget _buildContent() {
    final data = _data!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        _buildHeroHeader(data),
        const SizedBox(height: 32),
        _buildKpiRow(data),
        const SizedBox(height: 32),
        _buildProtocoleRepartition(data.repartitionProtocole),
        const SizedBox(height: 32),
        _buildVaccinationsDuJour(data),
        const SizedBox(height: 32),
        _buildAlertesSection(data),
      ],
    );
  }

  // ── Hero header ──────────────────────────────────────────────────
  Widget _buildHeroHeader(DashboardAntirabiqueData data) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
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
                child: const Icon(Icons.biotech, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Service d'Épidémiologie",
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75), letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Centre Antirabique',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                    ),
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
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _heroStat('${data.patientsEnSuivi}', 'Patients\nen suivi'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.18)),
              ),
              _heroStat('${data.vaccinationsDuJour}', "Vaccinations\naujourd'hui"),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Container(width: 1, height: 48, color: Colors.white.withValues(alpha: 0.18)),
              ),
              const SizedBox(width: 28),
              _heroStat('${data.patientsEnRetard}', 'Patients\nen retard'),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.onAdmitPatient != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.onAdmitPatient,
                icon: const Icon(Icons.person_add_alt, color: EpidemiologyTheme.redPrimary, size: 20),
                label: Text(
                  'Admettre un nouveau patient',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EpidemiologyTheme.redPrimary),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
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
        Text(value, style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white, height: 1.0, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75), height: 1.25)),
      ],
    );
  }

  // ── KPI row ──────────────────────────────────────────────────────
  Widget _buildKpiRow(DashboardAntirabiqueData data) {
    final kpis = [
      KpiCard(title: 'Patients en suivi', value: '${data.patientsEnSuivi}', icon: Icons.people, color: EpidemiologyTheme.teal, subtitle: 'Dossiers actifs'),
      KpiCard(title: "Vaccinations aujourd'hui", value: '${data.vaccinationsDuJour}', icon: Icons.vaccines, color: EpidemiologyTheme.redMedium, subtitle: 'Séances programmées'),
      KpiCard(title: 'Patients en retard', value: '${data.patientsEnRetard}', icon: Icons.warning_amber, color: EpidemiologyTheme.warning, subtitle: 'Suivi à reprendre'),
      KpiCard(title: 'Alertes critiques', value: '${data.alertesCritiques}', icon: Icons.error_outline, color: EpidemiologyTheme.danger, subtitle: 'Nécessitent attention'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 720) {
          return Row(children: kpis.map((k) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: k))).toList());
        }
        if (constraints.maxWidth > 400) {
          return Wrap(
            spacing: 12, runSpacing: 12,
            children: kpis.map((k) => SizedBox(width: (constraints.maxWidth - 12) / 2, child: k)).toList(),
          );
        }
        return Column(children: kpis.map((k) => Padding(padding: const EdgeInsets.only(bottom: 12), child: k)).toList());
      },
    );
  }

  // ── Protocole repartition ────────────────────────────────────────
  Widget _buildProtocoleRepartition(RepartitionProtocole repartition) {
    final segments = [
      (label: 'Essen 5 doses', count: repartition.essen, color: EpidemiologyTheme.redDeep),
      (label: 'Essen 4 doses', count: repartition.essenReduit, color: EpidemiologyTheme.redMedium),
      (label: 'Zagreb', count: repartition.zagreb, color: EpidemiologyTheme.burgundy),
      (label: 'IPC', count: repartition.ipc, color: EpidemiologyTheme.carmine),
    ];
    final activeSegments = segments.where((s) => s.count > 0).toList();
    final total = activeSegments.fold(0, (int s, e) => s + e.count);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: EpidemiologyTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpidemiologyTheme.sectionHeader('Répartition des protocoles', icon: Icons.pie_chart),
          const SizedBox(height: 20),
          if (total > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: activeSegments.map((s) => Expanded(
                    flex: s.count,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [s.color, s.color.withValues(alpha: 0.7)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20, runSpacing: 10,
              children: activeSegments.map((s) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 8),
                  Text('${s.label} — ${s.count} patients', style: EpidemiologyTheme.bodySm(color: EpidemiologyTheme.warm600)),
                ],
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // ── Vaccinations du jour ─────────────────────────────────────────
  Widget _buildVaccinationsDuJour(DashboardAntirabiqueData data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: EpidemiologyTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpidemiologyTheme.sectionHeader(
            'Vaccinations du jour',
            icon: Icons.vaccines,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${data.vaccinationsDuJourList.length} prévue(s)',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: EpidemiologyTheme.redPrimary)),
            ),
          ),
          const SizedBox(height: 16),
          if (data.vaccinationsDuJourList.isEmpty)
            EpidemiologyTheme.emptyState(Icons.event_busy, 'Aucune vaccination programmée aujourd\'hui')
          else
            ...data.vaccinationsDuJourList.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warm50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: EpidemiologyTheme.warm100, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [EpidemiologyTheme.redMedium, EpidemiologyTheme.red400], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(v.patientNom, style: EpidemiologyTheme.label(color: EpidemiologyTheme.warm900)),
                          Text('${v.protocole} · Dose ${v.numeroDose}', style: EpidemiologyTheme.caption()),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: v.statut == 'Prévu' ? EpidemiologyTheme.infoLight : EpidemiologyTheme.warningLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(v.statut,
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                          color: v.statut == 'Prévu' ? EpidemiologyTheme.info : EpidemiologyTheme.warning)),
                    ),
                  ],
                ),
              ),
            )),
        ],
      ),
    );
  }

  // ── Alertes ──────────────────────────────────────────────────────
  Widget _buildAlertesSection(DashboardAntirabiqueData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: EpidemiologyTheme.sectionHeader('Alertes', icon: Icons.warning_amber, iconColor: EpidemiologyTheme.danger),
        ),
        ...data.alertes.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AlertCard(alerte: a),
        )),
      ],
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        EpidemiologyTheme.shimmerBox(height: 170),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: List.generate(4, (i) => SizedBox(
            width: MediaQuery.of(context).size.width > 720
                ? (MediaQuery.of(context).size.width - 84) / 4
                : MediaQuery.of(context).size.width > 400
                    ? (MediaQuery.of(context).size.width - 64) / 2
                    : MediaQuery.of(context).size.width - 48,
            child: EpidemiologyTheme.shimmerBox(height: 130),
          )),
        ),
        const SizedBox(height: 32),
        EpidemiologyTheme.shimmerBox(height: 140),
        const SizedBox(height: 32),
        EpidemiologyTheme.shimmerBox(height: 220),
      ],
    );
  }
}
