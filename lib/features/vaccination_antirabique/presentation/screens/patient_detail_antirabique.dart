import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/evaluation_initiale_model.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../domain/repositories/evaluation_initiale_repository.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../../../../injection_container.dart' as di;
import 'evaluation_initiale_screen.dart';
import 'rabies_vaccination_book_screen.dart';
import 'tabs/protocole_vaccinal_tab.dart';
import 'tabs/suivi_clinique_tab.dart';

class PatientDetailAntirabique extends StatefulWidget {
  final String patientId;
  final VoidCallback? onBack;

  const PatientDetailAntirabique({
    super.key,
    required this.patientId,
    this.onBack,
  });

  @override
  State<PatientDetailAntirabique> createState() => _PatientDetailAntirabiqueState();
}

class _PatientDetailAntirabiqueState extends State<PatientDetailAntirabique>
    with SingleTickerProviderStateMixin {
  PatientAntirabiqueModel? _patient;
  InitialRabiesAssessment? _evaluation;
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatient();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    final patientRepo = di.sl<PatientAntirabiqueRepository>();
    final evalRepo = di.sl<EvaluationInitialeRepository>();
    final results = await Future.wait([
      patientRepo.getPatientById(widget.patientId),
      evalRepo.getEvaluation(widget.patientId),
    ]);
    setState(() {
      _patient = results[0] as PatientAntirabiqueModel?;
      _evaluation = results[1] as InitialRabiesAssessment?;
      _loading = false;
    });
  }

  Future<void> _openEvaluationInitiale() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EvaluationInitialeScreen(patientId: widget.patientId),
      ),
    );
    if (result == true) {
      final evalRepo = di.sl<EvaluationInitialeRepository>();
      final eval = await evalRepo.getEvaluation(widget.patientId);
      setState(() => _evaluation = eval);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_patient == null) {
      return Center(child: Text('Patient introuvable'));
    }
    return _buildContent();
  }

  Widget _buildContent() {
    final patient = _patient!;
    final isUrgent = patient.categorieExposition == CategorieExposition.categorieIII;

    return Column(
      children: [
        _buildHeader(patient, isUrgent),
        _buildEvaluationCard(),
        Container(
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            boxShadow: [BoxShadow(color: EpidemiologyTheme.blackWith(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: EpidemiologyTheme.redPrimary,
            unselectedLabelColor: EpidemiologyTheme.warm400,
            indicatorColor: EpidemiologyTheme.redPrimary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Protocole vaccinal'),
              Tab(text: 'Suivi clinique'),
              Tab(text: 'Carnet'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ProtocoleVaccinalTab(patientId: patient.id),
              SuiviCliniqueTab(patientId: patient.id),
              RabiesVaccinationBookView(patientId: patient.id),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationCard() {
    final exists = _evaluation != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: exists
              ? [EpidemiologyTheme.successLight, EpidemiologyTheme.successLight.withValues(alpha: 0.3)]
              : [EpidemiologyTheme.warningLight, EpidemiologyTheme.amberLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(bottom: BorderSide(color: EpidemiologyTheme.warm100)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: exists ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              exists ? Icons.checklist : Icons.checklist_rtl,
              size: 18, color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Évaluation initiale J0',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800),
                ),
                Text(
                  exists
                      ? 'Réalisée le ${_evaluation!.dateEvaluation} · ${_evaluation!.synthese.label}'
                      : 'Non réalisée — À compléter avant démarrage',
                  style: GoogleFonts.inter(fontSize: 12, color: exists ? EpidemiologyTheme.success : EpidemiologyTheme.warning),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: FilledButton(
              onPressed: _openEvaluationInitiale,
              style: FilledButton.styleFrom(
                backgroundColor: exists ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: Text(exists ? 'Réviser' : 'Réaliser'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PatientAntirabiqueModel patient, bool isUrgent) {
    return Container(
      padding: EdgeInsets.only(
        left: EpidemiologyTheme.spaceXl,
        right: EpidemiologyTheme.spaceXl,
        top: MediaQuery.of(context).padding.top + 12,
        bottom: EpidemiologyTheme.spaceLg,
      ),
      decoration: BoxDecoration(
        gradient: isUrgent
            ? EpidemiologyTheme.heroGradient
            : LinearGradient(
                colors: [EpidemiologyTheme.warm700, EpidemiologyTheme.warm500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: isUrgent ? EpidemiologyTheme.shadowHero : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack ?? () => Navigator.maybePop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusSm),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: EpidemiologyTheme.spaceMd),
              Expanded(
                child: Text(
                  'Fiche patient',
                  style: EpidemiologyTheme.subtitle(color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusSm),
                ),
                child: Text(
                  patient.id,
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EpidemiologyTheme.spaceLg),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                ),
                child: Icon(
                  patient.sexe == 'Masculin' ? Icons.person : Icons.person_2,
                  color: Colors.white, size: 28,
                ),
              ),
              const SizedBox(width: EpidemiologyTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      patient.nomComplet,
                      style: EpidemiologyTheme.h2(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${patient.age} ans · ${patient.sexe}${patient.telephone != null ? ' · ${patient.telephone}' : ''}',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: EpidemiologyTheme.spaceLg),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (patient.protocole != null)
                _headerChip(Icons.medical_services, patient.protocole!.label),
              _headerChip(Icons.category, patient.categorieExposition?.label ?? 'À évaluer'),
              if (patient.siteMorsure != null)
                _headerChip(Icons.healing, patient.siteMorsure!.split(' - ').first),
              _headerChip(Icons.pets, patient.animalSource ?? 'N/R'),
              _headerChip(Icons.biotech, patient.animalStatut.label),
              if (patient.rigAdministree)
                _headerChip(Icons.science, 'RIG+', color: EpidemiologyTheme.teal),
              if (patient.immunocompromis)
                _headerChip(Icons.warning, 'Immunodéprimé', color: EpidemiologyTheme.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label, {Color? color}) {
    final chipColor = color ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor.withValues(alpha: 0.9)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: chipColor.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
