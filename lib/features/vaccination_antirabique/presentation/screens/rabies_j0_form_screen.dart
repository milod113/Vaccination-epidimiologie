import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/dossier_enums.dart';
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/models/dossier/rabies_clinical_alert.dart';
import '../../domain/models/dossier/rabies_decision_summary.dart';
import '../../domain/models/dossier/vaccination.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../../domain/services/rabies_alert_service.dart';
import '../../domain/services/rabies_decision_engine.dart';
import '../../domain/services/rabies_protocol_resolver.dart';
import '../../domain/services/actor_context.dart';
import '../../domain/services/rabies_traceability_service.dart';
import '../widgets/j0_wizard/j0_alert_banner.dart';
import '../widgets/j0_wizard/j0_review_summary_card.dart';
import '../widgets/j0_wizard/j0_step_card.dart';
import '../widgets/j0_wizard/j0_step_model.dart';
import '../widgets/j0_wizard/j0_step_navigation_bar.dart';
import '../widgets/j0_wizard/j0_stepper_header.dart';
import '../widgets/j0_wizard/j0_summary_panel.dart';
import '../widgets/j0_wizard/j0_ui.dart';
import '../widgets/rabies_dossier_widgets.dart';
import '../widgets/traceability/traceability_status_strip.dart';
import 'rabies_traceability_screen.dart';

class RabiesJ0FormScreen extends StatefulWidget {
  final String dossierId;

  const RabiesJ0FormScreen({super.key, required this.dossierId});

  @override
  State<RabiesJ0FormScreen> createState() => _RabiesJ0FormScreenState();
}

class _RabiesJ0FormScreenState extends State<RabiesJ0FormScreen> {
  RabiesCaseRecord? _record;
  bool _loading = true;
  bool _saving = false;
  int _currentStep = 0;

  late final TextEditingController _adresseController;
  late final TextEditingController _communeController;
  late final TextEditingController _dairaController;
  late final TextEditingController _wilayaController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _heureArriveeController;
  late final TextEditingController _heureExposureController;
  late final TextEditingController _orientationController;
  late final TextEditingController _justificationController;
  late final TextEditingController _animalAutreController;
  late final TextEditingController _proprietaireController;
  late final TextEditingController _pelageController;
  late final TextEditingController _produitsController;
  late final TextEditingController _erigLotController;
  late final TextEditingController _erigDoseController;
  late final TextEditingController _erigSerumController;
  late final TextEditingController _erigTitreController;
  late final TextEditingController _erigPoidsController;
  late final TextEditingController _erigReactionController;
  late final TextEditingController _vaccinLotController;
  late final TextEditingController _vaccinDciController;
  late final TextEditingController _antibiotiqueController;
  late final TextEditingController _tetanosObsController;
  late final TextEditingController _traceCarteController;
  late final TextEditingController _traceRegistreController;
  late final TextEditingController _chirurgieHopitalController;
  late final TextEditingController _chirurgieServiceController;
  late final TextEditingController _mpviManifestationsController;
  late final TextEditingController _mpviMesuresController;
  late final TextEditingController _autresTraitementsController;
  late final TextEditingController _notesFinalesController;

  @override
  void initState() {
    super.initState();
    _adresseController = TextEditingController();
    _communeController = TextEditingController();
    _dairaController = TextEditingController();
    _wilayaController = TextEditingController();
    _telephoneController = TextEditingController();
    _heureArriveeController = TextEditingController();
    _heureExposureController = TextEditingController();
    _orientationController = TextEditingController();
    _justificationController = TextEditingController();
    _animalAutreController = TextEditingController();
    _proprietaireController = TextEditingController();
    _pelageController = TextEditingController();
    _produitsController = TextEditingController();
    _erigLotController = TextEditingController();
    _erigDoseController = TextEditingController();
    _erigSerumController = TextEditingController();
    _erigTitreController = TextEditingController();
    _erigPoidsController = TextEditingController();
    _erigReactionController = TextEditingController();
    _vaccinLotController = TextEditingController();
    _vaccinDciController = TextEditingController();
    _antibiotiqueController = TextEditingController();
    _tetanosObsController = TextEditingController();
    _traceCarteController = TextEditingController();
    _traceRegistreController = TextEditingController();
    _chirurgieHopitalController = TextEditingController();
    _chirurgieServiceController = TextEditingController();
    _mpviManifestationsController = TextEditingController();
    _mpviMesuresController = TextEditingController();
    _autresTraitementsController = TextEditingController();
    _notesFinalesController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    for (final controller in [
      _adresseController,
      _communeController,
      _dairaController,
      _wilayaController,
      _telephoneController,
      _heureArriveeController,
      _heureExposureController,
      _orientationController,
      _justificationController,
      _animalAutreController,
      _proprietaireController,
      _pelageController,
      _produitsController,
      _erigLotController,
      _erigDoseController,
      _erigSerumController,
      _erigTitreController,
      _erigPoidsController,
      _erigReactionController,
      _vaccinLotController,
      _vaccinDciController,
      _antibiotiqueController,
      _tetanosObsController,
      _traceCarteController,
      _traceRegistreController,
      _chirurgieHopitalController,
      _chirurgieServiceController,
      _mpviManifestationsController,
      _mpviMesuresController,
      _autresTraitementsController,
      _notesFinalesController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final repo = di.sl<RabiesDossierRepository>();
    final dossier = await repo.getDossierById(widget.dossierId);
    if (!mounted) return;
    if (dossier != null) {
      _record = dossier;
      _hydrateControllers(dossier);
    }
    setState(() => _loading = false);
  }

  void _hydrateControllers(RabiesCaseRecord dossier) {
    _adresseController.text = dossier.identity.residence.adresse;
    _communeController.text = dossier.identity.residence.commune;
    _dairaController.text = dossier.identity.residence.daira;
    _wilayaController.text = dossier.identity.residence.wilaya;
    _telephoneController.text = dossier.identity.telephone ?? '';
    _heureArriveeController.text = dossier.admission.heureArrivee ?? '';
    _heureExposureController.text = dossier.exposition.heureExposition ?? '';
    _orientationController.text = dossier.admission.structureOrientation ?? '';
    _justificationController.text = dossier.classification.justification ?? '';
    _animalAutreController.text = dossier.animal.autreEspecePrecision ?? '';
    _proprietaireController.text = dossier.animal.proprietaireNom ?? '';
    _pelageController.text = dossier.animal.couleurPelage ?? '';
    _produitsController.text = dossier.soinsLocaux.produitsAppliques ?? '';
    _erigLotController.text = dossier.erig.numeroLot ?? '';
    _erigDoseController.text =
        dossier.erig.doseTotaleTheoriqueMl?.toString() ?? '';
    _erigSerumController.text =
        dossier.erig.quantiteSerumPhysiologiqueMl?.toString() ?? '';
    _erigTitreController.text = dossier.erig.titreIUMl?.toString() ?? '';
    _erigPoidsController.text = dossier.erig.poidsPatientKg?.toString() ?? '';
    _erigReactionController.text = dossier.erig.mesuresReaction ?? '';
    _vaccinLotController.text = dossier.vaccination.numeroLot ?? '';
    _vaccinDciController.text = dossier.vaccination.dci ?? '';
    _antibiotiqueController.text = dossier.antibiotiques.molecule ?? '';
    _tetanosObsController.text = dossier.vaccinationTetanos.observations ?? '';
    _traceCarteController.text = dossier.tracabilite.numeroCarte ?? '';
    _traceRegistreController.text = dossier.tracabilite.numeroRegistre ?? '';
    _chirurgieHopitalController.text = dossier.chirurgie.hopital ?? '';
    _chirurgieServiceController.text = dossier.chirurgie.service ?? '';
    _mpviManifestationsController.text = dossier.mpvi.manifestations ?? '';
    _mpviMesuresController.text = dossier.mpvi.mesuresPrises ?? '';
    _autresTraitementsController.text = dossier.autresTraitements.description ?? '';
    _notesFinalesController.text = dossier.evolution.observations ?? '';
  }

  Future<void> _save() async {
    final record = _record;
    if (record == null) return;
    setState(() => _saving = true);
    final repo = di.sl<RabiesDossierRepository>();
    final derived = _applyDerivedState(record);
    final hasJ0 = derived.historique
        .any((e) => e.typeAction == DossierHistoryActionType.evaluationJ0Validee);
    final updated = hasJ0
        ? derived
        : RabiesTraceabilityService.validerEtape(
            derived,
            etape: ValidationStepType.ficheJ0,
            acteur: ActorContext.medecin,
            description: 'Fiche J0 enregistrée et validée.',
            nouvelleValeur: derived.categorie.label,
          );
    final saved = await repo.saveDossier(updated);
    if (!mounted) return;
    setState(() {
      _record = saved;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fiche J0 enregistrée'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _openTraceability() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RabiesTraceabilityScreen(dossierId: widget.dossierId),
      ),
    );
    if (!mounted) return;
    final repo = di.sl<RabiesDossierRepository>();
    final dossier = await repo.getDossierById(widget.dossierId);
    if (dossier != null && mounted) {
      setState(() {
        _record = dossier;
        _hydrateControllers(dossier);
      });
    }
  }

  RabiesCaseRecord _applyDerivedState(RabiesCaseRecord input) {
    final catDecision = RabiesDecisionEngine.categorie(input.exposition);
    final category = catDecision.categorie;
    final shouldErig = category == RabiesRiskCategory.categorieIII;

    final protocolDecision = RabiesDecisionEngine.protocole(
      category,
      dejaVaccine:
          input.vaccination.protocole.type == VaccinationProtocolType.rappelJ0J3,
      immunodeprime: input.identity.terrainParticulier
              ?.toLowerCase()
              .contains('immuno') ??
          false,
      vaccinTissulaire:
          input.vaccination.typeVaccin == RabiesVaccineType.vaccinTissulaire,
    );

    final haveVaccin = input.vaccination.typeVaccin != RabiesVaccineType.non;
    final protocolType = haveVaccin ? protocolDecision?.type : null;

    final generated = protocolType == null
        ? const <VaccineDose>[]
        : RabiesProtocolResolver.genererDoses(
            type: protocolType,
            dateDebut: input.admission.dateArriveeUar ?? DateTime.now(),
            premiereRealisee: true,
          );

    final protocol = haveVaccin
        ? input.vaccination.protocole.copyWith(
            type: protocolType!,
            dateDebut: input.admission.dateArriveeUar ?? DateTime.now(),
            doses: _mergeDoseHistory(
              generated,
              input.vaccination.protocole.doses,
            ),
            complete: false,
          )
        : input.vaccination.protocole.copyWith(doses: const []);

    return input.copyWith(
      classification: input.classification.copyWith(
        categorie: category,
        justification: catDecision.raison,
        methode: RiskAssessmentMethod.automatique,
      ),
      erig: input.erig.copyWith(indiquee: shouldErig),
      vaccination: input.vaccination.copyWith(protocole: protocol),
    );
  }

  List<VaccineDose> _mergeDoseHistory(
    List<VaccineDose> generated,
    List<VaccineDose> previous,
  ) {
    return List.generate(generated.length, (index) {
      if (index >= previous.length) return generated[index];
      final old = previous[index];
      return generated[index].copyWith(
        dateReelle: old.dateReelle,
        numeroLot: old.numeroLot,
        notes: old.notes,
        statut: old.statut,
      );
    });
  }

  void _updateRecord(RabiesCaseRecord Function(RabiesCaseRecord current) mutate) {
    final current = _record;
    if (current == null) return;
    setState(() {
      _record = mutate(current);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final record = _record;
    if (record == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Dossier introuvable',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    final computed = _applyDerivedState(record);
    final alerts = RabiesAlertService.evaluer(computed);
    final summary = RabiesDecisionEngine.resumer(computed);
    final isWide = MediaQuery.of(context).size.width > 880;

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        backgroundColor: EpidemiologyTheme.white,
        elevation: 0,
        title: Text(
          'Fiche J0 · ${computed.numeroDossier}',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.slate900,
          ),
        ),
      ),
      body: Column(
        children: [
          J0StepperHeader(
            steps: J0StepData.tous,
            currentIndex: _currentStep,
            statusOf: (i) => _stepStatusFor(i, computed, alerts),
            onTap: _goToStep,
          ),
          const Divider(height: 1),
          Expanded(
            child: isWide
                ? _buildDesktopLayout(computed, alerts, summary)
                : _buildMobileLayout(computed, alerts, summary),
          ),
          if (!isWide) _buildMobileSummaryStrip(summary),
          J0StepNavigationBar(
            currentIndex: _currentStep,
            totalSteps: J0StepData.tous.length,
            hasPrevious: _currentStep > 0,
            isLast: _currentStep == J0StepData.tous.length - 1,
            saving: _saving,
            onPrevious: _previousStep,
            onNext: _nextStep,
            onSaveDraft: _saveDraft,
            onValidate: _save,
          ),
        ],
      ),
    );
  }

  // ── Navigation du wizard ────────────────────────────────────────────────

  void _goToStep(int index) {
    if (index < 0 || index >= J0StepData.tous.length) return;
    setState(() => _currentStep = index);
  }

  void _nextStep() {
    if (_currentStep < J0StepData.tous.length - 1) _goToStep(_currentStep + 1);
  }

  void _previousStep() {
    if (_currentStep > 0) _goToStep(_currentStep - 1);
  }

  Future<void> _saveDraft() async {
    final record = _record;
    if (record == null) return;
    final repo = di.sl<RabiesDossierRepository>();
    final saved = await repo.saveDossier(_applyDerivedState(record));
    if (!mounted) return;
    setState(() => _record = saved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Brouillon enregistré'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Statut de complétude d'une étape, déduit du modèle et des alertes.
  J0StepStatus _stepStatusFor(
    int index,
    RabiesCaseRecord record,
    List<RabiesClinicalAlert> alerts,
  ) {
    final step = J0StepData.tous[index];
    final stepAlerts = alerts.where((a) => step.sections.contains(a.section));
    final hasCritical = stepAlerts.any(
      (a) => a.severity == RabiesAlertSeverity.critical,
    );
    if (step.isComplete(record)) return J0StepStatus.complete;
    if (hasCritical) return J0StepStatus.toReview;
    if (step.isStarted(record)) return J0StepStatus.inProgress;
    return J0StepStatus.notStarted;
  }

  // ── Layouts responsive ──────────────────────────────────────────────────

  Widget _buildDesktopLayout(
    RabiesCaseRecord computed,
    List<RabiesClinicalAlert> alerts,
    RabiesDecisionSummary summary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _buildStepView(computed, alerts, summary)),
        Container(
          width: 340,
          padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
          child: SingleChildScrollView(
            child: J0SummaryPanel(
              summary: summary,
              saving: _saving,
              onSaveDraft: _saveDraft,
              onValidate: _save,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    RabiesCaseRecord computed,
    List<RabiesClinicalAlert> alerts,
    RabiesDecisionSummary summary,
  ) {
    return _buildStepView(computed, alerts, summary);
  }

  Widget _buildStepView(
    RabiesCaseRecord computed,
    List<RabiesClinicalAlert> alerts,
    RabiesDecisionSummary summary,
  ) {
    final step = J0StepData.tous[_currentStep];
    final status = _stepStatusFor(_currentStep, computed, alerts);
    final stepAlerts = alerts
        .where((a) => step.sections.contains(a.section))
        .toList();
    final isLast = _currentStep == J0StepData.tous.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        _buildHero(computed, alerts.length),
        const SizedBox(height: 16),
        J0StepCard(
          step: step,
          index: _currentStep,
          total: J0StepData.tous.length,
          status: status,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _stepCards(_currentStep, computed),
          ),
        ),
        if (stepAlerts.isNotEmpty) ...[
          const SizedBox(height: 4),
          for (final alert in stepAlerts) J0AlertBanner(alert: alert),
        ],
        if (isLast) ...[
          const SizedBox(height: 12),
          ReviewSummaryCard(
            record: computed,
            summary: summary,
            steps: J0StepData.tous,
            statuses: [
              for (var i = 0; i < J0StepData.tous.length; i++)
                _stepStatusFor(i, computed, alerts),
            ],
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _stepCards(int index, RabiesCaseRecord record) {
    switch (J0StepData.tous[index].id) {
      case 'patient':
        return [_buildPatientCard(record)];
      case 'exposition':
        return [_buildExposureCard(record)];
      case 'classification':
        return [_buildClassificationCard(record)];
      case 'animal':
        return [_buildAnimalCard(record)];
      case 'priseEnCharge':
        return [
          _buildLocalCareCard(record),
          _buildErigCard(record),
          _buildSurgeryCard(record),
        ];
      case 'vaccination':
        return [_buildVaccinationCard(record)];
      case 'traitements':
        return [
          _buildAdjunctCard(record),
          _buildMpviCard(record),
          TraceabilityStatusStrip(record: record, onTap: _openTraceability),
        ];
      case 'validation':
        return [_buildOutcomeCard(record)];
      default:
        return const [];
    }
  }

  Widget _buildMobileSummaryStrip(RabiesDecisionSummary summary) {
    final crit = summary.alertesCritiques;
    return Container(
      width: double.infinity,
      color: EpidemiologyTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _miniChip(
              Icons.workspace_premium_outlined,
              summary.categorie.categorie.label,
              J0Ui.categoryColor(summary.categorie.categorie),
            ),
            const SizedBox(width: 8),
            _miniChip(
              Icons.shield_outlined,
              summary.ppe.indiquee ? 'PPE' : 'Pas de PPE',
              summary.ppe.indiquee
                  ? EpidemiologyTheme.redPrimary
                  : EpidemiologyTheme.warm400,
            ),
            const SizedBox(width: 8),
            _miniChip(
              Icons.bloodtype_outlined,
              summary.erig.indiquee
                  ? (summary.erig.administree ? 'ERIG OK' : 'ERIG à faire')
                  : 'Sans ERIG',
              summary.erig.indiquee
                  ? (summary.erig.administree
                      ? EpidemiologyTheme.success
                      : EpidemiologyTheme.warning)
                  : EpidemiologyTheme.warm400,
            ),
            if (summary.protocole != null) ...[
              const SizedBox(width: 8),
              _miniChip(
                Icons.vaccines_outlined,
                summary.protocole!.type.label,
                EpidemiologyTheme.redPrimary,
              ),
            ],
            if (crit > 0) ...[
              const SizedBox(width: 8),
              _miniChip(
                Icons.error_outline,
                '$crit critique(s)',
                EpidemiologyTheme.danger,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(RabiesCaseRecord record, int issues) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(24),
        boxShadow: EpidemiologyTheme.shadowHero,
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.patientNomComplet,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.numeroDossier} · ${record.categorie.label}',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          _severityPill(record.categorie, issues),
        ],
      ),
    );
  }

  Widget _severityPill(RabiesRiskCategory category, int issues) {
    final color = switch (category) {
      RabiesRiskCategory.categorieI => EpidemiologyTheme.teal,
      RabiesRiskCategory.categorieII => EpidemiologyTheme.warning,
      RabiesRiskCategory.categorieIII => EpidemiologyTheme.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            category.label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            issues == 0 ? 'Prêt' : '$issues point(s)',
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color == EpidemiologyTheme.warning
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(RabiesCaseRecord record) {
    final identity = record.identity;
    return DossierSectionCard(
      title: 'Patient · Admission',
      icon: Icons.person_outline,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        children: [
          _textField(
            label: 'Téléphone',
            controller: _telephoneController,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                identity: current.identity.copyWith(telephone: value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  label: 'Adresse',
                  controller: _adresseController,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      identity: current.identity.copyWith(
                        residence: current.identity.residence.copyWith(adresse: value),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  label: 'Commune',
                  controller: _communeController,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      identity: current.identity.copyWith(
                        residence: current.identity.residence.copyWith(commune: value),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  label: 'Daïra',
                  controller: _dairaController,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      identity: current.identity.copyWith(
                        residence: current.identity.residence.copyWith(daira: value),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  label: 'Wilaya',
                  controller: _wilayaController,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      identity: current.identity.copyWith(
                        residence: current.identity.residence.copyWith(wilaya: value),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  label: 'Heure arrivée UAR',
                  controller: _heureArriveeController,
                  hint: '08:30',
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      admission: current.admission.copyWith(heureArrivee: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _enumSelector<ArrivalMode>(
                  label: 'Mode arrivée',
                  value: record.admission.modeArrivee,
                  values: ArrivalMode.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      admission: current.admission.copyWith(modeArrivee: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (record.admission.modeArrivee == ArrivalMode.orienteParStructure) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'Structure d’orientation',
              controller: _orientationController,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  admission: current.admission.copyWith(structureOrientation: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _readOnlyInfo('Terrain particulier', identity.terrainParticulier ?? '—'),
        ],
      ),
    );
  }

  Widget _buildExposureCard(RabiesCaseRecord record) {
    final exposure = record.exposition;
    return DossierSectionCard(
      title: 'Exposition · Lésions',
      icon: Icons.coronavirus_outlined,
      accent: EpidemiologyTheme.warning,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _textField(
                  label: 'Heure exposition',
                  controller: _heureExposureController,
                  hint: '16:20',
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      exposition: current.exposition.copyWith(heureExposition: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _enumSelector<ExposurePlace>(
                  label: 'Lieu',
                  value: exposure.lieu,
                  values: ExposurePlace.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      exposition: current.exposition.copyWith(lieu: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _enumSelector<ExposureNature>(
            label: 'Nature de l’exposition',
            value: exposure.nature,
            values: ExposureNature.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                exposition: current.exposition.copyWith(nature: value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _enumSelector<BleedingStatus>(
                  label: 'Saignement',
                  value: exposure.saignement,
                  values: BleedingStatus.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      exposition: current.exposition.copyWith(saignement: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _enumSelector<LesionCountType>(
                  label: 'Nombre de lésions',
                  value: exposure.nombreLesions,
                  values: LesionCountType.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      exposition: current.exposition.copyWith(nombreLesions: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _chipMultiSelect<LesionSite>(
            label: 'Siège des lésions',
            values: LesionSite.values.where((site) => site != LesionSite.nonPrecise).toList(),
            selected: exposure.siegeLesions,
            itemLabel: (value) => value.label,
            onChanged: (selection) => _updateRecord(
              (current) => current.copyWith(
                exposition: current.exposition.copyWith(siegeLesions: selection),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationCard(RabiesCaseRecord record) {
    final category = record.classification.categorie;
    final color = switch (category) {
      RabiesRiskCategory.categorieI => EpidemiologyTheme.teal,
      RabiesRiskCategory.categorieII => EpidemiologyTheme.warning,
      RabiesRiskCategory.categorieIII => EpidemiologyTheme.danger,
    };
    return DossierSectionCard(
      title: 'Classification du risque',
      icon: Icons.local_fire_department_outlined,
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        category.description,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: EpidemiologyTheme.slate700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _chipMultiSelect<FamilyMeasure>(
            label: 'Mesures déjà faites avant l’UAR',
            values: FamilyMeasure.values,
            selected: record.classification.mesuresFamiliales,
            itemLabel: (value) => value.label,
            onChanged: (selection) => _updateRecord(
              (current) => current.copyWith(
                classification:
                    current.classification.copyWith(mesuresFamiliales: selection),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _textField(
            label: 'Justification clinique',
            controller: _justificationController,
            maxLines: 2,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                classification:
                    current.classification.copyWith(justification: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(RabiesCaseRecord record) {
    final animal = record.animal;
    return DossierSectionCard(
      title: 'Animal en cause',
      icon: Icons.pets_outlined,
      accent: EpidemiologyTheme.slate500,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _enumSelector<AnimalSpecies>(
                  label: 'Espèce',
                  value: animal.espece,
                  values: AnimalSpecies.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      animal: current.animal.copyWith(espece: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _enumSelector<AnimalStatus>(
                  label: 'Statut',
                  value: animal.statut,
                  values: AnimalStatus.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      animal: current.animal.copyWith(statut: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (animal.espece == AnimalSpecies.autre) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'Préciser espèce',
              controller: _animalAutreController,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  animal: current.animal.copyWith(autreEspecePrecision: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _textField(
                  label: 'Pelage',
                  controller: _pelageController,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      animal: current.animal.copyWith(couleurPelage: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _textField(
                  label: 'Propriétaire',
                  controller: _proprietaireController,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      animal: current.animal.copyWith(proprietaireNom: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _enumSelector<AnimalBehavior>(
                  label: 'Comportement',
                  value: animal.comportement,
                  values: AnimalBehavior.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      animal: current.animal.copyWith(comportement: value),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _enumSelector<ObservationStatus>(
                  label: 'Observation vétérinaire',
                  value: animal.observationVeterinaire,
                  values: ObservationStatus.values,
                  itemLabel: (value) => value.label,
                  onChanged: (value) => _updateRecord(
                    (current) => current.copyWith(
                      animal:
                          current.animal.copyWith(observationVeterinaire: value),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (animal.observationVeterinaire == ObservationStatus.oui) ...[
            const SizedBox(height: 12),
            _enumSelector<ObservationResult>(
              label: 'Résultat observation',
              value: animal.resultatObservation,
              values: ObservationResult.values,
              itemLabel: (value) => value.label,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  animal: current.animal.copyWith(resultatObservation: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _enumSelector<AnimalOutcome>(
            label: 'Sort de l’animal',
            value: animal.sort,
            values: AnimalOutcome.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                animal: current.animal.copyWith(sort: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalCareCard(RabiesCaseRecord record) {
    final care = record.soinsLocaux;
    return DossierSectionCard(
      title: 'Soins locaux',
      icon: Icons.clean_hands_outlined,
      accent: EpidemiologyTheme.teal,
      child: Column(
        children: [
          _enumSelector<LocalCarePerformed>(
            label: 'Soins locaux réalisés',
            value: care.realise,
            values: LocalCarePerformed.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                soinsLocaux: current.soinsLocaux.copyWith(realise: value),
              ),
            ),
          ),
          if (care.realise == LocalCarePerformed.oui) ...[
            const SizedBox(height: 12),
            _chipMultiSelect<LocalCareMethod>(
              label: 'Méthodes',
              values: LocalCareMethod.values,
              selected: care.methodes,
              itemLabel: (value) => value.label,
              onChanged: (selection) => _updateRecord(
                (current) => current.copyWith(
                  soinsLocaux: current.soinsLocaux.copyWith(methodes: selection),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _textField(
              label: 'Produits appliqués',
              controller: _produitsController,
              maxLines: 2,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  soinsLocaux:
                      current.soinsLocaux.copyWith(produitsAppliques: value),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErigCard(RabiesCaseRecord record) {
    final erig = record.erig;
    final indicated = record.classification.erigIndiquee;
    return DossierSectionCard(
      title: 'ERIG / Immunoglobulines',
      icon: Icons.science_outlined,
      accent: indicated ? EpidemiologyTheme.danger : EpidemiologyTheme.slate400,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: indicated
                  ? EpidemiologyTheme.dangerLight
                  : EpidemiologyTheme.slate100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              indicated
                  ? 'ERIG indiquée selon la catégorie ${record.categorie.label}'
                  : 'ERIG non indiquée sur la base des données actuelles',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: indicated
                    ? EpidemiologyTheme.danger
                    : EpidemiologyTheme.slate600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _yesNoCards(
            label: 'ERIG administrée',
            value: erig.administree,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                erig: current.erig.copyWith(
                  administree: value,
                  indiquee: indicated,
                ),
              ),
            ),
          ),
          if (erig.administree) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Lot ERIG',
                    controller: _erigLotController,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        erig: current.erig.copyWith(numeroLot: value),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    label: 'Titre UI/ml',
                    controller: _erigTitreController,
                    hint: '200',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        erig: current.erig.copyWith(
                          titreIUMl: double.tryParse(value),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Poids patient (kg)',
                    controller: _erigPoidsController,
                    hint: '61',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        erig: current.erig.copyWith(
                          poidsPatientKg: double.tryParse(value),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    label: 'Dose théorique (ml)',
                    controller: _erigDoseController,
                    hint: '6.1',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        erig: current.erig.copyWith(
                          doseTotaleTheoriqueMl: double.tryParse(value),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _yesNoCards(
              label: 'Dilution ERIG',
              value: erig.dilutionRealisee,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  erig: current.erig.copyWith(dilutionRealisee: value),
                ),
              ),
            ),
            if (erig.dilutionRealisee) ...[
              const SizedBox(height: 12),
              _textField(
                label: 'Sérum physiologique utilisé (ml)',
                controller: _erigSerumController,
                hint: '5',
                keyboardType: TextInputType.number,
                onChanged: (value) => _updateRecord(
                  (current) => current.copyWith(
                    erig: current.erig.copyWith(
                      quantiteSerumPhysiologiqueMl: double.tryParse(value),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _chipMultiSelect<ErigRoute>(
              label: 'Voies administration',
              values: ErigRoute.values,
              selected: erig.voies,
              itemLabel: (value) => value.label,
              onChanged: (selection) => _updateRecord(
                (current) => current.copyWith(
                  erig: current.erig.copyWith(voies: selection),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _yesNoCards(
              label: 'Réaction post ERIG',
              value: erig.reactionPostErig,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  erig: current.erig.copyWith(reactionPostErig: value),
                ),
              ),
            ),
            if (erig.reactionPostErig) ...[
              const SizedBox(height: 12),
              _textField(
                label: 'Mesures prises / réaction',
                controller: _erigReactionController,
                maxLines: 2,
                onChanged: (value) => _updateRecord(
                  (current) => current.copyWith(
                    erig: current.erig.copyWith(mesuresReaction: value),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSurgeryCard(RabiesCaseRecord record) {
    final surgery = record.chirurgie;
    return DossierSectionCard(
      title: 'Chirurgie · Suture',
      icon: Icons.healing_outlined,
      accent: EpidemiologyTheme.warning,
      child: Column(
        children: [
          _enumSelector<SurgeryPerformed>(
            label: 'Intervention chirurgicale',
            value: surgery.realise,
            values: SurgeryPerformed.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                chirurgie: current.chirurgie.copyWith(realise: value),
              ),
            ),
          ),
          if (surgery.realise == SurgeryPerformed.oui) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Hôpital',
                    controller: _chirurgieHopitalController,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        chirurgie: current.chirurgie.copyWith(hopital: value),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _textField(
                    label: 'Service',
                    controller: _chirurgieServiceController,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        chirurgie: current.chirurgie.copyWith(service: value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _enumSelector<SutureTiming>(
            label: 'Suture',
            value: surgery.suture,
            values: SutureTiming.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                chirurgie: current.chirurgie.copyWith(suture: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(RabiesCaseRecord record) {
    final vaccination = record.vaccination;
    final protocol = record.vaccination.protocole;
    return DossierSectionCard(
      title: 'Vaccination antirabique',
      icon: Icons.vaccines_outlined,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _enumSelector<RabiesVaccineType>(
            label: 'Type vaccin',
            value: vaccination.typeVaccin,
            values: RabiesVaccineType.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                vaccination: current.vaccination.copyWith(typeVaccin: value),
              ),
            ),
          ),
          if (vaccination.typeVaccin != RabiesVaccineType.non) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'DCI vaccin',
              controller: _vaccinDciController,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  vaccination: current.vaccination.copyWith(dci: value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _textField(
                    label: 'Lot vaccin',
                    controller: _vaccinLotController,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        vaccination:
                            current.vaccination.copyWith(numeroLot: value),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _enumSelector<AdministrationRoute>(
                    label: 'Voie',
                    value: vaccination.voie,
                    values: AdministrationRoute.values,
                    itemLabel: (value) => value.label,
                    onChanged: (value) => _updateRecord(
                      (current) => current.copyWith(
                        vaccination: current.vaccination.copyWith(voie: value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
Text(
                    'Protocole suggéré : ${protocol.type.label}',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: EpidemiologyTheme.slate900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Schéma : ${RabiesProtocolResolver.schema(protocol.type)}',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: EpidemiologyTheme.slate500,
                    ),
                  ),
            const SizedBox(height: 8),
            if (protocol.doses.isEmpty)
              Text(
                'Aucun protocole nécessaire pour cette catégorie.',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.slate500,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: protocol.doses.map((dose) {
                  final color = switch (dose.statut) {
                    DoseStatus.realisee => EpidemiologyTheme.teal,
                    DoseStatus.enRetard => EpidemiologyTheme.warning,
                    DoseStatus.manquee => EpidemiologyTheme.danger,
                    DoseStatus.prevue => EpidemiologyTheme.slate400,
                  };
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.18)),
                    ),
                    child: Text(
                      '${dose.jourTheorique} · ${ddMMyyyy(dose.datePrevue)}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdjunctCard(RabiesCaseRecord record) {
    return DossierSectionCard(
      title: 'Traitements associés · Traçabilité',
      icon: Icons.medical_services_outlined,
      accent: EpidemiologyTheme.teal,
      child: Column(
        children: [
          _enumSelector<AntibioticPrescription>(
            label: 'Antibiotiques',
            value: record.antibiotiques.prescription,
            values: AntibioticPrescription.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                antibiotiques: current.antibiotiques.copyWith(prescription: value),
              ),
            ),
          ),
          if (record.antibiotiques.prescription == AntibioticPrescription.oui) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'Molécule / protocole',
              controller: _antibiotiqueController,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  antibiotiques: current.antibiotiques.copyWith(molecule: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _yesNoCards(
            label: 'Autres traitements',
            value: record.autresTraitements.present,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                autresTraitements:
                    current.autresTraitements.copyWith(present: value),
              ),
            ),
          ),
          if (record.autresTraitements.present) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'Description autres traitements',
              controller: _autresTraitementsController,
              maxLines: 2,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  autresTraitements:
                      current.autresTraitements.copyWith(description: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _enumSelector<TetanusVaccinationStatus>(
            label: 'Vaccin DT / dT',
            value: record.vaccinationTetanos.statut,
            values: TetanusVaccinationStatus.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                vaccinationTetanos:
                    current.vaccinationTetanos.copyWith(statut: value),
              ),
            ),
          ),
          if (record.vaccinationTetanos.statut == TetanusVaccinationStatus.oui) ...[
            const SizedBox(height: 12),
            _enumSelector<TetanusVaccineType>(
              label: 'Type DT / dT',
              value: record.vaccinationTetanos.type,
              values: TetanusVaccineType.values,
              itemLabel: (value) => value.label,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  vaccinationTetanos:
                      current.vaccinationTetanos.copyWith(type: value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _textField(
              label: 'Observation DT/dT',
              controller: _tetanosObsController,
              maxLines: 2,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  vaccinationTetanos:
                      current.vaccinationTetanos.copyWith(observations: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _yesNoCards(
            label: 'Carte de vaccination remise',
            value: record.tracabilite.carteRemise,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                tracabilite: current.tracabilite.copyWith(
                  carteVaccination:
                      value ? TraceStatus.ouiAvecNumero : TraceStatus.non,
                ),
              ),
            ),
          ),
          if (record.tracabilite.carteRemise) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'Numéro carte',
              controller: _traceCarteController,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  tracabilite: current.tracabilite.copyWith(numeroCarte: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _yesNoCards(
            label: 'Patient inscrit au registre',
            value: record.tracabilite.patientRepertorie,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                tracabilite: current.tracabilite.copyWith(
                  registre: value ? TraceStatus.ouiAvecNumero : TraceStatus.non,
                ),
              ),
            ),
          ),
          if (record.tracabilite.patientRepertorie) ...[
            const SizedBox(height: 12),
            _textField(
              label: 'Numéro registre',
              controller: _traceRegistreController,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  tracabilite:
                      current.tracabilite.copyWith(numeroRegistre: value),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _textField(
            label: 'Résumé clinique / notes finales',
            controller: _notesFinalesController,
            maxLines: 3,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                evolution: current.evolution.copyWith(observations: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMpviCard(RabiesCaseRecord record) {
    final mpvi = record.mpvi;
    return DossierSectionCard(
      title: 'MPVI / Effets indésirables',
      icon: Icons.warning_amber_outlined,
      accent: mpvi.present ? EpidemiologyTheme.warning : EpidemiologyTheme.slate400,
      child: Column(
        children: [
          _yesNoCards(
            label: 'Manifestation post-vaccinale indésirable',
            value: mpvi.present,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                mpvi: current.mpvi.copyWith(present: value),
              ),
            ),
          ),
          if (mpvi.present) ...[
            const SizedBox(height: 12),
            _enumSelector<MpviSeverity>(
              label: 'Gravité',
              value: mpvi.gravite,
              values: MpviSeverity.values,
              itemLabel: (value) => value.label,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  mpvi: current.mpvi.copyWith(gravite: value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _textField(
              label: 'Manifestations',
              controller: _mpviManifestationsController,
              maxLines: 2,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  mpvi: current.mpvi.copyWith(manifestations: value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _textField(
              label: 'Mesures prises',
              controller: _mpviMesuresController,
              maxLines: 2,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  mpvi: current.mpvi.copyWith(mesuresPrises: value),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _yesNoCards(
              label: 'Déclaration pharmacovigilance',
              value: mpvi.declarationPharmacovigilance,
              onChanged: (value) => _updateRecord(
                (current) => current.copyWith(
                  mpvi: current.mpvi.copyWith(
                    declarationPharmacovigilance: value,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutcomeCard(RabiesCaseRecord record) {
    return DossierSectionCard(
      title: 'Évolution du dossier',
      icon: Icons.flag_outlined,
      accent: EpidemiologyTheme.slate500,
      child: Column(
        children: [
          _enumSelector<FinalCaseOutcome>(
            label: 'Statut dossier',
            value: record.evolution.resultat,
            values: FinalCaseOutcome.values,
            itemLabel: (value) => value.label,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                evolution: current.evolution.copyWith(resultat: value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _textField(
            label: 'Résumé clinique / notes finales',
            controller: _notesFinalesController,
            maxLines: 3,
            onChanged: (value) => _updateRecord(
              (current) => current.copyWith(
                evolution: current.evolution.copyWith(observations: value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.cairo(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: EpidemiologyTheme.slate900,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: EpidemiologyTheme.warm50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: EpidemiologyTheme.warm100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: EpidemiologyTheme.warm100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: EpidemiologyTheme.redPrimary, width: 1.5),
        ),
      ),
    );
  }

  Widget _readOnlyInfo(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.cairo(color: EpidemiologyTheme.slate700),
          children: [
            TextSpan(
              text: '$label : ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _yesNoCards({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.slate800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _booleanCard('Oui', value, () => onChanged(true))),
            const SizedBox(width: 10),
            Expanded(child: _booleanCard('Non', !value, () => onChanged(false))),
          ],
        ),
      ],
    );
  }

  Widget _booleanCard(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active
              ? EpidemiologyTheme.redPrimary.withValues(alpha: 0.08)
              : EpidemiologyTheme.warm50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? EpidemiologyTheme.redPrimary
                : EpidemiologyTheme.warm150,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active
                  ? EpidemiologyTheme.redPrimary
                  : EpidemiologyTheme.slate600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _enumSelector<T>({
    required String label,
    required T value,
    required List<T> values,
    required String Function(T value) itemLabel,
    required ValueChanged<T> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: EpidemiologyTheme.warm50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: EpidemiologyTheme.warm100),
        ),
      ),
      items: values
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue != null) onChanged(newValue);
      },
    );
  }

  Widget _chipMultiSelect<T>({
    required String label,
    required List<T> values,
    required List<T> selected,
    required String Function(T value) itemLabel,
    required ValueChanged<List<T>> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.slate800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((item) {
            final active = selected.contains(item);
            return FilterChip(
              selected: active,
              label: Text(itemLabel(item)),
              labelStyle: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active
                    ? EpidemiologyTheme.redPrimary
                    : EpidemiologyTheme.slate600,
              ),
              selectedColor: EpidemiologyTheme.redPrimary.withValues(alpha: 0.10),
              checkmarkColor: EpidemiologyTheme.redPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: active
                      ? EpidemiologyTheme.redPrimary
                      : EpidemiologyTheme.warm150,
                ),
              ),
              onSelected: (isSelected) {
                final next = [...selected];
                if (isSelected) {
                  next.add(item);
                } else {
                  next.remove(item);
                }
                onChanged(next);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
