import 'package:flutter/material.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../widgets/dossier_list/dossier_empty_state.dart';
import '../widgets/dossier_list/dossier_filter_bar.dart';
import '../widgets/dossier_list/dossier_list_card.dart';
import '../widgets/dossier_list/dossier_list_hero_header.dart';
import '../widgets/dossier_list/dossier_list_kpis.dart';
import '../widgets/dossier_list/dossier_list_models.dart';
import '../widgets/dossier_list/dossier_list_skeleton.dart';
import '../widgets/dossier_list/dossier_list_table.dart';
import '../widgets/dossier_list/dossier_priority_banner.dart';
import '../widgets/dossier_list/dossier_search_bar.dart';

/// Écran liste des dossiers antirabiques — page de pilotage clinique.
///
/// Structure : hero header premium (titre, total, CTA), barre de recherche,
/// filtres cliniques + tri (statut, catégorie, protocole, retards, commune),
/// bannière « suivi requis aujourd'hui », KPI de synthèse puis liste
/// responsive (tableau desktop, cartes tablette/mobile) avec états
/// skeleton / vide.
class RabiesDossierListScreen extends StatefulWidget {
  final void Function(String dossierId)? onDossierSelected;

  /// Action « Nouveau dossier ».
  final VoidCallback? onCreateDossier;

  const RabiesDossierListScreen({
    super.key,
    this.onDossierSelected,
    this.onCreateDossier,
  });

  @override
  State<RabiesDossierListScreen> createState() =>
      _RabiesDossierListScreenState();
}

class _RabiesDossierListScreenState extends State<RabiesDossierListScreen> {
  List<RabiesCaseRecord>? _dossiers;
  List<RabiesCaseRecord>? _filtered;
  bool _loading = true;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  DossierStatusFilter _status = DossierStatusFilter.all;
  DossierQuickFilter? _quick;
  DossierSortOption _sort = DossierSortOption.urgence;
  String? _commune;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  int get _total => _dossiers?.length ?? 0;

  List<String> get _communes {
    final set = <String>{};
    for (final d in _dossiers ?? const []) {
      final c = d.identity.residence.commune;
      if (c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return list;
  }

  bool get _hasActiveFilters =>
      _status != DossierStatusFilter.all ||
      _quick != null ||
      _commune != null ||
      _searchController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = di.sl<RabiesDossierRepository>();
    final list = await repo.getDossiers();
    setState(() {
      _dossiers = list;
      _loading = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final source = _dossiers;
    if (source == null) {
      if (_filtered != null) setState(() => _filtered = null);
      return;
    }
    final today = _today;
    final q = _searchController.text.trim().toLowerCase();

    final matches = source.where((d) {
      if (q.isNotEmpty) {
        final hit =
            d.patientNomComplet.toLowerCase().contains(q) ||
            d.numeroDossier.toLowerCase().contains(q) ||
            d.categorie.label.toLowerCase().contains(q);
        if (!hit) return false;
      }
      if (!_status.matches(d, today)) return false;
      if (_quick != null && !_quick!.matches(d, today)) return false;
      if (_commune != null) {
        final c = d.identity.residence.commune;
        if (c != _commune) return false;
      }
      return true;
    }).toList();

    final sorted = _sort.sort(matches, today);
    setState(() => _filtered = sorted);
  }

  void _setStatus(DossierStatusFilter f) {
    _status = f;
    _applyFilters();
  }

  void _setQuick(DossierQuickFilter? f) {
    _quick = f;
    _applyFilters();
  }

  void _setSort(DossierSortOption o) {
    _sort = o;
    _applyFilters();
  }

  void _setCommune(String? c) {
    _commune = c;
    _applyFilters();
  }

  void _reset() {
    _searchController.clear();
    _status = DossierStatusFilter.all;
    _quick = null;
    _commune = null;
    _focusNode.unfocus();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: DossierListHeroHeader(
            totalCount: _total,
            onCreateDossier: widget.onCreateDossier,
          ),
        ),
        SliverToBoxAdapter(
          child: DossierSearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            hasQuery: _searchController.text.isNotEmpty,
            onChanged: (_) => _applyFilters(),
          ),
        ),
        SliverToBoxAdapter(
          child: DossierFilterBar(
            status: _status,
            quick: _quick,
            sort: _sort,
            communes: _communes,
            selectedCommune: _commune,
            resultCount: _filtered?.length ?? 0,
            onStatusChanged: _setStatus,
            onQuickChanged: _setQuick,
            onSortChanged: _setSort,
            onCommuneChanged: _setCommune,
            onReset: _hasActiveFilters ? _reset : () {},
          ),
        ),
        SliverToBoxAdapter(
          child: DossierListKpis(dossiers: _dossiers ?? const []),
        ),
        if (!_loading)
          SliverToBoxAdapter(
            child: DossierPriorityBanner(
              dossiers: _dossiers ?? const [],
              onOpenDossier: (id) => widget.onDossierSelected?.call(id),
            ),
          ),
        _loading
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: DossierListSkeleton(),
                ),
              )
            : _listSliver(),
      ],
    );
  }

  Widget _listSliver() {
    final list = _filtered;
    if (_dossiers != null && (list == null || list.isEmpty)) {
      return SliverToBoxAdapter(
        child: DossierListEmptyState(
          hasActiveFilters: _hasActiveFilters,
          onReset: _hasActiveFilters ? _reset : null,
          onCreate: _hasActiveFilters ? null : widget.onCreateDossier,
        ),
      );
    }
    if (list == null || list.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1100;
            if (wide) {
              return DossierListTable(
                dossiers: list,
                onOpenDossier: (id) => widget.onDossierSelected?.call(id),
              );
            }

            final cols = constraints.maxWidth >= 620 ? 2 : 1;
            final gap = 14.0;
            final cardWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final d in list)
                  SizedBox(
                    width: cardWidth,
                    child: DossierListCard(
                      dossier: d,
                      onTap: () => widget.onDossierSelected?.call(d.id),
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
