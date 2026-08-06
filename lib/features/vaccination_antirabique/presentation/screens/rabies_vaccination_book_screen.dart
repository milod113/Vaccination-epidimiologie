import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/evaluation_initiale_model.dart';
import '../../data/models/patient_antirabique_model.dart';
import '../../data/models/protocole_vaccinal_model.dart';
import '../../domain/repositories/evaluation_initiale_repository.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../../domain/repositories/protocole_repository.dart';
import '../widgets/rabies_book/activity_log_card.dart';
import '../widgets/rabies_book/clinical_synthesis_card.dart';
import '../widgets/rabies_book/next_dose_card.dart';
import '../widgets/rabies_book/protocol_summary_card.dart';
import '../widgets/rabies_book/rabies_book_alert_banner.dart';
import '../widgets/rabies_book/rabies_dose_timeline.dart';
import '../widgets/rabies_book/rabies_vaccination_book_header.dart';
import '../widgets/rabies_book/traceability_summary_card.dart';
import '../widgets/rabies_book/vaccination_progress_card.dart';

/// Vue « carnet vaccinal antirabique » (contenu réutilisable).
///
/// Charté en carte premium : header hero, alertes, prochaine dose,
/// progression, protocole, timeline des doses, synthèse clinique,
/// traçabilité et historique. Responsive (colonnes sur grand écran).
class RabiesVaccinationBookView extends StatefulWidget {
  final String patientId;

  const RabiesVaccinationBookView({super.key, required this.patientId});

  @override
  State<RabiesVaccinationBookView> createState() =>
      _RabiesVaccinationBookViewState();
}

class _RabiesVaccinationBookViewState extends State<RabiesVaccinationBookView> {
  bool _loading = true;
  PatientAntirabiqueModel? _patient;
  ProtocoleVaccinalModel? _protocol;
  InitialRabiesAssessment? _evaluation;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      di.sl<PatientAntirabiqueRepository>().getPatientById(widget.patientId),
      di.sl<ProtocoleRepository>().getProtocole(widget.patientId),
      di.sl<EvaluationInitialeRepository>().getEvaluation(widget.patientId),
    ]);
    if (!mounted) return;
    setState(() {
      _patient = results[0] as PatientAntirabiqueModel?;
      _protocol = results[1] as ProtocoleVaccinalModel?;
      _evaluation = results[2] as InitialRabiesAssessment?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _skeleton();
    final patient = _patient;
    if (patient == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_rounded, size: 40, color: EpidemiologyTheme.warm300),
              const SizedBox(height: 10),
              Text('Patient introuvable', style: EpidemiologyTheme.body()),
            ],
          ),
        ),
      );
    }

    final protocol = _protocol;
    final evaluation = _evaluation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final content = <Widget>[
          RabiesVaccinationBookHeader(patient: patient, protocol: protocol),
          const SizedBox(height: 16),
          _buildAlerts(),
          const SizedBox(height: 16),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: _leftColumn(protocol, evaluation),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 6,
                  child: _rightColumn(patient, protocol, evaluation),
                ),
              ],
            )
          else
            _singleColumn(patient, protocol, evaluation),
        ];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Carnet vaccinal', Icons.menu_book_rounded),
            const SizedBox(height: 12),
            ...content,
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _sectionTitle(String t, IconData i) => Text(
        t,
        style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800),
      );

  Widget _leftColumn(ProtocoleVaccinalModel? p, InitialRabiesAssessment? e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockTitle('Prochaine dose'),
        NextDoseCard(protocol: p),
        const SizedBox(height: 20),
        _blockTitle('Progression'),
        VaccinationProgressCard(protocol: p),
        if (p != null) ...[
          const SizedBox(height: 20),
          _blockTitle('Protocole'),
          ProtocolSummaryCard(protocol: p, evaluation: e),
        ],
        if (e != null) ...[
          const SizedBox(height: 20),
          _blockTitle('Traçabilité'),
          TraceabilitySummaryCard(evaluation: e, protocol: p),
        ],
      ],
    );
  }

  Widget _rightColumn(
    PatientAntirabiqueModel patient,
    ProtocoleVaccinalModel? p,
    InitialRabiesAssessment? e,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockTitle('Timeline vaccinale'),
        RabiesDoseTimeline(
          doses: p?.doses ?? const [],
          nextDoseId: p?.prochaineDoseUrgente?.id ?? p?.prochaineDose?.id,
        ),
        const SizedBox(height: 20),
        _blockTitle('Synthèse clinique'),
        ClinicalSynthesisCard(patient: patient, protocol: p, evaluation: e),
        const SizedBox(height: 20),
        _blockTitle('Activité récente'),
        ActivityLogCard(patient: patient, protocol: p, evaluation: e),
      ],
    );
  }

  Widget _singleColumn(
    PatientAntirabiqueModel patient,
    ProtocoleVaccinalModel? p,
    InitialRabiesAssessment? e,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _blockTitle('Prochaine dose'),
        NextDoseCard(protocol: p),
        const SizedBox(height: 20),
        _blockTitle('Progression du protocole'),
        VaccinationProgressCard(protocol: p),
        if (p != null) ...[
          const SizedBox(height: 20),
          _blockTitle('Protocole'),
          ProtocolSummaryCard(protocol: p, evaluation: e),
        ],
        const SizedBox(height: 20),
        _blockTitle('Timeline vaccinale'),
        RabiesDoseTimeline(
          doses: p?.doses ?? const [],
          nextDoseId: p?.prochaineDoseUrgente?.id ?? p?.prochaineDose?.id,
        ),
        const SizedBox(height: 20),
        _blockTitle('Synthèse clinique'),
        ClinicalSynthesisCard(patient: patient, protocol: p, evaluation: e),
        const SizedBox(height: 20),
        _blockTitle('Traçabilité vaccinale'),
        TraceabilitySummaryCard(evaluation: e, protocol: p),
        const SizedBox(height: 20),
        _blockTitle('Activité récente'),
        ActivityLogCard(patient: patient, protocol: p, evaluation: e),
      ],
    );
  }

  Widget _blockTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          text,
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm500, letterSpacing: 0.2),
        ),
      );

  Widget _buildAlerts() {
    final alerts = <Widget>[];
    final p = _protocol;
    final patient = _patient;

    if (p == null) {
      alerts.add(RabiesBookAlertBanner(
        icon: Icons.assignment_late_outlined,
        title: 'Évaluation initiale requise',
        message: "La fiche J0 n'a pas été réalisée. Catégorie et protocole non définis.",
        color: EpidemiologyTheme.warning,
      ));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final a in alerts) Padding(padding: const EdgeInsets.only(bottom: 8), child: a)],
      );
    }

    if (p.dosesEnRetard.isNotEmpty) {
      alerts.add(RabiesBookAlertBanner(
        icon: Icons.warning_amber_rounded,
        title: '${p.dosesEnRetard.length} dose(s) en retard',
        message: 'Prenez rendez-vous en urgence pour administrer les doses manquées.',
        color: EpidemiologyTheme.danger,
      ));
    }
    if (p.aDoseAujourdhui) {
      alerts.add(RabiesBookAlertBanner(
        icon: Icons.notifications_active_rounded,
        title: "Dose prévue aujourd'hui",
        message: '${p.dosesAujourdhui.map((d) => d.jourTheorique).join(', ')} — le patient doit se présenter au centre.',
        color: EpidemiologyTheme.warning,
      ));
    }
    if (patient?.statut == StatutSuivi.perduDeVue) {
      alerts.add(RabiesBookAlertBanner(
        icon: Icons.person_off_rounded,
        title: 'Patient perdu de vue',
        message: 'Suivi à reprendre : le patient ne se présente plus depuis plusieurs visites.',
        color: EpidemiologyTheme.danger,
      ));
    }
    if (p.rigIndiquee && !p.rigAdministree) {
      alerts.add(RabiesBookAlertBanner(
        icon: Icons.science_rounded,
        title: 'ERIG indiquée, non administrée',
        message: 'Les immunoglobulines antirabiques sont indiquées (catégorie III) mais non administrées à ce jour.',
        color: EpidemiologyTheme.warning,
      ));
    }

    final e = _evaluation;
    if (e != null && p.dosesAdministrees > 0 && !(e.carteRemise && e.inscritRegistre)) {
      alerts.add(RabiesBookAlertBanner(
        icon: Icons.verified_user_outlined,
        title: 'Traçabilité à compléter',
        message: 'Des doses ont été administrées mais la carte et/ou le registre ne sont pas renseignés.',
        color: EpidemiologyTheme.info,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final a in alerts) Padding(padding: const EdgeInsets.only(bottom: 8), child: a)],
    );
  }

  Widget _skeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: EpidemiologyTheme.primaryGradientWarm,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: 20),
        EpidemiologyTheme.shimmerBox(width: double.infinity, height: 90),
        const SizedBox(height: 12),
        EpidemiologyTheme.shimmerBox(width: double.infinity, height: 70),
        const SizedBox(height: 12),
        EpidemiologyTheme.shimmerBox(width: double.infinity, height: 200),
      ],
    );
  }
}

/// Écran dédié au carnet vaccinal antirabique (plein écran).
class RabiesVaccinationBookScreen extends StatelessWidget {
  final String patientId;

  const RabiesVaccinationBookScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        backgroundColor: EpidemiologyTheme.redPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Carnet vaccinal antirabique',
          style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: EpidemiologyTheme.surfaceGradient),
        child: RabiesVaccinationBookView(patientId: patientId),
      ),
    );
  }
}