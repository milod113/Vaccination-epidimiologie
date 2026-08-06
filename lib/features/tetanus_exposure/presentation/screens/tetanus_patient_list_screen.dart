import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../../data/models/tetanus_models.dart';
import '../widgets/tetanus_patient_card.dart';
import 'tetanus_patient_detail_screen.dart';
import 'tetanus_checklist_screen.dart';

class TetanusPatientListScreen extends StatefulWidget {
  const TetanusPatientListScreen({super.key});

  @override
  State<TetanusPatientListScreen> createState() =>
      _TetanusPatientListScreenState();
}

class _TetanusPatientListScreenState extends State<TetanusPatientListScreen> {
  final _repo = GetIt.instance<TetanusRepository>();
  late List<TetanusPatientModel> _patients;
  List<TetanusPatientModel> _filtered = [];
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _filterStatut = 'Tous';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _patients = _repo.getPatients();
    _filtered = List.from(_patients);
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _patients.where((p) {
        final matchesSearch = q.isEmpty ||
            p.nomComplet.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q);
        final matchesStatut = _filterStatut == 'Tous' ||
            p.statutDossier.label == _filterStatut;
        return matchesSearch && matchesStatut;
      }).toList();
    });
  }

  int get _urgentCount =>
      _patients.where((p) => p.estUrgent).length;
  int get _enCoursCount => _patients
      .where((p) => p.statutDossier == TetanusDossierStatut.enCours)
      .length;
  int get _closCount => _patients
      .where((p) => p.statutDossier == TetanusDossierStatut.suiviClos)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: EpidemiologyTheme.warm700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Liste des cas',
              style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm800),
            ),
            Text(
              '${_filtered.length} patient${_filtered.length > 1 ? 's' : ''}',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: EpidemiologyTheme.warm400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close_rounded : Icons.search_rounded,
              color: _showSearch
                  ? EpidemiologyTheme.amber
                  : EpidemiologyTheme.warm500,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchFocus.unfocus();
                } else {
                  _searchFocus.requestFocus();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.person_add_rounded,
                color: EpidemiologyTheme.amber),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TetanusChecklistScreen()),
            ),
          ),
        ],
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
            bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1)),
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          if (_showSearch) _buildSearchBar(),
          _buildFilterRow(),
          if (!_showSearch && _searchController.text.isEmpty)
            _buildResultBar(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptyState()
                : _buildAnimatedList(),
          ),
        ],
      ),
    );
  }

  // ── Stats Bar ──

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: EpidemiologyTheme.white,
      child: Row(
        children: [
          _statPill(
              '${_patients.length}', 'Total', EpidemiologyTheme.info),
          const SizedBox(width: 8),
          _statPill('$_urgentCount', 'Urgent', EpidemiologyTheme.danger),
          const SizedBox(width: 8),
          _statPill(
              '$_enCoursCount', 'En cours', EpidemiologyTheme.warning),
          const SizedBox(width: 8),
          _statPill('$_closCount', 'Clos', EpidemiologyTheme.success),
        ],
      ),
    );
  }

  Widget _statPill(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: color.withValues(alpha: 0.12), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ──

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: EpidemiologyTheme.white,
      child: Material(
        elevation: 0,
        shadowColor: EpidemiologyTheme.warm200,
        borderRadius: BorderRadius.circular(18),
        child: Focus(
          child: Builder(builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasFocus
                      ? EpidemiologyTheme.amber.withValues(alpha: 0.5)
                      : EpidemiologyTheme.warm100,
                  width: hasFocus ? 1.5 : 1,
                ),
                boxShadow: hasFocus
                    ? [
                        BoxShadow(
                          color:
                              EpidemiologyTheme.amber.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: 'Rechercher un patient (nom, ID)…',
                  hintStyle: TextStyle(
                      color: EpidemiologyTheme.warm400,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(13),
                    child: Icon(Icons.search_rounded,
                        color: hasFocus
                            ? EpidemiologyTheme.amber
                            : EpidemiologyTheme.warm400,
                        size: 22),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 20,
                              color: EpidemiologyTheme.warm400),
                          onPressed: () {
                            _searchController.clear();
                            _searchFocus.unfocus();
                          })
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15),
                ),
                style: TextStyle(
                    fontSize: 14,
                    color: EpidemiologyTheme.warm800,
                    fontWeight: FontWeight.w500),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Result Bar ──

  Widget _buildResultBar() {
    if (_filterStatut == 'Tous' && _searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
      color: EpidemiologyTheme.white,
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded,
              size: 14, color: EpidemiologyTheme.warm400),
          const SizedBox(width: 6),
          Text(
            '${_filtered.length} résultat${_filtered.length > 1 ? 's' : ''}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.warm400,
            ),
          ),
          const Spacer(),
          if (_filterStatut != 'Tous')
            GestureDetector(
              onTap: () {
                setState(() => _filterStatut = 'Tous');
                _filter();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warm100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close_rounded,
                        size: 12, color: EpidemiologyTheme.warm500),
                    const SizedBox(width: 3),
                    Text(
                      'Effacer filtre',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: EpidemiologyTheme.warm500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Filter Row ──

  Widget _buildFilterRow() {
    final statuts = [
      _FilterOption('Tous', null),
      _FilterOption('En cours', TetanusDossierStatut.enCours),
      _FilterOption('Acte effectué', TetanusDossierStatut.acteEffectue),
      _FilterOption('Suivi clos', TetanusDossierStatut.suiviClos),
      _FilterOption('Perdu de vue', TetanusDossierStatut.perduDeVue),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: EpidemiologyTheme.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuts.map((opt) {
            final active = _filterStatut == opt.label;
            final count = opt.statut != null
                ? _patients
                    .where((p) => p.statutDossier == opt.statut)
                    .length
                : _patients.length;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _filterStatut = opt.label);
                  _filter();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: active
                        ? LinearGradient(
                            colors: [
                              EpidemiologyTheme.amber,
                              EpidemiologyTheme.amber.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: active
                        ? null
                        : EpidemiologyTheme.warm50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: active
                          ? Colors.transparent
                          : EpidemiologyTheme.warm100,
                      width: 1,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: EpidemiologyTheme.amber
                                  .withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opt.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? Colors.white
                              : EpidemiologyTheme.warm500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withValues(alpha: 0.25)
                              : EpidemiologyTheme.warm100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? Colors.white
                                : EpidemiologyTheme.warm400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Animated List ──

  Widget _buildAnimatedList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => _AnimatedListItem(
        index: i,
        child: TetanusPatientCard(
          patient: _filtered[i],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TetanusPatientDetailScreen(
                    patientId: _filtered[i].id),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Empty State ──

  Widget _buildEmptyState() {
    final hasSearch =
        _searchController.text.isNotEmpty || _filterStatut != 'Tous';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    EpidemiologyTheme.warm100.withValues(alpha: 0.6),
                    EpidemiologyTheme.warm50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: EpidemiologyTheme.warm100,
                  width: 1,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.warm200.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    hasSearch
                        ? Icons.search_off_rounded
                        : Icons.inbox_rounded,
                    size: 40,
                    color: EpidemiologyTheme.warm300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasSearch ? 'Aucun résultat' : 'Aucun patient',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.warm600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'Essayez un autre terme de recherche\nou modifiez le filtre appliqué'
                  : 'Les patients pris en charge pour une\nprophylaxie antitétanique apparaîtront ici',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: EpidemiologyTheme.warm400,
                height: 1.6,
              ),
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const TetanusChecklistScreen()),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text(
                  'Nouveau patient',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: EpidemiologyTheme.amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Filter Option Helper ──

class _FilterOption {
  final String label;
  final TetanusDossierStatut? statut;
  const _FilterOption(this.label, this.statut);
}

// ── Animated List Item ──

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}
