import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../widgets/act/tetanus_act_form_section.dart';
import '../widgets/act/tetanus_act_header_card.dart';
import '../widgets/act/tetanus_act_history_timeline.dart';
import '../widgets/act/tetanus_act_summary_card.dart';
import '../widgets/act/tetanus_act_traceability_card.dart';
import '../widgets/act/tetanus_act_type_selector.dart';
import '../widgets/tetanus_evaluation_section.dart';

/// Écran premium « Enregistrer un acte » pour un cas tétanique.
///
/// Sélection du type d'acte, formulaire dynamique, traçabilité complète
/// (date, heure, acteur, rôle, centre, validation), récapitulatif pré-validation
/// et sauvegarde via le repository. Responsive mobile / tablette / desktop.
class TetanusActFormScreen extends StatefulWidget {
  const TetanusActFormScreen({super.key, required this.patientId});

  final String patientId;

  @override
  State<TetanusActFormScreen> createState() => _TetanusActFormScreenState();
}

class _TetanusActFormScreenState extends State<TetanusActFormScreen> {
  final _repo = GetIt.instance<TetanusRepository>();

  TetanusPatientModel? _patient;

  // ── État du formulaire ────────────────────────────────────────────
  TetanusActType _type = TetanusActType.vaccination;
  String _vaccin = '';
  String _lot = '';
  String _expiration = '';
  String _voie = '';
  String _dose = '';
  String _zone = '';
  String _observations = '';

  String _date = '';
  String _heure = '';
  String _acteur = '';
  String _role = '';
  String _centre = '';
  bool _valide = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _patient = _repo.getPatientById(widget.patientId);
    _date = _today();
  }

  String _today() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  List<String> get _missing {
    final missing = <String>[];
    if (_date.trim().isEmpty) missing.add('Date');
    if (_acteur.trim().isEmpty) missing.add('Acteur');
    if (_role.trim().isEmpty) missing.add('Rôle');
    if (_centre.trim().isEmpty) missing.add('Centre');
    if (_type.requiresVaccin && _vaccin.trim().isEmpty) missing.add('Produit');
    if (_type.requiresLot) {
      if (_lot.trim().isEmpty) missing.add('Lot');
      if (_expiration.trim().isEmpty) missing.add('Expiration');
    }
    if (_type.requiresOrganisation) {
      if (_voie.trim().isEmpty) missing.add('Voie');
      if (_dose.trim().isEmpty) missing.add('Dose');
    }
    if (_type == TetanusActType.soinsLocaux && _zone.trim().isEmpty) {
      missing.add('Zone');
    }
    return missing;
  }

  bool get _ready => _missing.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_patient == null) {
      return Scaffold(
        backgroundColor: EpidemiologyTheme.warm50,
        body: const Center(child: Text('Patient introuvable')),
      );
    }
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: EpidemiologyTheme.warm700,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Enregistrer un acte',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.warm900,
          ),
        ),
        centerTitle: false,
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
          bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1),
        ),
      ),
      body: isWide ? _buildWide() : _buildNarrow(),
    );
  }

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
            child: TetanusActSummaryCard(
              type: _type,
              missing: _missing,
              submitting: _submitting,
              onSubmit: _save,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow() {
    return _buildScroll(showSummary: true);
  }

  Widget _buildScroll({required bool showSummary}) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        TetanusActHeaderCard(patient: _patient!),
        const SizedBox(height: 4),
        TetanusEvaluationSection(
          title: 'Type d\'acte',
          subtitle: 'Sélectionnez la nature de l\'acte à enregistrer',
          icon: Icons.category_outlined,
          accent: EpidemiologyTheme.redPrimary,
          child: TetanusActTypeSelector(
            selected: _type,
            onChanged: (t) => setState(() => _type = t),
          ),
        ),
        TetanusActFormSection(
          type: _type,
          vaccin: _vaccin,
          onVaccinChanged: (v) => setState(() => _vaccin = v),
          numeroLot: _lot,
          onNumeroLotChanged: (v) => setState(() => _lot = v),
          dateExpiration: _expiration,
          onDateExpirationChanged: (v) => setState(() => _expiration = v),
          voie: _voie,
          onVoieChanged: (v) => setState(() => _voie = v),
          dose: _dose,
          onDoseChanged: (v) => setState(() => _dose = v),
          zone: _zone,
          onZoneChanged: (v) => setState(() => _zone = v),
          observations: _observations,
          onObservationsChanged: (v) => setState(() => _observations = v),
        ),
        TetanusActTraceabilityCard(
          date: _date,
          heure: _heure,
          acteur: _acteur,
          role: _role,
          centre: _centre,
          valide: _valide,
          onDateChanged: (v) => setState(() => _date = v),
          onHeureChanged: (v) => setState(() => _heure = v),
          onActeurChanged: (v) => setState(() => _acteur = v),
          onRoleChanged: (v) => setState(() => _role = v),
          onCentreChanged: (v) => setState(() => _centre = v),
          onValideChanged: (v) => setState(() => _valide = v),
        ),
        TetanusEvaluationSection(
          title: 'Chronologie du dossier',
          subtitle: 'Actes déjà enregistrés pour ce patient',
          icon: Icons.history_rounded,
          accent: EpidemiologyTheme.warning,
          child: TetanusActHistoryTimeline(acts: _patient!.historique),
        ),
        if (showSummary) ...[
          const SizedBox(height: 4),
          TetanusActSummaryCard(
            type: _type,
            missing: _missing,
            submitting: _submitting,
            onSubmit: _save,
          ),
        ],
      ],
    );
  }

  void _save() {
    if (!_ready || _submitting) return;
    final p = _patient!;
    setState(() => _submitting = true);

    final acte = TetanusActeModel(
      id: 'ACT-${DateTime.now().millisecondsSinceEpoch}',
      patientId: p.id,
      dateActe: _date.trim(),
      typeActe: _type.label,
      type: _type,
      vaccin: _type.requiresVaccin && _vaccin.trim().isNotEmpty
          ? _vaccin.trim()
          : null,
      numeroLot: _type.requiresLot && _lot.trim().isNotEmpty
          ? _lot.trim()
          : null,
      dateExpiration: _type.requiresLot && _expiration.trim().isNotEmpty
          ? _expiration.trim()
          : null,
      administrateur: _acteur.trim().isNotEmpty ? _acteur.trim() : null,
      centre: _centre.trim().isNotEmpty ? _centre.trim() : null,
      observations: _observations.trim().isNotEmpty
          ? _observations.trim()
          : null,
      heureActe: _heure.trim().isNotEmpty ? _heure.trim() : null,
      voie: _type.requiresOrganisation && _voie.trim().isNotEmpty
          ? _voie.trim()
          : null,
      dose: _type.requiresOrganisation && _dose.trim().isNotEmpty
          ? _dose.trim()
          : null,
      zone: _zone.trim().isNotEmpty ? _zone.trim() : null,
      role: _role.trim().isNotEmpty ? _role.trim() : null,
      valide: _valide,
    );

    final ok = _repo.addAct(acte);
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Acte enregistré · ${_type.label}'
                : 'Échec de l\'enregistrement de l\'acte',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok
              ? EpidemiologyTheme.redPrimary
              : EpidemiologyTheme.danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      Navigator.of(context).pop(ok);
    });
  }
}
