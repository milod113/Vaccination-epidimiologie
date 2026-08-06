import 'package:flutter/material.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/patient_list/patient_filter_bar.dart';
import '../widgets/patient_list/patient_list_empty_state.dart';
import '../widgets/patient_list/patient_list_hero_header.dart';
import '../widgets/patient_list/patient_list_models.dart';
import '../widgets/patient_list/patient_list_skeleton.dart';
import '../widgets/patient_list/patient_overview_kpis.dart';
import '../widgets/patient_list/patient_search_bar.dart';
import '../widgets/patient_list/premium_rabies_patient_card.dart';

/// Écran liste des patients antirabiques — page de pilotage clinique.
///
/// Structure : hero header premium (titre, contexte, total, CTA admission),
/// barre de recherche, filtres cliniques + tri, KPI de synthèse, puis grille
/// responsive de cartes patient premium (avec états skeleton / vide).
class PatientListAntirabique extends StatefulWidget {
  final void Function(String patientId)? onPatientSelected;

  /// Action « Admettre un nouveau patient ».
  final VoidCallback? onCreatePatient;

  /// Incrémenté pour forcer un rechargement de la liste (après création).
  final int reloadToken;

  const PatientListAntirabique({
    super.key,
    this.onPatientSelected,
    this.onCreatePatient,
    this.reloadToken = 0,
  });

  @override
  State<PatientListAntirabique> createState() => _PatientListAntirabiqueState();
}

class _PatientListAntirabiqueState extends State<PatientListAntirabique> {
  List<PatientAntirabiqueModel>? _patients;
  List<PatientAntirabiqueModel>? _filtered;
  bool _loading = true;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  PatientStatusFilter _status = PatientStatusFilter.all;
  PatientQuickFilter? _quick;
  PatientSortOption _sort = PatientSortOption.urgent;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_applyFilters);
  }

  @override
  void didUpdateWidget(covariant PatientListAntirabique oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadToken != oldWidget.reloadToken) {
      _loadPatients();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int get _totalPatients => _patients?.length ?? 0;

  bool get _hasActiveFilters =>
      _status != PatientStatusFilter.all ||
      _quick != null ||
      _searchController.text.trim().isNotEmpty;

  Future<void> _loadPatients() async {
    setState(() => _loading = true);
    final repo = di.sl<PatientAntirabiqueRepository>();
    final patients = await repo.getPatients();
    setState(() {
      _patients = patients;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final source = _patients;
    if (source == null) {
      if (_filtered != null) setState(() => _filtered = null);
      return;
    }
    final today = _today;
    final q = _searchController.text.trim().toLowerCase();

    final matches = source.where((p) {
      if (q.isNotEmpty) {
        final hit =
            p.nomComplet.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q) ||
            (p.animalSource?.toLowerCase().contains(q) ?? false) ||
            (p.protocole?.label.toLowerCase().contains(q) ?? false);
        if (!hit) return false;
      }
      if (!_status.matches(p, today)) return false;
      if (_quick != null && !_quick!.matches(p, today)) return false;
      return true;
    }).toList();

    final sorted = _sort.sort(matches, today);
    setState(() => _filtered = sorted);
  }

  void _setStatus(PatientStatusFilter f) {
    _status = f;
    _applyFilters();
  }

  void _setQuick(PatientQuickFilter? f) {
    _quick = f;
    _applyFilters();
  }

  void _setSort(PatientSortOption o) {
    _sort = o;
    _applyFilters();
  }

  void _reset() {
    _searchController.clear();
    _status = PatientStatusFilter.all;
    _quick = null;
    _focusNode.unfocus();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: PatientListHeroHeader(
            totalCount: _totalPatients,
            onCreatePatient: widget.onCreatePatient,
          ),
        ),
        SliverToBoxAdapter(
          child: PatientSearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            hasQuery: _searchController.text.isNotEmpty,
            onChanged: (_) => _applyFilters(),
          ),
        ),
        SliverToBoxAdapter(
          child: PatientFilterBar(
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
          child: PatientOverviewKpis(patients: _patients ?? const []),
        ),
        _loading
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: PatientListSkeleton(),
                ),
              )
            : _listSliver(),
      ],
    );
  }

  Widget _listSliver() {
    final list = _filtered;
    if (list == null || list.isEmpty) {
      return SliverToBoxAdapter(
        child: PatientListEmptyState(
          hasActiveFilters: _hasActiveFilters,
          onReset: _hasActiveFilters ? _reset : null,
          onCreate: _hasActiveFilters ? null : widget.onCreatePatient,
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
            final cardWidth =
                (constraints.maxWidth - gap * (cols - 1)) / cols;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final patient in list)
                  SizedBox(
                    width: cardWidth,
                    child: PremiumRabiesPatientCard(
                      patient: patient,
                      onTap: () => widget.onPatientSelected?.call(patient.id),
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