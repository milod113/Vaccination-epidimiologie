import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/premium_patient_card_antirabique.dart';

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
  List<PatientAntirabiqueModel>? _filteredPatients;
  bool _loading = true;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_filter);
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

  Future<void> _loadPatients() async {
    final repo = di.sl<PatientAntirabiqueRepository>();
    final patients = await repo.getPatients();
    setState(() {
      _patients = patients;
      _filteredPatients = patients;
      _loading = false;
    });
  }

  void _filter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients?.where((p) =>
          p.nomComplet.toLowerCase().contains(query) ||
          p.id.toLowerCase().contains(query) ||
          p.animalSource?.toLowerCase().contains(query) == true
        ).toList();
      }
    });
  }

  int get _totalCount => _patients?.length ?? 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const SizedBox(height: 4),
        _buildSearchBar(),
        const SizedBox(height: 16),
        if (_loading)
          Expanded(child: _buildLoadingState())
        else if (_filteredPatients != null && _filteredPatients!.isEmpty)
          Expanded(child: EpidemiologyTheme.emptyState(
            Icons.search_off,
            'Aucun patient trouvé',
            subtitle: 'Essayez de modifier votre recherche',
          ))
        else
          Expanded(child: _buildPatientList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Row(
        children: [
          Text('Patients', style: EpidemiologyTheme.h2()),
          const SizedBox(width: 8),
          if (!_loading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$_totalCount', style: EpidemiologyTheme.label(color: EpidemiologyTheme.warm600)),
            ),
          const Spacer(),
          if (widget.onCreatePatient != null) ...[
            FilledButton.icon(
              onPressed: widget.onCreatePatient,
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: const Text('Nouveau'),
              style: FilledButton.styleFrom(
                backgroundColor: EpidemiologyTheme.redPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () { _searchController.clear(); _focusNode.unfocus(); },
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Rechercher un patient ou un animal…',
            prefixIcon: Icon(Icons.search, color: EpidemiologyTheme.warm400, size: 22),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: EpidemiologyTheme.warm400, size: 18),
                    onPressed: () { _searchController.clear(); _focusNode.unfocus(); },
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 6,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 118,
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: EpidemiologyTheme.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warm100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22), bottomLeft: Radius.circular(22),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          EpidemiologyTheme.shimmerBox(width: 44, height: 44, radius: 14),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                EpidemiologyTheme.shimmerBox(width: 140, height: 16),
                                const SizedBox(height: 6),
                                EpidemiologyTheme.shimmerBox(width: 100, height: 12),
                              ],
                            ),
                          ),
                          EpidemiologyTheme.shimmerBox(width: 80, height: 24, radius: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, thickness: 1, color: EpidemiologyTheme.warm100),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          EpidemiologyTheme.shimmerBox(width: 60, height: 20, radius: 8),
                          const SizedBox(width: 8),
                          EpidemiologyTheme.shimmerBox(width: 80, height: 20, radius: 8),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredPatients!.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PremiumPatientCardAntirabique(
            patient: patient,
            onTap: () => widget.onPatientSelected?.call(patient.id),
          ),
        );
      },
    );
  }
}
