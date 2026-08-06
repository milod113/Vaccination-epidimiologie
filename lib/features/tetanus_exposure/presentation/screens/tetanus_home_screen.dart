import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/tetanus_repository.dart';
import 'tetanus_patient_list_screen.dart';
import 'tetanus_checklist_screen.dart';
import 'tetanus_historique_screen.dart';

class TetanusHomeScreen extends StatefulWidget {
  const TetanusHomeScreen({super.key});

  @override
  State<TetanusHomeScreen> createState() => _TetanusHomeScreenState();
}

class _TetanusHomeScreenState extends State<TetanusHomeScreen> {
  final _repo = GetIt.instance<TetanusRepository>();
  late Map<String, int> _counts;

  @override
  void initState() {
    super.initState();
    _counts = _repo.getDashboardCounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        title: Text(
          'Tétanos post-exposition',
          style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800),
        ),
        centerTitle: false,
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
          bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Aperçu', Icons.dashboard_rounded),
          const SizedBox(height: 14),
          _buildKpiRow(),
          const SizedBox(height: 28),
          _buildSectionHeader('Accès rapide', Icons.quickreply_rounded),
          const SizedBox(height: 14),
          _buildQuickAccessGrid(),
          const SizedBox(height: 28),
          _buildSectionHeader('Conduite à tenir', Icons.medical_services_outlined),
          const SizedBox(height: 14),
          _buildDecisionCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: EpidemiologyTheme.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: EpidemiologyTheme.amber),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    final today = DateTime.now();
    final dateStr =
        '${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}';
    final total = _counts['total'] ?? 0;
    final urgent = _counts['urgent'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EpidemiologyTheme.amber, EpidemiologyTheme.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.amber.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: EpidemiologyTheme.amber.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.healing_rounded,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prophylaxie antitétanique',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Tétanos post-exposition',
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 13, color: Colors.white.withValues(alpha: 0.85)),
                            const SizedBox(width: 6),
                            Text(
                              dateStr,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _heroStat('$total', 'Patients\nen suivi'),
                        const Spacer(),
                        _heroStat('${_counts['enCours'] ?? 0}', 'Dossiers\nen cours'),
                        const Spacer(),
                        _heroStat('$urgent', 'Alertes\nactives'),
                        const Spacer(),
                        _heroStat('${_counts['clos'] ?? 0}', 'Dossiers\nclos'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: Text(
                urgent > 0
                    ? '$urgent patient${urgent > 1 ? 's' : ''} nécessite${urgent > 1 ? 'nt' : ''} une prise en charge urgente'
                    : 'Aucune alerte en cours',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final items = [
          _kpiCard('Patients', _counts['total'] ?? 0, Icons.people_outline, EpidemiologyTheme.info),
          _kpiCard('En cours', _counts['enCours'] ?? 0, Icons.pending_outlined, EpidemiologyTheme.warning),
          _kpiCard('Urgents', _counts['urgent'] ?? 0, Icons.warning_amber_outlined, EpidemiologyTheme.danger),
          _kpiCard('Clos', _counts['clos'] ?? 0, Icons.check_circle_outline, EpidemiologyTheme.success),
        ];
        if (isWide) {
          return Row(children: items.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: w))).toList());
        }
        return Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((w) => SizedBox(width: (constraints.maxWidth - 8) / 2, child: w)).toList(),
        );
      },
    );
  }

  Widget _kpiCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          ...EpidemiologyTheme.shadowSm,
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 22, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w500, color: EpidemiologyTheme.warm400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final items = [
      _quickAccessTile(Icons.person_add_rounded, 'Nouveau patient', 'Checklist initiale',
          const TetanusChecklistScreen()),
      _quickAccessTile(Icons.list_alt_rounded, 'Liste des cas', 'Consulter les patients',
          const TetanusPatientListScreen()),
      _quickAccessTile(Icons.vaccines_rounded, 'Enregistrer acte', 'VAT, Ig, rappel',
          const TetanusHistoriqueScreen()),
      _quickAccessTile(Icons.history_rounded, 'Historique', 'Traçabilité des actes',
          const TetanusHistoriqueScreen()),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: items[0]), const SizedBox(width: 12),
              Expanded(child: items[1]), const SizedBox(width: 12),
              Expanded(child: items[2]), const SizedBox(width: 12),
              Expanded(child: items[3]),
            ],
          );
        }
        return Column(
          children: [
            Row(children: [Expanded(child: items[0]), const SizedBox(width: 10), Expanded(child: items[1])]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: items[2]), const SizedBox(width: 10), Expanded(child: items[3])]),
          ],
        );
      },
    );
  }

  Widget _quickAccessTile(IconData icon, String title, String subtitle, Widget destination) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: EpidemiologyTheme.warm100),
            boxShadow: EpidemiologyTheme.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EpidemiologyTheme.amber.withValues(alpha: 0.12), EpidemiologyTheme.orange.withValues(alpha: 0.06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: EpidemiologyTheme.amber, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: EpidemiologyTheme.warm400),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: EpidemiologyTheme.warm300),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDecisionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_services_outlined,
                    size: 18, color: EpidemiologyTheme.amber),
              ),
              const SizedBox(width: 12),
              Text(
                'Conduite à tenir selon le statut vaccinal',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _decisionRow('À jour', 'Plaie propre → Surveillance', 'Plaie tétanigène → Rappel (>5 ans)',
              EpidemiologyTheme.success),
          _decisionRow('Incomplet', 'Plaie propre → Rappel VAT', 'Plaie tétanigène → VAT + Ig',
              EpidemiologyTheme.warning),
          _decisionRow('Inconnu', 'Plaie propre → VAT', 'Plaie tétanigène → VAT + Ig',
              EpidemiologyTheme.danger),
          _decisionRow('Non vacciné', 'Plaie propre → VAT', 'Plaie tétanigène → VAT + Ig',
              EpidemiologyTheme.danger),
        ],
      ),
    );
  }

  Widget _decisionRow(String status, String cleanWound, String tetanigene, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanWound,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: EpidemiologyTheme.warm600, height: 1.4),
                ),
                Text(
                  tetanigene,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: EpidemiologyTheme.warm600, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
