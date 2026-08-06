import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../../data/models/tetanus_models.dart';
import '../widgets/case_list/tetanus_cases_hero_header.dart';
import '../widgets/case_list/tetanus_cases_kpis.dart';
import '../widgets/case_list/tetanus_case_search_bar.dart';
import '../widgets/case_list/tetanus_case_filter_bar.dart';
import '../widgets/case_list/tetanus_case_list_models.dart';
import '../widgets/case_list/tetanus_case_card.dart';
import '../widgets/case_list/tetanus_case_skeleton.dart';
import '../widgets/case_list/tetanus_case_empty_state.dart';
import 'tetanus_patient_detail_screen.dart';
import 'tetanus_evaluation_screen.dart';

/// Écran liste des cas tétaniques — page de pilotage clinique.
///
/// Structure : hero header premium (titre, contexte, total, CTA évaluation),
/// barre de recherche, filtres cliniques + tri, KPI de synthèse, puis grille
/// responsive de cartes cas premium (avec états skeleton / vide).
class TetanusPatientListScreen extends StatefulWidget {
  const TetanusPatientListScreen({super.key});

  @override
  State<TetanusPatientListScreen> createState() =>
      _TetanusPatientListScreenState();
}

class _TetanusPatientListScreenState extends State<TetanusPatientListScreen> {
  final _repo = GetIt.instance<TetanusRepository>();
  List<TetanusPatientModel>? _patients;
  List<TetanusPatientModel>? _filtered;
  bool _loading = true;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  TetanusCaseStatusFilter _status = TetanusCaseStatusFilter.tout;
  TetanusCaseQuickFilter? _quick;
  TetanusCaseSortOption _sort = TetanusCaseSortOption.urgent;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalPatients => _patients?.length ?? 0;
  int get _urgentCount =>
      _patients?.where((p) => p.estUrgent).length ?? 0;

  bool get _hasActiveFilters =>
      _status != TetanusCaseStatusFilter.tout ||
      _quick != null ||
      _searchController.text.trim().isNotEmpty;

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    final patients = _repo.getPatients();
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _patients = patients;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final source = _patients;
    if (source == null) return;
    final q = _searchController.text.trim().toLowerCase();

    final matches = source.where((p) {
      if (q.isNotEmpty) {
        final hit = p.nomComplet.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q) ||
            p.localisation.toLowerCase().contains(q) ||
            p.decision.label.toLowerCase().contains(q) ||
            p.typePlaie.label.toLowerCase().contains(q);
        if (!hit) return false;
      }
      if (!_status.matches(p)) return false;
      if (_quick != null && !_quick!.matches(p)) return false;
      return true;
    }).toList();

    final sorted = _sort.sort(matches);
    setState(() => _filtered = sorted);
  }

  void _setStatus(TetanusCaseStatusFilter f) {
    _status = f;
    _applyFilters();
  }

  void _setQuick(TetanusCaseQuickFilter? f) {
    _quick = f;
    _applyFilters();
  }

  void _setSort(TetanusCaseSortOption o) {
    _sort = o;
    _applyFilters();
  }

  void _reset() {
    _searchController.clear();
    _status = TetanusCaseStatusFilter.tout;
    _quick = null;
    _focusNode.unfocus();
    _applyFilters();
  }

  void _openEvaluation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TetanusEvaluationScreen()),
    );
  }

  void _openDetail(TetanusPatientModel patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TetanusPatientDetailScreen(patientId: patient.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: TetanusCasesHeroHeader(
                totalCount: _totalPatients,
                urgentCount: _urgentCount,
                onBack: () => Navigator.of(context).pop(),
                onCreateEvaluation: _openEvaluation,
              ),
            ),
            SliverToBoxAdapter(
              child: TetanusCaseSearchBar(
                controller: _searchController,
                focusNode: _focusNode,
                hasQuery: _searchController.text.isNotEmpty,
                onChanged: (_) => _applyFilters(),
              ),
            ),
            SliverToBoxAdapter(
              child: TetanusCaseFilterBar(
                status: _status,
                quick: _quick,
                sort: _sort,
                resultCount: _filtered?.length ?? 0,
                onStatusChanged: _setStatus,
                onQuickChanged: _setQuick,
                onSortChanged: _setSort,
                onReset: _hasActiveFilters ? _reset : () {},
              ),
            ),
            SliverToBoxAdapter(
              child: TetanusCasesKpis(patients: _patients ?? const []),
            ),
            _loading
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: const TetanusCaseSkeleton(),
                    ),
                  )
                : _listSliver(),
          ],
        ),
      ),
    );
  }

  Widget _listSliver() {
    final list = _filtered;
    if (list == null || list.isEmpty) {
      return SliverToBoxAdapter(
        child: TetanusCaseEmptyState(
          hasActiveFilters: _hasActiveFilters,
          onReset: _hasActiveFilters ? _reset : null,
          onCreate: _hasActiveFilters ? null : _openEvaluation,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 1100
                ? 3
                : constraints.maxWidth >= 620
                    ? 2
                    : 1;
            final gap = 14.0;
            final cardWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final patient in list)
                  SizedBox(
                    width: cardWidth,
                    child: _AnimatedCaseItem(
                      index: list.indexOf(patient),
                      child: TetanusCaseCard(
                        patient: patient,
                        onTap: () => _openDetail(patient),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedCaseItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCaseItem({required this.index, required this.child});

  @override
  State<_AnimatedCaseItem> createState() => _AnimatedCaseItemState();
}

class _AnimatedCaseItemState extends State<_AnimatedCaseItem>
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
    Future.delayed(Duration(milliseconds: widget.index * 50), () {
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