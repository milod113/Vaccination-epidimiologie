import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/evaluation_initiale_model.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../domain/repositories/evaluation_initiale_repository.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../widgets/j0_creation/j0_creation_fields.dart';
import '../widgets/j0_creation/j0_creation_steps.dart';
import '../widgets/j0_creation/j0_creation_summary_panel.dart';
import '../widgets/j0_wizard/j0_step_card.dart';
import '../widgets/j0_wizard/j0_step_model.dart';
import '../widgets/j0_wizard/j0_step_navigation_bar.dart';
import '../widgets/j0_wizard/j0_stepper_header.dart';
import '../widgets/j0_wizard/j0_section_title.dart';
import '../widgets/j0_wizard/j0_ui.dart';

/// Fiche de création / réalisation de l'évaluation initiale J0.
///
/// Refondue en wizard médical premium en 8 étapes, fidèle au formulaire
/// algérien du patient exposé au risque rabique et cohérente avec la fiche
/// de modification J0 : stepper, cartes d'étape, navigation brouillon/valider
/// et résumé clinique temps réel.
class EvaluationInitialeScreen extends StatefulWidget {
  final String patientId;

  const EvaluationInitialeScreen({super.key, required this.patientId});

  @override
  State<EvaluationInitialeScreen> createState() =>
      _EvaluationInitialeScreenState();
}

class _EvaluationInitialeScreenState extends State<EvaluationInitialeScreen> {
  PatientAntirabiqueModel? _patient;
  InitialRabiesAssessment? _existing;
  bool _loading = true;
  bool _saving = false;
  int _currentStep = 0;

  ExpositionInfo _exposition = const ExpositionInfo();
  PlaieInfo _plaie = const PlaieInfo();
  EtatClinique _etatClinique = const EtatClinique();
  AntecedentsAntirabiques _antecedents = const AntecedentsAntirabiques();
  ConduiteInitiale _conduite = const ConduiteInitiale();
  DecisionMedicale _decision = const DecisionMedicale();
  NiveauPriorite _priorite = NiveauPriorite.nonDeterminee;

  final _observationsController = TextEditingController();
  final _conclusionController = TextEditingController();
  final _medecinController = TextEditingController();
  final _centreController = TextEditingController();

  // ── Admission ────────────────────────────────────────────────────
  final _heureArrivee = TextEditingController();
  final _modeArrivee = TextEditingController();
  final _structureOrientation = TextEditingController();

  // ── Adresse de résidence ─────────────────────────────────────────
  final _adresseResidence = TextEditingController();
  final _commune = TextEditingController();
  final _daira = TextEditingController();
  final _wilaya = TextEditingController();

  // ── Animal ───────────────────────────────────────────────────────
  final _animalEspece = TextEditingController();
  final _animalStatut = TextEditingController();
  final _animalComportement = TextEditingController();
  final _animalProprietaire = TextEditingController();
  final _animalObservationVet = TextEditingController();
  final _animalSort = TextEditingController();
  final _animalResultat = TextEditingController();

  // ── Soins / ERIG ─────────────────────────────────────────────────
  bool _lavageEau = false;
  bool _lavageEauSavon = false;
  final _produitsAppliques = TextEditingController();
  bool _erigIndiquee = false;
  bool _erigAdministree = false;
  final _erigLot = TextEditingController();
  final _erigDoseTheorique = TextEditingController();
  final _erigDilution = TextEditingController();
  final _erigVoies = TextEditingController();
  final _erigReaction = TextEditingController();

  // ── Vaccination ──────────────────────────────────────────────────
  final _vaccinType = TextEditingController();
  final _vaccinVoie = TextEditingController();
  final _vaccinLot = TextEditingController();
  final _vaccinDci = TextEditingController();

  // ── Traçabilité ──────────────────────────────────────────────────
  bool _carteRemise = false;
  final _numeroCarte = TextEditingController();
  bool _inscritRegistre = false;
  final _numeroRegistre = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _conclusionController.dispose();
    _medecinController.dispose();
    _centreController.dispose();
    _heureArrivee.dispose();
    _modeArrivee.dispose();
    _structureOrientation.dispose();
    _adresseResidence.dispose();
    _commune.dispose();
    _daira.dispose();
    _wilaya.dispose();
    _animalEspece.dispose();
    _animalStatut.dispose();
    _animalComportement.dispose();
    _animalProprietaire.dispose();
    _animalObservationVet.dispose();
    _animalSort.dispose();
    _animalResultat.dispose();
    _produitsAppliques.dispose();
    _erigLot.dispose();
    _erigDoseTheorique.dispose();
    _erigDilution.dispose();
    _erigVoies.dispose();
    _erigReaction.dispose();
    _vaccinType.dispose();
    _vaccinVoie.dispose();
    _vaccinLot.dispose();
    _vaccinDci.dispose();
    _numeroCarte.dispose();
    _numeroRegistre.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final patientRepo = di.sl<PatientAntirabiqueRepository>();
    final evalRepo = di.sl<EvaluationInitialeRepository>();
    final patient = await patientRepo.getPatientById(widget.patientId);
    final existing = await evalRepo.getEvaluation(widget.patientId);
    if (existing != null) {
      _exposition = existing.exposition;
      _plaie = existing.plaie;
      _etatClinique = existing.etatClinique;
      _antecedents = existing.antecedents;
      _conduite = existing.conduite;
      _decision = existing.decision;
      _observationsController.text = existing.observationsCliniques ?? '';
      _conclusionController.text = existing.conclusionMedicale ?? '';
      _medecinController.text = existing.medecinEvaluateur ?? '';
      _centreController.text = existing.centre ?? '';
      _priorite = existing.niveauPriorite;
      _heureArrivee.text = existing.heureArrivee ?? '';
      _modeArrivee.text = existing.modeArrivee ?? '';
      _structureOrientation.text = existing.structureOrientation ?? '';
      _adresseResidence.text = existing.adresseResidence ?? '';
      _commune.text = existing.commune ?? '';
      _daira.text = existing.daira ?? '';
      _wilaya.text = existing.wilaya ?? '';
      _animalEspece.text =
          existing.animalEspece ?? existing.exposition.especeAnimale ?? '';
      _animalStatut.text = existing.animalStatut ?? '';
      _animalComportement.text = existing.animalComportement ?? '';
      _animalProprietaire.text = existing.animalProprietaire ?? '';
      _animalObservationVet.text = existing.animalObservationVet ?? '';
      _animalSort.text = existing.animalSort ?? '';
      _animalResultat.text = existing.animalResultat ?? '';
      _lavageEau = existing.lavageEau;
      _lavageEauSavon = existing.lavageEauSavon;
      _produitsAppliques.text = existing.produitsAppliques ?? '';
      _erigIndiquee = existing.erigIndiquee;
      _erigAdministree = existing.erigAdministree;
      _erigLot.text = existing.erigLot ?? '';
      _erigDoseTheorique.text = existing.erigDoseTheorique ?? '';
      _erigDilution.text = existing.erigDilution ?? '';
      _erigVoies.text = existing.erigVoies ?? '';
      _erigReaction.text = existing.erigReaction ?? '';
      _vaccinType.text = existing.vaccinType ?? '';
      _vaccinVoie.text = existing.vaccinVoie ?? '';
      _vaccinLot.text = existing.vaccinLot ?? '';
      _vaccinDci.text = existing.vaccinDci ?? '';
      _carteRemise = existing.carteRemise;
      _numeroCarte.text = existing.numeroCarte ?? '';
      _inscritRegistre = existing.inscritRegistre;
      _numeroRegistre.text = existing.numeroRegistre ?? '';
    } else if (patient != null) {
      // Pré-remplissage à partir de l'admission du patient (nouveau patient).
      _heureArrivee.text = patient.heureAdmission ?? '';
      _modeArrivee.text = patient.modeArrivee ?? '';
      _structureOrientation.text = patient.structureOrientation ?? '';
      _adresseResidence.text = patient.adresse ?? '';
      _commune.text = patient.commune ?? '';
      _daira.text = patient.daira ?? '';
      _wilaya.text = patient.wilaya ?? '';
    }
    setState(() {
      _patient = patient;
      _existing = existing;
      _loading = false;
    });
  }

  String? _text(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  InitialRabiesAssessment _buildAssessment() {
    return InitialRabiesAssessment(
      patientId: widget.patientId,
      dateEvaluation: _existing?.dateEvaluation ??
          DateTime.now().toIso8601String().split('T').first,
      medecinEvaluateur: _text(_medecinController),
      centre: _text(_centreController),
      niveauPriorite: _priorite,
      exposition: _exposition.copyWith(
        especeAnimale: _animalEspece.text.trim().isEmpty
            ? _exposition.especeAnimale
            : _animalEspece.text.trim(),
      ),
      plaie: _plaie,
      etatClinique: _etatClinique,
      antecedents: _antecedents,
      conduite: _conduite,
      decision: _decision,
      heureArrivee: _text(_heureArrivee),
      modeArrivee: _text(_modeArrivee),
      structureOrientation: _text(_structureOrientation),
      adresseResidence: _text(_adresseResidence),
      commune: _text(_commune),
      daira: _text(_daira),
      wilaya: _text(_wilaya),
      animalEspece: _text(_animalEspece),
      animalStatut: _text(_animalStatut),
      animalComportement: _text(_animalComportement),
      animalProprietaire: _text(_animalProprietaire),
      animalObservationVet: _text(_animalObservationVet),
      animalSort: _text(_animalSort),
      animalResultat: _text(_animalResultat),
      lavageEau: _lavageEau,
      lavageEauSavon: _lavageEauSavon,
      produitsAppliques: _text(_produitsAppliques),
      erigIndiquee: _erigIndiquee,
      erigAdministree: _erigAdministree,
      erigLot: _text(_erigLot),
      erigDoseTheorique: _text(_erigDoseTheorique),
      erigDilution: _text(_erigDilution),
      erigVoies: _text(_erigVoies),
      erigReaction: _text(_erigReaction),
      vaccinType: _text(_vaccinType),
      vaccinVoie: _text(_vaccinVoie),
      vaccinLot: _text(_vaccinLot),
      vaccinDci: _text(_vaccinDci),
      carteRemise: _carteRemise,
      numeroCarte: _text(_numeroCarte),
      inscritRegistre: _inscritRegistre,
      numeroRegistre: _text(_numeroRegistre),
      observationsCliniques: _text(_observationsController),
      conclusionMedicale: _text(_conclusionController),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = di.sl<EvaluationInitialeRepository>();
    await repo.saveEvaluation(_buildAssessment());
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _existing != null
              ? 'Évaluation initiale mise à jour'
              : 'Évaluation initiale enregistrée',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        ),
      ),
    );
    Navigator.of(context).pop(true);
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: EpidemiologyTheme.slate700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _existing != null ? 'Révision de l\'évaluation J0' : 'Nouvelle évaluation J0',
          style: J0Ui.text(
              size:  16, weight: FontWeight.w700,
              color: EpidemiologyTheme.slate900),
        ),
        centerTitle: false,
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      backgroundColor: EpidemiologyTheme.slate50,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildWizardBody(),
      bottomNavigationBar: _loading
          ? null
          : J0StepNavigationBar(
              currentIndex: _currentStep,
              totalSteps: J0CreationSteps.tous.length,
              hasPrevious: _currentStep > 0,
              isLast: _currentStep == J0CreationSteps.tous.length - 1,
              saving: _saving,
              onPrevious: _previousStep,
              onNext: _nextStep,
              onSaveDraft: _save,
              onValidate: _save,
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // WIZARD SHELL
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildWizardBody() {
    final assessment = _buildAssessment();
    final steps = J0CreationSteps.tous;
    final statuses = [
      for (final s in steps)
        J0CreationStatus.statusFor(s, assessment, _patient?.categorieExposition),
    ];
    final summary = J0CreationSummary.from(assessment, _patient, steps, statuses);
    final isWide = MediaQuery.of(context).size.width > 880;

    return Column(
      children: [
        J0StepperHeader(
          steps: steps,
          currentIndex: _currentStep,
          statusOf: (i) => statuses[i],
          onTap: _goToStep,
        ),
        const Divider(height: 1),
        Expanded(
          child: isWide
              ? _buildDesktopLayout(steps, statuses, summary)
              : _buildMobileLayout(steps, statuses, summary),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    List<J0StepData> steps,
    List<J0StepStatus> statuses,
    J0CreationSummary summary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildStepScroll(steps, statuses, summary)),
        const SizedBox(width: 16),
        SizedBox(
          width: 340,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 32),
            child: J0CreationSummaryPanel(
              summary: summary,
              saving: _saving,
              onSaveDraft: _save,
              onValidate: _save,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    List<J0StepData> steps,
    List<J0StepStatus> statuses,
    J0CreationSummary summary,
  ) {
    return _buildStepScroll(steps, statuses, summary);
  }

  Widget _buildStepScroll(
    List<J0StepData> steps,
    List<J0StepStatus> statuses,
    J0CreationSummary summary,
  ) {
    final step = steps[_currentStep];
    final isLast = _currentStep == steps.length - 1;
    final isWide = MediaQuery.of(context).size.width > 880;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildPatientBanner(),
        const SizedBox(height: 14),
        J0StepCard(
          step: step,
          index: _currentStep,
          total: steps.length,
          status: statuses[_currentStep],
          child: _buildStepContent(step.id),
        ),
        if (isLast && !isWide) ...[
          const SizedBox(height: 4),
          J0CreationSummaryPanel(
            summary: summary,
            saving: _saving,
            onSaveDraft: _save,
            onValidate: _save,
          ),
        ],
      ],
    );
  }

  void _goToStep(int index) => setState(() => _currentStep = index);

  void _nextStep() {
    if (_currentStep < J0CreationSteps.tous.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  // ═══════════════════════════════════════════════════════════════════
  // PATIENT BANNER
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPatientBanner() {
    final p = _patient;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(18),
        boxShadow: EpidemiologyTheme.heroShadow(EpidemiologyTheme.redDeep),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              p != null
                  ? p.nomComplet
                      .split(' ')
                      .where((e) => e.isNotEmpty)
                      .take(2)
                      .map((e) => e[0])
                      .join()
                  : '?',
              style: J0Ui.text(
                size:  15,
                weight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p?.nomComplet ?? 'Patient',
                  style: J0Ui.text(
                    size:  16,
                    weight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p == null
                      ? 'Chargement…'
                      : '${p.id} · ${p.age} ans · ${p.sexe}',
                  style: J0Ui.text(
                    size:  12,
                    weight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (p != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                p.typeExposition?.label ?? 'Non évalué',
                style: J0Ui.text(
                  size:  11,
                  weight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP CONTENT
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepContent(String id) {
    switch (id) {
      case 'patient':
        return _stepPatient();
      case 'exposition':
        return _stepExposition();
      case 'lesions':
        return _stepLesions();
      case 'classification':
        return _stepClassification();
      case 'animal':
        return _stepAnimal();
      case 'soins':
        return _stepSoins();
      case 'vaccination':
        return _stepVaccination();
      case 'tracabilite':
        return _stepTracabilite();
      default:
        return const SizedBox();
    }
  }

  // ── Étape 1 : Patient / Admission ────────────────────────────────

  Widget _stepPatient() {
    final p = _patient;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        J0SectionTitle('Patient', icon: Icons.badge_outlined),
        J0InfoRow(
          icon: Icons.person_outline,
          label: 'Identité',
          value: p == null
              ? '—'
              : '${p.nomComplet} · ${p.age} ans · ${p.sexe}',
        ),
        J0InfoRow(
          icon: Icons.phone_outlined,
          label: 'Téléphone',
          value: p?.telephone ?? 'Non renseigné',
        ),
        J0InfoRow(
          icon: Icons.medical_information_outlined,
          label: 'Site de la morsure',
          value: p?.siteMorsure ?? 'Non renseigné',
        ),
        const SizedBox(height: 8),
        J0SectionTitle('Adresse de résidence',
            icon: Icons.location_on_outlined),
        J0TextField(
          label: 'Adresse',
          hint: 'Rue, lotissement…',
          controller: _adresseResidence,
          prefixIcon: Icons.home_outlined,
        ),
        J0TextField(
          label: 'Commune',
          hint: 'Commune de résidence',
          controller: _commune,
          prefixIcon: Icons.location_city_outlined,
        ),
        Row(
          children: [
            Expanded(
              child: J0TextField(
                label: 'Daïra',
                hint: 'Daïra',
                controller: _daira,
                prefixIcon: Icons.map_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: J0TextField(
                label: 'Wilaya',
                hint: 'Wilaya',
                controller: _wilaya,
                prefixIcon: Icons.flag_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        J0SectionTitle('Admission à l\'UAR',
            icon: Icons.local_hospital_outlined),
        J0TextField(
          label: 'Heure d\'arrivée',
          hint: 'ex : 14:30',
          controller: _heureArrivee,
          prefixIcon: Icons.schedule,
        ),
        _ChoiceBlock(
          label: 'Mode d\'arrivée',
          child: J0ChoicePills<String>(
            options: const [
              J0ChoiceOption('Venu directement', 'Venu directement'),
              J0ChoiceOption('Référé', 'Référé'),
              J0ChoiceOption('Transféré', 'Transféré'),
            ],
            selected: _modeArrivee.text.isEmpty
                ? null
                : _modeArrivee.text,
            onChanged: (v) => setState(() => _modeArrivee.text = v),
          ),
        ),
        J0TextField(
          label: 'Structure d\'orientation',
          hint: 'Établissement de santé d\'origine',
          controller: _structureOrientation,
          prefixIcon: Icons.forward_outlined,
        ),
      ],
    );
  }

  // ── Étape 2 : Exposition au risque rabique ───────────────────────

  Widget _stepExposition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        J0SectionTitle('Circonstances', icon: Icons.event_outlined),
        Row(
          children: [
            Expanded(
              child: J0DateField(
                label: 'Date d\'exposition',
                value: _exposition.dateExposition,
                onPicked: (d) => setState(() => _exposition =
                    _exposition.copyWith(
                        dateExposition:
                            d.toIso8601String().split('T').first)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: J0TimeField(
                label: 'Heure',
                value: _exposition.heureExposition,
                onPicked: (t) => setState(() {
                  final hh = t.hour.toString().padLeft(2, '0');
                  final mm = t.minute.toString().padLeft(2, '0');
                  _exposition =
                      _exposition.copyWith(heureExposition: '$hh:$mm');
                }),
              ),
            ),
          ],
        ),
        J0TextField(
          label: 'Siège / localisation des lésions',
          hint: 'ex : membre inférieur droit',
          controller:
              TextEditingController(text: _exposition.localisation ?? ''),
          onChangedText: (v) =>
              _exposition = _exposition.copyWith(localisation: v),
        ),
        J0TextField(
          label: 'Nombre de lésions',
          hint: '0',
          controller: TextEditingController(
              text: _exposition.nombreLesions?.toString() ?? ''),
          keyboardType: TextInputType.number,
          onChangedText: (v) => _exposition =
              _exposition.copyWith(nombreLesions: int.tryParse(v)),
        ),
        const SizedBox(height: 8),
        J0SectionTitle('Nature de l\'exposition',
            icon: Icons.pets_outlined),
        J0ToggleTile(
          label: 'Morsure',
          icon: Icons.report_problem_outlined,
          value: _exposition.morsure,
          onChanged: (v) =>
              setState(() => _exposition = _exposition.copyWith(morsure: v)),
        ),
        J0ToggleTile(
          label: 'Griffure',
          icon: Icons.emergency_outlined,
          value: _exposition.griffure,
          onChanged: (v) =>
              setState(() => _exposition = _exposition.copyWith(griffure: v)),
        ),
        J0ToggleTile(
          label: 'Contact salivaire sur peau lésée',
          icon: Icons.water_drop_outlined,
          value: _exposition.contactSalivairePeauLestee,
          onChanged: (v) => setState(() => _exposition =
              _exposition.copyWith(contactSalivairePeauLestee: v)),
        ),
        J0ToggleTile(
          label: 'Contact salivaire sur muqueuse',
          icon: Icons.water_drop_outlined,
          value: _exposition.contactSalivaireMuqueuse,
          onChanged: (v) => setState(() => _exposition =
              _exposition.copyWith(contactSalivaireMuqueuse: v)),
        ),
        const SizedBox(height: 8),
        J0ToggleTile(
          label: 'Exposition jugée significative',
          help: 'Exposition réelle nécessitant une évaluation du risque',
          icon: Icons.flag_outlined,
          color: EpidemiologyTheme.danger,
          value: _exposition.expositionJugeeSignificative,
          onChanged: (v) => setState(() => _exposition =
              _exposition.copyWith(expositionJugeeSignificative: v)),
        ),
      ],
    );
  }

  // ── Étape 3 : Lésions / Gravité locale ───────────────────────────

  Widget _stepLesions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        J0SectionTitle('Soins immédiats de la plaie',
            icon: Icons.clean_hands_outlined),
        J0ToggleTile(
          label: 'Plaie lavée immédiatement',
          icon: Icons.water_outlined,
          value: _plaie.plaieLaveeImmediatement,
          onChanged: (v) => setState(
              () => _plaie = _plaie.copyWith(plaieLaveeImmediatement: v)),
        ),
        J0ToggleTile(
          label: 'Désinfection réalisée',
          icon: Icons.local_hospital_outlined,
          value: _plaie.desinfectionRealisee,
          onChanged: (v) => setState(
              () => _plaie = _plaie.copyWith(desinfectionRealisee: v)),
        ),
        const SizedBox(height: 8),
        J0SectionTitle('Éléments de gravité locale',
            icon: Icons.healing_outlined),
        J0ToggleTile(
          label: 'Plaie profonde',
          icon: Icons.ads_click_outlined,
          color: EpidemiologyTheme.danger,
          value: _plaie.plaieProfonde,
          onChanged: (v) =>
              setState(() => _plaie = _plaie.copyWith(plaieProfonde: v)),
        ),
        J0ToggleTile(
          label: 'Plaie multiple',
          icon: Icons.food_bank_outlined,
          color: EpidemiologyTheme.danger,
          value: _plaie.plaieMultiple,
          onChanged: (v) =>
              setState(() => _plaie = _plaie.copyWith(plaieMultiple: v)),
        ),
        J0ToggleTile(
          label: 'Atteinte tête / cou',
          icon: Icons.face_retouching_natural_outlined,
          color: EpidemiologyTheme.danger,
          value: _plaie.atteinteTeteCou,
          onChanged: (v) =>
              setState(() => _plaie = _plaie.copyWith(atteinteTeteCou: v)),
        ),
        J0ToggleTile(
          label: 'Atteinte main / doigts',
          icon: Icons.back_hand_outlined,
          color: EpidemiologyTheme.danger,
          value: _plaie.atteinteMainDoigts,
          onChanged: (v) => setState(
              () => _plaie = _plaie.copyWith(atteinteMainDoigts: v)),
        ),
        J0ToggleTile(
          label: 'Saignement important',
          icon: Icons.bloodtype_outlined,
          color: EpidemiologyTheme.warning,
          value: _plaie.saignementImportant,
          onChanged: (v) =>
              setState(() => _plaie = _plaie.copyWith(saignementImportant: v)),
        ),
        J0ToggleTile(
          label: 'Plaie nécessitant des soins complémentaires',
          icon: Icons.medical_services_outlined,
          color: EpidemiologyTheme.warning,
          value: _plaie.plaieNecessiteSoinsComplementaires,
          onChanged: (v) => setState(() => _plaie =
              _plaie.copyWith(plaieNecessiteSoinsComplementaires: v)),
        ),
      ],
    );
  }

  // ── Étape 4 : Classification du risque ───────────────────────────

  Widget _stepClassification() {
    final cat = _patient?.categorieExposition;
    final (Color color, String roman, String title) = switch (cat) {
      CategorieExposition.categorieI =>
        (EpidemiologyTheme.success, 'I', 'Catégorie I'),
      CategorieExposition.categorieII =>
        (EpidemiologyTheme.warning, 'II', 'Catégorie II'),
      CategorieExposition.categorieIII =>
        (EpidemiologyTheme.danger, 'III', 'Catégorie III'),
      null => (EpidemiologyTheme.warm400, '—', 'À déterminer'),
    };
    final synthese = _buildAssessment().synthese;
    final syntheseColor = switch (synthese) {
      DecisionSynthese.compatibleDemarrage => EpidemiologyTheme.success,
      DecisionSynthese.precautionsComplementaires => EpidemiologyTheme.warning,
      DecisionSynthese.avisSpecialiseRequis => EpidemiologyTheme.danger,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.10),
                color.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  roman,
                  style: J0Ui.text(
                    size:  22,
                    weight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: J0Ui.text(
                        size:  17,
                        weight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      cat?.description ??
                          'La catégorie est issue de la fiche patient.',
                      style: J0Ui.text(
                        size:  12,
                        weight: FontWeight.w500,
                        color: EpidemiologyTheme.warm600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        J0Note(
          icon: Icons.psychology_alt_outlined,
          title: synthese.label,
          message: _buildAssessment().messageSynthese,
          color: syntheseColor,
        ),
        const SizedBox(height: 6),
        J0SectionTitle('Conduite initiale', icon: Icons.shield_outlined),
        J0ToggleTile(
          label: 'Vaccination antirabique indiquée',
          icon: Icons.vaccines_outlined,
          color: EpidemiologyTheme.success,
          value: _conduite.vaccinationIndiquee,
          onChanged: (v) => setState(
              () => _conduite = _conduite.copyWith(vaccinationIndiquee: v)),
        ),
        J0ToggleTile(
          label: 'Immunoglobulines (ERIG) à envisager',
          icon: Icons.bloodtype_outlined,
          color: EpidemiologyTheme.warning,
          value: _conduite.immunoglobulinesAEnvisager,
          onChanged: (v) => setState(() => _conduite =
              _conduite.copyWith(immunoglobulinesAEnvisager: v)),
        ),
        J0ToggleTile(
          label: 'Surveillance clinique renforcée',
          icon: Icons.monitor_heart_outlined,
          value: _conduite.surveillanceCliniqueRenforcee,
          onChanged: (v) => setState(() => _conduite =
              _conduite.copyWith(surveillanceCliniqueRenforcee: v)),
        ),
        J0ToggleTile(
          label: 'Avis spécialisé nécessaire',
          icon: Icons.medical_services_outlined,
          color: EpidemiologyTheme.danger,
          value: _conduite.avisSpecialiseNecessaire,
          onChanged: (v) => setState(() =>
              _conduite = _conduite.copyWith(avisSpecialiseNecessaire: v)),
        ),
        const SizedBox(height: 8),
        J0SectionTitle('Protocole à démarrer',
            icon: Icons.event_note_outlined),
        J0ChoicePills<String>(
          options: const [
            J0ChoiceOption('essen', 'Essen (5 doses)',
                help: 'J0 · J3 · J7 · J14 · J28'),
            J0ChoiceOption('zagreb', 'Zagreb (2-1-1)',
                help: 'J0 (2) · J7 · J21'),
            J0ChoiceOption('apres', 'Après confirmation',
                help: 'Démarrage conditionné'),
          ],
          selected: _decision.demarrerEssen
              ? 'essen'
              : _decision.demarrerZagreb
                  ? 'zagreb'
                  : _decision.demarrerApresConfirmation
                      ? 'apres'
                      : null,
          onChanged: (v) => setState(() {
            _decision = DecisionMedicale(
              demarrerEssen: v == 'essen',
              demarrerZagreb: v == 'zagreb',
              demarrerApresConfirmation: v == 'apres',
              reevaluationNecessaire: _decision.reevaluationNecessaire,
            );
          }),
        ),
        const SizedBox(height: 10),
        J0ToggleTile(
          label: 'Réévaluation complémentaire nécessaire',
          icon: Icons.autorenew_outlined,
          color: EpidemiologyTheme.danger,
          value: _decision.reevaluationNecessaire,
          onChanged: (v) =>
              setState(() => _decision = _decision.copyWith(
                  reevaluationNecessaire: v)),
        ),
      ],
    );
  }

  // ── Étape 5 : Animal en cause ────────────────────────────────────

  Widget _stepAnimal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        J0SectionTitle('Animal en cause', icon: Icons.pets_outlined),
        J0TextField(
          label: 'Espèce de l\'animal',
          hint: 'ex : chien, chat…',
          controller: _animalEspece,
          prefixIcon: Icons.pets_outlined,
        ),
        _ChoiceBlock(
          label: 'Statut de l\'animal',
          child: J0ChoicePills<String>(
            options: [
              for (final s in AnimauxStatut.values)
                J0ChoiceOption(s.label, s.label),
            ],
            selected: _animalStatut.text.isEmpty ? null : _animalStatut.text,
            onChanged: (v) => setState(() => _animalStatut.text = v),
          ),
        ),
        const SizedBox(height: 10),
        _ChoiceBlock(
          label: 'Comportement',
          child: J0ChoicePills<String>(
            options: const [
              J0ChoiceOption('Normal', 'Normal'),
              J0ChoiceOption('Suspect', 'Suspect'),
              J0ChoiceOption('Agressif', 'Agressif'),
              J0ChoiceOption('Inconnu', 'Inconnu'),
            ],
            selected:
                _animalComportement.text.isEmpty ? null : _animalComportement.text,
            onChanged: (v) => setState(() => _animalComportement.text = v),
          ),
        ),
        J0TextField(
          label: 'Propriétaire (si connu)',
          hint: 'Nom et coordonnées',
          controller: _animalProprietaire,
          prefixIcon: Icons.person_outline,
        ),
        J0TextField(
          label: 'Observation vétérinaire',
          hint: 'Résultats de l\'examen vétérinaire',
          controller: _animalObservationVet,
          maxLines: 2,
          prefixIcon: Icons.monitor_heart_outlined,
        ),
        const SizedBox(height: 8),
        _ChoiceBlock(
          label: 'Sort de l\'animal',
          child: J0ChoicePills<String>(
            options: const [
              J0ChoiceOption('En observation', 'En observation'),
              J0ChoiceOption('Abattu', 'Abattu'),
              J0ChoiceOption('Mort', 'Mort'),
              J0ChoiceOption('En fuite', 'En fuite'),
            ],
            selected: _animalSort.text.isEmpty ? null : _animalSort.text,
            onChanged: (v) => setState(() => _animalSort.text = v),
          ),
        ),
        J0TextField(
          label: 'Résultat (analyse / surveillance)',
          hint: 'En attente, rage confirmée, non enragé…',
          controller: _animalResultat,
          prefixIcon: Icons.science_outlined,
        ),
      ],
    );
  }

  // ── Étape 6 : Soins locaux / ERIG ────────────────────────────────

  Widget _stepSoins() {
    final cat = _patient?.categorieExposition;
    final erigRecommandee =
        cat == CategorieExposition.categorieIII && !_erigAdministree;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        J0SectionTitle('Soins locaux', icon: Icons.clean_hands_outlined),
        J0ToggleTile(
          label: 'Lavage à l\'eau',
          icon: Icons.water_outlined,
          value: _lavageEau,
          onChanged: (v) => setState(() => _lavageEau = v),
        ),
        J0ToggleTile(
          label: 'Lavage à l\'eau + savon',
          icon: Icons.clean_hands_outlined,
          value: _lavageEauSavon,
          onChanged: (v) => setState(() => _lavageEauSavon = v),
        ),
        J0TextField(
          label: 'Produits appliqués',
          hint: 'Antiseptique (alcool, povidone iodée…)',
          controller: _produitsAppliques,
          prefixIcon: Icons.sanitizer_outlined,
        ),
        if (erigRecommandee)
          J0Note(
            icon: Icons.bloodtype_outlined,
            title: 'ERIG recommandée (catégorie III)',
            message:
                'Les immunoglobulines sont recommandées pour les expositions de catégorie III. À administrer le jour même si possible.',
            color: EpidemiologyTheme.warning,
          ),
        const SizedBox(height: 8),
        J0SectionTitle('Immunoglobulines (ERIG)',
            icon: Icons.bloodtype_outlined),
        J0ToggleTile(
          label: 'ERIG indiquée',
          icon: Icons.bloodtype_outlined,
          value: _erigIndiquee,
          onChanged: (v) => setState(() => _erigIndiquee = v),
        ),
        if (_erigIndiquee)
          J0ToggleTile(
            label: 'ERIG administrée',
            icon: Icons.check_circle_outline,
            color: EpidemiologyTheme.success,
            value: _erigAdministree,
            onChanged: (v) => setState(() => _erigAdministree = v),
          ),
        if (_erigIndiquee || _erigAdministree) ...[
          Row(
            children: [
              Expanded(
                child: J0TextField(
                  label: 'Lot ERIG',
                  hint: 'N° de lot',
                  controller: _erigLot,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: J0TextField(
                  label: 'Dose théorique',
                  hint: 'UI/kg',
                  controller: _erigDoseTheorique,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: J0TextField(
                  label: 'Dilution',
                  hint: 'ex : 1/1, 1/10',
                  controller: _erigDilution,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: J0TextField(
                  label: 'Voies d\'administration',
                  hint: 'ex : IM, infiltration',
                  controller: _erigVoies,
                ),
              ),
            ],
          ),
          J0TextField(
            label: 'Réaction post-ERIG',
            hint: 'Réaction locale ou générale éventuelle',
            controller: _erigReaction,
            maxLines: 2,
            prefixIcon: Icons.warning_amber_outlined,
          ),
        ],
      ],
    );
  }

  // ── Étape 7 : Vaccination / Protocole ────────────────────────────

  Widget _stepVaccination() {
    final ProtocoleType? proto = _decision.demarrerEssen
        ? ProtocoleType.essen
        : _decision.demarrerZagreb
            ? ProtocoleType.zagreb
            : null;
    final timeline = _decision.demarrerEssen
        ? const ['J0', 'J3', 'J7', 'J14', 'J28']
        : _decision.demarrerZagreb
            ? const ['J0 (2)', 'J7', 'J21']
            : const <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (proto != null) ...[
          J0Note(
            icon: Icons.vaccines_outlined,
            title: 'Schéma ${proto.label} · ${proto.duree}',
            message: proto.description,
            color: EpidemiologyTheme.redPrimary,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final d in timeline)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    d,
                    style: J0Ui.text(
                      size: 12,
                      weight: FontWeight.w700,
                      color: EpidemiologyTheme.redPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        J0SectionTitle('Première dose', icon: Icons.vaccines_outlined),
        J0TextField(
          label: 'Type de vaccin',
          hint: 'ex : PCECV, PVRV…',
          controller: _vaccinType,
          prefixIcon: Icons.science_outlined,
        ),
        _ChoiceBlock(
          label: 'Voie d\'administration',
          child: J0ChoicePills<String>(
            options: const [
              J0ChoiceOption('IM', 'IM (intramusculaire)'),
              J0ChoiceOption('SC', 'SC (sous-cutanée)'),
              J0ChoiceOption('ID', 'ID (intradermique)'),
            ],
            selected: _vaccinVoie.text.isEmpty ? null : _vaccinVoie.text,
            onChanged: (v) => setState(() => _vaccinVoie.text = v),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: J0TextField(
                label: 'N° de lot',
                hint: 'Lot du vaccin',
                controller: _vaccinLot,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: J0TextField(
                label: 'DCI',
                hint: 'Dénomination commune',
                controller: _vaccinDci,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        J0Note(
          icon: Icons.event_repeat_outlined,
          title: 'Calendrier prévu',
          message: proto == null
              ? 'Le calendrier des doses sera généré une fois le protocole choisi à l\'étape « Classification du risque ».'
              : '${proto.totalDoses} doses · ${proto.nombreVisites} visites · ${proto.duree}',
          color: EpidemiologyTheme.info,
        ),
      ],
    );
  }

  // ── Étape 8 : Traçabilité / Validation finale ────────────────────

  Widget _stepTracabilite() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        J0SectionTitle('Traçabilité réglementaire',
            icon: Icons.verified_outlined),
        J0ToggleTile(
          label: 'Carte de vaccination remise',
          icon: Icons.credit_card_outlined,
          value: _carteRemise,
          onChanged: (v) => setState(() => _carteRemise = v),
        ),
        if (_carteRemise)
          J0TextField(
            label: 'Numéro de carte',
            hint: 'N° de la carte de vaccination',
            controller: _numeroCarte,
            prefixIcon: Icons.numbers_outlined,
          ),
        J0ToggleTile(
          label: 'Patient inscrit au registre',
          icon: Icons.menu_book_outlined,
          value: _inscritRegistre,
          onChanged: (v) => setState(() => _inscritRegistre = v),
        ),
        if (_inscritRegistre)
          J0TextField(
            label: 'Numéro de registre',
            hint: 'N° d\'inscription au registre',
            controller: _numeroRegistre,
            prefixIcon: Icons.numbers_outlined,
          ),
        const SizedBox(height: 8),
        J0SectionTitle('Observations & conclusion',
            icon: Icons.edit_note_rounded),
        J0TextField(
          label: 'Observations cliniques',
          hint: 'Signes, évolution, éléments pertinents…',
          controller: _observationsController,
          maxLines: 3,
        ),
        J0TextField(
          label: 'Conclusion médicale',
          hint: 'Synthèse et orientation médicale…',
          controller: _conclusionController,
          maxLines: 3,
        ),
        Row(
          children: [
            Expanded(
              child: J0TextField(
                label: 'Médecin évaluateur',
                hint: 'Dr. …',
                controller: _medecinController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: J0TextField(
                label: 'Centre / Service',
                hint: '…',
                controller: _centreController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// En-tête de bloc de choix avec label, utilisé dans les étapes.
class _ChoiceBlock extends StatelessWidget {
  const _ChoiceBlock({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: J0Ui.text(
              size: 11.5,
              weight: FontWeight.w700,
              color: EpidemiologyTheme.warm500,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
