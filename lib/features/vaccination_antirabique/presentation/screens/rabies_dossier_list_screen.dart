import 'package:flutter/material.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../widgets/rabies_dossier_card.dart';

class RabiesDossierListScreen extends StatefulWidget {
  final void Function(String dossierId)? onDossierSelected;

  const RabiesDossierListScreen({super.key, this.onDossierSelected});

  @override
  State<RabiesDossierListScreen> createState() => _RabiesDossierListScreenState();
}

class _RabiesDossierListScreenState extends State<RabiesDossierListScreen> {
  List<RabiesCaseRecord>? _dossiers;
  List<RabiesCaseRecord>? _filtered;
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = di.sl<RabiesDossierRepository>();
    final list = await repo.getDossiers();
    setState(() {
      _dossiers = list;
      _filtered = list;
      _loading = false;
    });
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = _dossiers;
        return;
      }
      _filtered = _dossiers?.where((d) =>
        d.patientNomComplet.toLowerCase().contains(q) ||
        d.numeroDossier.toLowerCase().contains(q) ||
        d.categorie.label.toLowerCase().contains(q)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 4),
        _buildSearch(),
        const SizedBox(height: 16),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_filtered != null && _filtered!.isEmpty)
          Expanded(child: EpidemiologyTheme.emptyState(
            Icons.folder_off,
            'Aucun dossier trouvé',
            subtitle: 'Essayez de modifier votre recherche',
          ))
        else
          Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Text('Dossiers antirabiques', style: EpidemiologyTheme.h2()),
          const SizedBox(width: 8),
          if (!_loading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_dossiers?.length ?? 0}',
                style: EpidemiologyTheme.label(color: EpidemiologyTheme.warm600),
              ),
            ),
          const Spacer(),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () => _searchController.clear(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warm100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Effacer', style: EpidemiologyTheme.caption(color: EpidemiologyTheme.warm500)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un dossier, patient ou catégorie…',
          prefixIcon: Icon(Icons.search, color: EpidemiologyTheme.warm400, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: EpidemiologyTheme.warm400, size: 18),
                  onPressed: () => _searchController.clear(),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildList() {
    final list = _filtered!;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final dossier = list[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RabiesDossierCard(
            dossier: dossier,
            onTap: () => widget.onDossierSelected?.call(dossier.id),
          ),
        );
      },
    );
  }
}