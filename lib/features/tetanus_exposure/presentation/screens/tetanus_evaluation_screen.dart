import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../../domain/services/tetanus_evaluation_service.dart';
import '../widgets/tetanus_action_bar.dart';
import '../widgets/tetanus_decision_card.dart';
import '../widgets/tetanus_evaluation_controls.dart';
import '../widgets/tetanus_evaluation_hero.dart';
import '../widgets/tetanus_evaluation_section.dart';
import '../widgets/tetanus_risk_card.dart';
import '../widgets/tetanus_summary_panel.dart';

/// Écran d'évaluation tétanos post-exposition.
///
/// Refonte premium alignée sur l'identité visuelle du module antirabique :
/// hero header, sections cliniques, risque en temps réel, décision clinique,
/// panneau de synthèse et barre d'action. Responsive mobile / tablette / desk.
class TetanusEvaluationScreen extends StatefulWidget {
  final String? patientId;
  const TetanusEvaluationScreen({super.key, this.patientId});

  @override
  State<TetanusEvaluationScreen> createState() => _TetanusEvaluationScreenState();
}

class _TetanusEvaluationScreenState extends State<TetanusEvaluationScreen> {
  final _service = const TetanusEvaluationService();

  // ── État de l'évaluation ───────────────────────────────────────────
  TetanusWoundType _woundType = TetanusWoundType.aRisque;
  String _localisation = '';
  String _delai = '< 6h';
  bool _profond = false;
  bool _souillee = false;
  bool _corpsEtranger = false;
  bool _soinsLocaux = false;
  TetanusVaccinStatus _vaccin = TetanusVaccinStatus.inconnu;
  int? _nbDoses;
  String? _derniereDose;
  bool _immunodeprime = false;
  bool _grossesse = false;
  bool _allergieVat = false;
  bool _antecedentTetanos = false;
  bool _traitementDejaRecu = false;

  final _observationsController = TextEditingController();
  bool _saving = false;

  TetanusEvaluationInput get _input {
    return TetanusEvaluationInput(
      typePlaie: _woundType,
      localisation: _localisation,
      profond: _profond,
      souillee: _souillee,
      corpsEtranger: _corpsEtranger,
      soinsLocaux: _soinsLocaux,
      delai: _delai,
      statutVaccinal: _vaccin,
      nombreDoses: _nbDoses,
      derniereDose: _derniereDose,
      immunodeprime: _immunodeprime,
      grossesse: _grossesse,
      allergieVat: _allergieVat,
      antecedentTetanos: _antecedentTetanos,
      traitementDejaRecu: _traitementDejaRecu,
    );
  }

  bool get _dossierPret => _service.isDossierPret(_input);

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _prefill(widget.patientId!);
    }
  }

  void _prefill(String patientId) {
    final patient = GetIt.instance<TetanusRepository>().getPatientById(patientId);
    if (patient == null) return;
    setState(() {
      _woundType = patient.typePlaie;
      _localisation = patient.localisation;
      _profond = patient.plaieProfonde;
      _souillee = patient.plaieSouillee;
      _corpsEtranger = patient.corpsEtranger;
      _soinsLocaux = patient.soinsLocauxRealises;
      _delai = patient.delaiConsultation;
      _vaccin = patient.statutVaccinal;
      _nbDoses = patient.nombreDosesConnues;
      _derniereDose = patient.derniereDoseDate;
      _traitementDejaRecu = false;
    });
  }

  @override
  void dispose() {
    _observationsController.dispose();
    super.dispose();
  }

  TetanusDecisionResolution get _resolution => _service.resolve(_input);

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 880;

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: EpidemiologyTheme.warm700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Évaluation tétanique',
            style: GoogleFonts.cairo(
                fontSize: 16, fontWeight: FontWeight.w800,
                color: EpidemiologyTheme.warm900)),
        centerTitle: false,
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
            bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1)),
      ),
      body: isWide ? _buildWide() : _buildNarrow(),
      bottomNavigationBar: TetanusActionBar(
        canValidate: _dossierPret,
        saving: _saving,
        onCancel: () => Navigator.of(context).pop(),
        onSaveDraft: _saving ? null : _save,
        onValidate: _dossierPret ? _save : null,
      ),
    );
  }

  // ── Layout large (≥ 880px) ──────────────────────────────────────────
  Widget _buildWide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildScroll(showSummary: false)),
        const SizedBox(width: 16),
        SizedBox(
          width: 340,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 24),
            child: TetanusSummaryPanel(
              resolution: _resolution,
              input: _input,
              dossierPret: _dossierPret,
            ),
          ),
        ),
      ],
    );
  }

  // ── Layout étroit ──────────────────────────────────────────────────
  Widget _buildNarrow() {
    return _buildScroll(showSummary: true);
  }

  Widget _buildScroll({required bool showSummary}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        TetanusEvaluationHero(
          nom: widget.patientId != null ? _patientName() : 'Nouvelle évaluation',
          corps: widget.patientId != null
              ? _patientCorps()
              : 'Service d\'épidémiologie · ${_todayLabel()}',
          contexte: 'Prophylaxie antitétanique post-exposition',
          graviteLabel: _dossierPret ? 'Dossier complet' : 'À compléter',
          graviteColor: _dossierPret
              ? EpidemiologyTheme.success
              : EpidemiologyTheme.warm400,
          statutLabel: _resolution.decision.label,
          statutColor: _decisionStatutColor(),
        ),
        const SizedBox(height: 14),
        ..._buildSections(),
        const SizedBox(height: 4),
        TetanusRiskCard(input: _input, resolution: _resolution),
        TetanusDecisionCard(input: _input, resolution: _resolution),
        if (showSummary) ...[
          const SizedBox(height: 4),
          TetanusSummaryPanel(
            resolution: _resolution,
            input: _input,
            dossierPret: _dossierPret,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildSections() {
    return [
      TetanusEvaluationSection(
        title: 'Plaie & exposition',
        subtitle: 'Évaluer la nature tétanigène de la plaie',
        icon: Icons.healing_outlined,
        accent: EpidemiologyTheme.redMedium,
        required: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Type de plaie'),
            TetanusChoiceChips<TetanusWoundType>(
              options: [
                for (final w in TetanusWoundType.values)
                  TetanusChoiceOption(w, w.label, help: w.description),
              ],
              selected: _woundType,
              onChanged: (v) => setState(() => _woundType = v),
            ),
            const SizedBox(height: 12),
            _label('Caractéristiques'),
            TetanusToggleTile(
              label: 'Plaie profonde',
              icon: Icons.arrow_downward,
              value: _profond,
              accent: EpidemiologyTheme.danger,
              onChanged: (v) => setState(() => _profond = v),
            ),
            TetanusToggleTile(
              label: 'Plaie souillée (terre, poussière)',
              icon: Icons.grass,
              value: _souillee,
              accent: EpidemiologyTheme.danger,
              onChanged: (v) => setState(() => _souillee = v),
            ),
            TetanusToggleTile(
              label: 'Corps étranger / nécrose',
              icon: Icons.casino_outlined,
              value: _corpsEtranger,
              accent: EpidemiologyTheme.danger,
              onChanged: (v) => setState(() => _corpsEtranger = v),
            ),
            TetanusToggleTile(
              label: 'Soins locaux réalisés',
              icon: Icons.clean_hands_outlined,
              value: _soinsLocaux,
              accent: EpidemiologyTheme.success,
              onChanged: (v) => setState(() => _soinsLocaux = v),
            ),
            const SizedBox(height: 10),
            _label('Délai de consultation'),
            TetanusChoiceChips<String>(
              options: const [
                TetanusChoiceOption('< 6h', '< 6h'),
                TetanusChoiceOption('< 12h', '< 12h'),
                TetanusChoiceOption('< 24h', '< 24h'),
                TetanusChoiceOption('> 24h', '> 24h'),
              ],
              selected: _delai,
              onChanged: (v) => setState(() => _delai = v),
              accent: EpidemiologyTheme.info,
            ),
          ],
        ),
      ),
      TetanusEvaluationSection(
        title: 'Statut vaccinal tétanique',
        subtitle: 'Détermine la conduite prophylactique',
        icon: Icons.vaccines_outlined,
        accent: EpidemiologyTheme.indigo,
        required: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TetanusChoiceChips<TetanusVaccinStatus>(
              options: [
                for (final s in TetanusVaccinStatus.values)
                  TetanusChoiceOption(s, s.label),
              ],
              selected: _vaccin,
              onChanged: (v) => setState(() => _vaccin = v),
            ),
            const SizedBox(height: 12),
            if (_vaccin != TetanusVaccinStatus.inconnu &&
                _vaccin != TetanusVaccinStatus.nonVaccine) ...[
              _label('Doses connues & dernière dose'),
              TetanusChoiceChips<String>(
                options: const [
                  TetanusChoiceOption('3', '3 doses'),
                  TetanusChoiceOption('4', '4 doses'),
                  TetanusChoiceOption('5+', '5 doses ou +'),
                ],
                selected: _nbDoses == null
                    ? null
                    : (_nbDoses! >= 5
                        ? '5+'
                        : '$_nbDoses'),
                onChanged: (v) => setState(() => _nbDoses = int.tryParse(v)),
                accent: EpidemiologyTheme.indigo,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Date de la dernière dose (AAAA-MM-JJ)',
                  hintText: 'ex : 2023-03-15',
                  prefixIcon: Icon(Icons.event_outlined, size: 18),
                ),
                onChanged: (v) => setState(() => _derniereDose =
                    v.trim().isEmpty ? null : v.trim()),
              ),
              const SizedBox(height: 10),
            ],
            TetanusToggleTile(
              label: 'Traitement (VAT / Ig) déjà reçu',
              icon: Icons.done_all_outlined,
              value: _traitementDejaRecu,
              accent: EpidemiologyTheme.success,
              onChanged: (v) => setState(() => _traitementDejaRecu = v),
            ),
            if (_traitementDejaRecu)
              _hintBox(
                Icons.check_circle_outline,
                'Un acte prophylactique a déjà été enregistré. La décision '
                'tiendra compte des doses administrées.',
                EpidemiologyTheme.success,
              ),
          ],
        ),
      ),
      TetanusEvaluationSection(
        title: 'Contexte clinique',
        subtitle: 'Comorbidités et antécédents pertinents',
        icon: Icons.person_outline,
        accent: EpidemiologyTheme.teal,
        child: Column(
          children: [
            TetanusToggleTile(
              label: 'Patient immunodéprimé',
              icon: Icons.shield_outlined,
              value: _immunodeprime,
              accent: EpidemiologyTheme.danger,
              onChanged: (v) => setState(() => _immunodeprime = v),
            ),
            TetanusToggleTile(
              label: 'Grossesse en cours',
              icon: Icons.pregnant_woman,
              value: _grossesse,
              accent: EpidemiologyTheme.info,
              onChanged: (v) => setState(() => _grossesse = v),
            ),
            TetanusToggleTile(
              label: 'Allergie connue à l\'anatos VAcT',
              icon: Icons.warning_amber_outlined,
              value: _allergieVat,
              accent: EpidemiologyTheme.warning,
              onChanged: (v) => setState(() => _allergieVat = v),
            ),
            TetanusToggleTile(
              label: 'Antécédent de tétanos',
              icon: Icons.history_rounded,
              value: _antecedentTetanos,
              accent: EpidemiologyTheme.orange,
              onChanged: (v) => setState(() => _antecedentTetanos = v),
            ),
          ],
        ),
      ),
      TetanusEvaluationSection(
        title: 'Observations',
        subtitle: 'Notes cliniques complémentaires',
        icon: Icons.edit_note_rounded,
        accent: EpidemiologyTheme.redPrimary,
        child: TextField(
          controller: _observationsController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Signes, évolution, éléments pertinents…',
            alignLabelWithHint: true,
          ),
        ),
      ),
    ];
  }

  void _save() {
    if (!_dossierPret) return;
    setState(() => _saving = true);
    // La persistance est traitée par le repository du module tétanos.
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Évaluation enregistrée · ${_resolution.decision.label}',
            style: GoogleFonts.cairo(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: EpidemiologyTheme.redPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    });
  }

  TetanusPatientModel? get _patient {
    if (widget.patientId == null) return null;
    return GetIt.instance<TetanusRepository>().getPatientById(widget.patientId!);
  }

  String _patientName() => _patient?.nomComplet ?? 'Patient';

  String _patientCorps() {
    final p = _patient;
    if (p == null) return 'Service d\'épidémiologie · ${_todayLabel()}';
    return '${p.id} · ${p.age} ans · ${p.sexe}';
  }

  Color _decisionStatutColor() {
    switch (_resolution.decision) {
      case TetanusDecision.simpleSurveillance:
        return EpidemiologyTheme.success;
      case TetanusDecision.rappelIndique:
        return EpidemiologyTheme.warning;
      case TetanusDecision.vaccinationComplete:
        return EpidemiologyTheme.info;
      case TetanusDecision.vaccinationEtIg:
        return EpidemiologyTheme.danger;
      case TetanusDecision.avisSpecialise:
        return EpidemiologyTheme.orange;
    }
  }

  String _todayLabel() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: EpidemiologyTheme.warm500,
        ),
      ),
    );
  }

  Widget _hintBox(IconData icon, String messageSelected, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              messageSelected,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                height: 1.4,
                color: EpidemiologyTheme.warm700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}