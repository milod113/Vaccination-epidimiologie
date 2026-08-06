import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/hep_b_repository.dart';
import 'hepatitis_b_patient_list_screen.dart';

class HepatitisBHomeScreen extends StatefulWidget {
  const HepatitisBHomeScreen({super.key});

  @override
  State<HepatitisBHomeScreen> createState() => _HepatitisBHomeScreenState();
}

class _HepatitisBHomeScreenState extends State<HepatitisBHomeScreen> {
  final _repo = GetIt.instance<HepBRepository>();
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
        title: const Text('Hépatite B post-exposition'),
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
          bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: EpidemiologyTheme.infoChip(
              Icons.calendar_today,
              '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              EpidemiologyTheme.indigo,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Aperçu clinique', Icons.dashboard_rounded),
          const SizedBox(height: 14),
          _buildKpiRow(),
          const SizedBox(height: 28),
          _buildSectionHeader('Accès rapide', Icons.quickreply_rounded),
          const SizedBox(height: 14),
          _buildQuickAccessGrid(),
          const SizedBox(height: 28),
          _buildSectionHeader('Conduite à tenir', Icons.medical_services_outlined),
          const SizedBox(height: 14),
          _buildProtocolCard(),
          const SizedBox(height: 28),
          _buildSuiviCard(),
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
            color: EpidemiologyTheme.indigo.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: EpidemiologyTheme.indigo),
        ),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800,
        )),
      ],
    );
  }

  Widget _buildHeroCard() {
    final today = DateTime.now();
    final dateStr = '${today.day.toString().padLeft(2, '0')}/'
        '${today.month.toString().padLeft(2, '0')}/'
        '${today.year}';
    final total = _counts['total'] ?? 0;
    final urgent = _counts['urgent'] ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EpidemiologyTheme.indigo, Color(0xFF3730A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.indigo.withValues(alpha: 0.30),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: EpidemiologyTheme.indigo.withValues(alpha: 0.12),
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
                        child: const Icon(Icons.biotech, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Séroprophylaxie VHB',
                              style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Hépatite B\npost-exposition',
                              style: GoogleFonts.inter(
                                fontSize: 22, fontWeight: FontWeight.w800,
                                color: Colors.white, height: 1.1,
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
                            Text(dateStr,
                              style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: Colors.white,
                              )),
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
                        _heroStat('$urgent', 'Cas\nurgents'),
                        const Spacer(),
                        _heroStat('${_counts['serologieEnAttente'] ?? 0}', 'Sérologies\nen attente'),
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
              child: Row(
                children: [
                  Icon(
                    urgent > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    urgent > 0
                        ? '$urgent cas urgent${urgent > 1 ? 's' : ''} nécessitant une intervention immédiate'
                        : 'Aucun cas urgent en cours',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
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
        Text(value, style: GoogleFonts.inter(
          fontSize: 24, fontWeight: FontWeight.w800,
          color: Colors.white, height: 1.0,
        )),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.7),
          height: 1.3,
        )),
      ],
    );
  }

  Widget _buildKpiRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final items = [
          _kpiCard('Patients', _counts['total'] ?? 0, Icons.people_outline, EpidemiologyTheme.indigo),
          _kpiCard('En cours', _counts['enCours'] ?? 0, Icons.pending_outlined, EpidemiologyTheme.warning),
          _kpiCard('Urgents', _counts['urgent'] ?? 0, Icons.warning_amber_outlined, EpidemiologyTheme.danger),
          _kpiCard('Sérologies', _counts['serologieEnAttente'] ?? 0, Icons.biotech_outlined, EpidemiologyTheme.info),
        ];
        if (isWide) {
          return Row(
            children: items.map((w) => Expanded(
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: w),
            )).toList(),
          );
        }
        return Wrap(
          spacing: 8, runSpacing: 8,
          children: items.map((w) => SizedBox(
            width: (constraints.maxWidth - 8) / 2, child: w,
          )).toList(),
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
              Text('$count', style: GoogleFonts.inter(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: EpidemiologyTheme.warm800,
              )),
              Text(label, style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: EpidemiologyTheme.warm400,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final items = [
          _quickAccessTile(
            Icons.person_add_rounded, 'Nouveau patient', 'Enregistrer un cas',
            null,
          ),
          _quickAccessTile(
            Icons.list_alt_rounded, 'Liste des cas', 'Consulter les patients',
            const HepatitisBPatientListScreen(),
          ),
          _quickAccessTile(
            Icons.biotech_rounded, 'Sérologies', 'Résultats de laboratoire',
            null,
          ),
          _quickAccessTile(
            Icons.description_outlined, 'Protocole', 'Conduite à tenir VHB',
            null,
          ),
        ];

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
            Row(children: [
              Expanded(child: items[0]), const SizedBox(width: 10),
              Expanded(child: items[1]),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: items[2]), const SizedBox(width: 10),
              Expanded(child: items[3]),
            ]),
          ],
        );
      },
    );
  }

  Widget _quickAccessTile(IconData icon, String title, String subtitle, Widget? destination) {
    final urgentCount = _counts['urgent'] ?? 0;
    final showAlert = title == 'Liste des cas' && urgentCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: destination != null
            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination))
            : null,
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
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          EpidemiologyTheme.indigo.withValues(alpha: 0.12),
                          EpidemiologyTheme.indigo.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: EpidemiologyTheme.indigo, size: 22),
                  ),
                  if (showAlert)
                    Positioned(
                      top: 4, right: 4,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: EpidemiologyTheme.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: EpidemiologyTheme.white, width: 2),
                        ),
                        child: Center(
                          child: Text('$urgentCount',
                            style: GoogleFonts.inter(
                              fontSize: 8, fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: EpidemiologyTheme.warm800,
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.inter(
                      fontSize: 11, color: EpidemiologyTheme.warm400,
                    )),
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

  Widget _buildProtocolCard() {
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
                  color: EpidemiologyTheme.indigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_services_outlined,
                  size: 18, color: EpidemiologyTheme.indigo),
              ),
              const SizedBox(width: 12),
              Text('Conduite à tenir selon le statut vaccinal',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm800,
                )),
            ],
          ),
          const SizedBox(height: 16),
          _protocolRow('Non vacciné',
            'Vaccination complète + Ig VHB dans les 72h',
            'Vaccination complète + Ig VHB immédiate',
            EpidemiologyTheme.danger),
          _protocolRow('Vacciné (réponse +)',
            'Contrôle sérologique simple',
            'Rappel vaccin + sérologie',
            EpidemiologyTheme.success),
          _protocolRow('Vacciné (réponse ?)',
            'Sérologie anti-HBs + rappel si < 100 UI/L',
            'Ig VHB + rappel vaccin + sérologie',
            EpidemiologyTheme.warning),
          _protocolRow('Statut inconnu',
            'Sérologie urgente (Ag HBs, Ac anti-HBs, Ac anti-HBc)',
            'Ig VHB en attendant les résultats',
            EpidemiologyTheme.warning),
        ],
      ),
    );
  }

  Widget _protocolRow(String status, String standard, String eleve, Color color) {
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
            child: Text(status,
              style: GoogleFonts.inter(
                fontSize: 11, fontWeight: FontWeight.w700, color: color,
              )),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Risque standard : $standard',
                  style: GoogleFonts.inter(
                    fontSize: 11, color: EpidemiologyTheme.warm600, height: 1.4,
                  )),
                Text('Risque élevé : $eleve',
                  style: GoogleFonts.inter(
                    fontSize: 11, color: EpidemiologyTheme.warm600, height: 1.4,
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuiviCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EpidemiologyTheme.indigo.withValues(alpha: 0.04),
            EpidemiologyTheme.indigo.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.indigo.withValues(alpha: 0.08)),
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
                  color: EpidemiologyTheme.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.timeline_rounded,
                  size: 18, color: EpidemiologyTheme.teal),
              ),
              const SizedBox(width: 12),
              Text('Calendrier de suivi sérologique',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm800,
                )),
            ],
          ),
          const SizedBox(height: 16),
          _timelineStep(Icons.biotech, 'J0 — Sérologie initiale',
            'Ag HBs · Ac anti-HBs · Ac anti-HBc', false),
          _timelineStep(Icons.calendar_month, 'M1 — Contrôle à 1 mois',
            'Sérologie VHB de contrôle', false),
          _timelineStep(Icons.calendar_month, 'M3 — Contrôle à 3 mois',
            'Sérologie VHB finale', false),
          _timelineStep(Icons.description, 'Déclaration AES',
            'Déclaration obligatoire en cas d\'accident exposant au sang', true),
        ],
      ),
    );
  }

  Widget _timelineStep(IconData icon, String title, String subtitle, bool isLast) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: EpidemiologyTheme.teal),
              ),
              if (!isLast)
                Container(
                  width: 1, height: 20,
                  color: EpidemiologyTheme.warm200,
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm800,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.inter(
                  fontSize: 11.5, fontWeight: FontWeight.w500,
                  color: EpidemiologyTheme.warm500,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
