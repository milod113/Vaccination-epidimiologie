import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tracabilite/lot_vaccin_model.dart';
import '../../../domain/repositories/stock_repository.dart';
import '../../../../../injection_container.dart' as di;
import '../../widgets/kpi_card.dart';

class StockDashboard extends StatefulWidget {
  const StockDashboard({super.key});

  @override
  State<StockDashboard> createState() => _StockDashboardState();
}

class _StockDashboardState extends State<StockDashboard> {
  List<LotVaccinModel>? _lots;
  StockStats? _stats;
  bool _loading = true;
  String _filter = 'tous';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = di.sl<StockRepository>();
    final lots = await repo.getLots();
    final stats = await repo.getStockStats();
    setState(() {
      _lots = lots;
      _stats = stats;
      _loading = false;
    });
  }

  List<LotVaccinModel> get _filteredLots {
    if (_lots == null) return [];
    switch (_filter) {
      case 'disponible':
        return _lots!.where((l) => l.statut == LotStatut.disponible && !l.estExpire).toList();
      case 'peremptible':
        return _lots!.where((l) => l.statut == LotStatut.disponible && l.estPeremptible).toList();
      case 'expire':
        return _lots!.where((l) => l.statut == LotStatut.expire || l.estExpire).toList();
      default:
        return _lots!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.slate50,
      appBar: AppBar(
        title: Text('Gestion des stocks', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        foregroundColor: EpidemiologyTheme.slate900,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
              children: [
                _buildKpis(),
                const SizedBox(height: EpidemiologyTheme.spaceXxl),
                _buildAlertes(),
                const SizedBox(height: EpidemiologyTheme.spaceXxl),
                _buildFilters(),
                const SizedBox(height: EpidemiologyTheme.spaceMd),
                ..._filteredLots.map((lot) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _LotCard(lot: lot, onTap: () => _openLotDetail(lot)),
                )),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildKpis() {
    final stats = _stats!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(width: isWide ? (constraints.maxWidth - 30) / 4 : constraints.maxWidth,
              child: KpiCard(title: 'Lots disponibles', value: '${stats.lotsDisponibles}', icon: Icons.inventory_2, color: EpidemiologyTheme.teal, subtitle: 'Prêts à l\'usage')),
            SizedBox(width: isWide ? (constraints.maxWidth - 30) / 4 : constraints.maxWidth,
              child: KpiCard(title: 'Doses restantes', value: '${stats.dosesRestantes}', icon: Icons.vaccines, color: EpidemiologyTheme.redMedium, subtitle: 'Stock total')),
            SizedBox(width: isWide ? (constraints.maxWidth - 30) / 4 : constraints.maxWidth,
              child: KpiCard(title: 'Péremption ≤90j', value: '${stats.lotsPeremptibles}', icon: Icons.access_time, color: EpidemiologyTheme.warning, subtitle: 'À surveiller')),
            SizedBox(width: isWide ? (constraints.maxWidth - 30) / 4 : constraints.maxWidth,
              child: KpiCard(title: 'Lots expirés', value: '${stats.lotsExpires}', icon: Icons.cancel, color: EpidemiologyTheme.danger, subtitle: 'Retrait nécessaire')),
          ],
        );
      },
    );
  }

  Widget _buildAlertes() {
    final peremptibles = _lots!.where((l) => l.statut == LotStatut.disponible && l.estPeremptible && !l.estExpire).toList();
    final expires = _lots!.where((l) => l.statut == LotStatut.expire || l.estExpire).toList();
    if (peremptibles.isEmpty && expires.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (peremptibles.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: EpidemiologyTheme.alertGradient,
              borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
              border: Border.all(color: EpidemiologyTheme.warningLight),
            ),
            child: Row(children: [
              Icon(Icons.access_time, color: EpidemiologyTheme.warning, size: 22),
              const SizedBox(width: EpidemiologyTheme.spaceMd),
              Expanded(child: Text(
                '${peremptibles.length} lot(s) arrivent à expiration dans les 90 jours.',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.slate700),
              )),
            ]),
          ),
        if (peremptibles.isNotEmpty && expires.isNotEmpty)
          const SizedBox(height: EpidemiologyTheme.spaceSm),
        if (expires.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.dangerLight,
              borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
              border: Border.all(color: EpidemiologyTheme.dangerLight),
            ),
            child: Row(children: [
              Icon(Icons.cancel, color: EpidemiologyTheme.danger, size: 22),
              const SizedBox(width: EpidemiologyTheme.spaceMd),
              Expanded(child: Text(
                '${expires.length} lot(s) expiré(s) — Retrait nécessaire.',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.danger),
              )),
            ]),
          ),
      ],
    );
  }

  Widget _buildFilters() {
    final filters = ['tous', 'disponible', 'peremptible', 'expire'];
    final labels = ['Tous', 'Disponibles', 'Péremption ≤90j', 'Expirés'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (i) {
          final active = _filter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(labels[i], style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
              selected: active,
              selectedColor: EpidemiologyTheme.redPrimary,
              labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : EpidemiologyTheme.slate500),
              onSelected: (v) => setState(() => _filter = filters[i]),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
            ),
          );
        }),
      ),
    );
  }

  void _openLotDetail(LotVaccinModel lot) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _BatchDetailScreen(lot: lot)));
  }
}

class _LotCard extends StatelessWidget {
  final LotVaccinModel lot;
  final VoidCallback onTap;

  const _LotCard({required this.lot, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (Color statusColor, Color statusBg) = lot.estExpire
        ? (EpidemiologyTheme.danger, EpidemiologyTheme.dangerLight)
        : lot.estPeremptible
            ? (EpidemiologyTheme.warning, EpidemiologyTheme.warningLight)
            : lot.quantiteRestante <= 5
                ? (EpidemiologyTheme.orange, EpidemiologyTheme.orangeLight)
                : (EpidemiologyTheme.success, EpidemiologyTheme.successLight);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg),
            boxShadow: EpidemiologyTheme.shadowMd,
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [statusColor, statusColor.withValues(alpha: 0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                  boxShadow: [BoxShadow(color: statusColor.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Icon(Icons.inventory_2, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lot.numeroLot, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: EpidemiologyTheme.slate900)),
                    const SizedBox(height: 2),
                    Text('${lot.vaccinNom} · ${lot.fabricant}', style: EpidemiologyTheme.bodySm()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _miniChip('${lot.quantiteRestante}/${lot.quantiteInitiale}', EpidemiologyTheme.slate500),
                        const SizedBox(width: EpidemiologyTheme.spaceSm),
                        _miniChip('Exp: ${lot.dateExpiration}', lot.estExpire ? EpidemiologyTheme.danger : EpidemiologyTheme.slate500),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.15), width: 0.5),
                ),
                child: Text(lot.statut.label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color color) {
    return Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: color));
  }
}

class _BatchDetailScreen extends StatelessWidget {
  final LotVaccinModel lot;

  const _BatchDetailScreen({required this.lot});

  @override
  Widget build(BuildContext context) {
    final bool alerte = lot.estExpire || lot.estPeremptible || lot.quantiteRestante <= 5;
    return Scaffold(
      backgroundColor: EpidemiologyTheme.slate50,
      appBar: AppBar(
        title: Text('Lot ${lot.numeroLot}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        foregroundColor: EpidemiologyTheme.slate900,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
        children: [
          if (alerte) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: lot.estExpire ? EpidemiologyTheme.dangerLight : EpidemiologyTheme.warningLight,
                borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                border: Border.all(color: lot.estExpire ? EpidemiologyTheme.dangerLight : EpidemiologyTheme.warningLight),
              ),
              child: Row(children: [
                Icon(lot.estExpire ? Icons.cancel : Icons.warning, color: lot.estExpire ? EpidemiologyTheme.danger : EpidemiologyTheme.warning),
                const SizedBox(width: EpidemiologyTheme.spaceMd),
                Expanded(
                  child: Text(
                    lot.estExpire ? 'Lot expiré depuis ${lot.joursRestants.abs()} jours.' : lot.quantiteRestante <= 5 ? 'Stock quasi épuisé (${lot.quantiteRestante} doses).' : 'Expire dans ${lot.joursRestants} jours.',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: lot.estExpire ? EpidemiologyTheme.danger : EpidemiologyTheme.warning),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: EpidemiologyTheme.spaceLg),
          ],
          _detailCard(context),
        ],
      ),
    );
  }

  Widget _detailCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        boxShadow: EpidemiologyTheme.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _infoRow('Numéro de lot', lot.numeroLot),
          _infoRow('Vaccin', lot.vaccinNom),
          _infoRow('Fabricant', lot.fabricant),
          _infoRow('Date de fabrication', lot.dateFabrication),
          _infoRow("Date d'expiration", '${lot.dateExpiration} (${lot.joursRestants > 0 ? '${lot.joursRestants} jours restants' : 'Expiré depuis ${lot.joursRestants.abs()} jours'})'),
          _infoRow('Doses initiales', '${lot.quantiteInitiale}'),
          _infoRow('Doses restantes', '${lot.quantiteRestante}'),
          _infoRow("Taux d'utilisation", '${lot.tauxUtilisation.toStringAsFixed(1)}%'),
          _infoRow('Statut', lot.statut.label),
          if (lot.notes != null) ...[
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.slate50,
                borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                border: Border.all(color: EpidemiologyTheme.slate100),
              ),
              child: Text(lot.notes!, style: EpidemiologyTheme.bodySm()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: EpidemiologyTheme.label())),
          Expanded(child: Text(value, style: EpidemiologyTheme.label(color: EpidemiologyTheme.slate900))),
        ],
      ),
    );
  }
}
