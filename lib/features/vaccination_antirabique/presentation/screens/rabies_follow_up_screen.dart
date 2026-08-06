import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/models/dossier/rabies_clinical_alert.dart';
import '../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../domain/models/dossier/dossier_enums.dart';
import '../../domain/models/dossier/vaccination.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../../domain/services/actor_context.dart';
import '../../domain/services/rabies_follow_up_service.dart';
import '../../domain/services/rabies_traceability_service.dart';
import '../widgets/follow_up/clinical_status_pill.dart';
import '../widgets/follow_up/follow_up_nav_bar.dart';
import '../widgets/follow_up/follow_up_summary_header.dart';
import '../widgets/follow_up/sections/animal_follow_up_section.dart';
import '../widgets/follow_up/sections/dose_follow_up_section.dart';
import '../widgets/follow_up/sections/evolution_follow_up_section.dart';
import '../widgets/follow_up/sections/mpvi_follow_up_section.dart';
import '../widgets/follow_up/sections/traceability_follow_up_section.dart';

/// Écran du parcours de suivi du dossier antirabique (post-J0).
///
/// Structure : en-tête sticky de synthèse globale, navigation segmentée entre
/// les sections (doses, réactions, évolution, traçabilité, animal) et contenu
/// de la section active. Les actions de suivi (valider/reporter/manquée)
/// passent par `RabiesFollowUpService` puis sont persistées via le dépôt.
class RabiesFollowUpScreen extends StatefulWidget {
  final String dossierId;

  const RabiesFollowUpScreen({super.key, required this.dossierId});

  @override
  State<RabiesFollowUpScreen> createState() => _RabiesFollowUpScreenState();
}

class _RabiesFollowUpScreenState extends State<RabiesFollowUpScreen> {
  RabiesCaseRecord? _dossier;
  RabiesFollowUpSummary? _summary;
  bool _loading = true;
  FollowUpSection _current = FollowUpSection.doses;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = di.sl<RabiesDossierRepository>();
    final dossier = await repo.getDossierById(widget.dossierId);
    setState(() {
      _dossier = dossier;
      _summary = dossier == null ? null : RabiesFollowUpService.summary(dossier);
      _loading = false;
    });
  }

  Future<void> _apply(Function(RabiesCaseRecord) mutation, String successMessage) async {
    final dossier = _dossier;
    if (dossier == null) return;
    final repo = di.sl<RabiesDossierRepository>();
    final updated = mutation(dossier);
    await repo.saveDossier(updated);
    if (!mounted) return;
    setState(() {
      _dossier = updated;
      _summary = RabiesFollowUpService.summary(updated);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Future<void> _validerDose(int numero) async {
    await _apply(
      (d) {
        final updated = RabiesFollowUpService.validerDose(d, numero);
        return RabiesTraceabilityService.ajouterEvenement(
          updated,
          typeAction: DossierHistoryActionType.doseAdministree,
          titre: 'Dose $numero validée',
          sectionConcernee: DossierSectionType.vaccination,
          acteur: ActorContext.acteurCourant,
          etapeValidee: ValidationStepType.doseAdministration,
          description: 'Dose administrée et confirmée.',
        );
      },
      'Dose ${_labelNumero(numero)} validée comme administrée.',
    );
  }

  Future<void> _reporterDose(int numero) async {
    final dossier = _dossier;
    if (dossier == null) return;
    final dose = dossier.vaccination.protocole.doses
        .where((d) => d.numero == numero)
        .toList();
    if (dose.isEmpty) return;
    final newDate = await _pickDate(
      initial: dose.first.datePrevue ?? DateTime.now(),
    );
    if (newDate == null) return;
    await _apply(
      (d) {
        final updated =
            RabiesFollowUpService.reporterDose(d, numero, nouvelleDate: newDate);
        return RabiesTraceabilityService.ajouterEvenement(
          updated,
          typeAction: DossierHistoryActionType.doseReportee,
          titre: 'Dose $numero reportée',
          sectionConcernee: DossierSectionType.vaccination,
          acteur: ActorContext.acteurCourant,
          etapeValidee: ValidationStepType.doseAdministration,
          nouvelleValeur: _fmtDate(newDate),
        );
      },
      'Dose $numero reportée.',
    );
  }

  Future<void> _marquerManquee(int numero) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text('Marquer la dose comme manquée'),
        content: const Text(
          'Confirmez-vous que cette dose ne sera pas administrée '
          '(perdue de vue, refus, contre-indication) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: EpidemiologyTheme.danger,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _apply(
      (d) {
        final updated = RabiesFollowUpService.marquerDoseManquee(d, numero);
        return RabiesTraceabilityService.ajouterEvenement(
          updated,
          typeAction: DossierHistoryActionType.doseManquee,
          titre: 'Dose $numero marquée manquée',
          sectionConcernee: DossierSectionType.vaccination,
          acteur: ActorContext.acteurCourant,
          etapeValidee: ValidationStepType.doseAdministration,
          statut: ValidationStatus.validee,
        );
      },
      'Dose $numero marquée manquée.',
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  Future<DateTime?> _pickDate({required DateTime initial}) async {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 120)),
    );
  }

  void _showDoseDetails(VaccineDose dose) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DoseDetailsSheet(dose: dose),
    );
  }

  String _labelNumero(int numero) {
    // Le numéro correspond au rang affiché ; on renvoie simplement le numéro.
    return numero.toString();
  }

  @override
  Widget build(BuildContext context) {
    final dossier = _dossier;
    final summary = _summary;

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        backgroundColor: EpidemiologyTheme.warm50,
        elevation: 0,
        title: Text(
          'Suivi du dossier',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.slate900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: EpidemiologyTheme.slate900,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
      body: _loading || dossier == null || summary == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                FollowUpSummaryHeader(record: dossier, summary: summary),
                FollowUpNavBar(
                  current: _current,
                  onChanged: (s) => setState(() => _current = s),
                  badgeCounts: _badgeCounts(),
                ),
                Expanded(
                  child: _sectionFor(dossier, summary),
                ),
              ],
            ),
    );
  }

  Map<FollowUpSection, int> _badgeCounts() {
    final alerts = _summary?.alertes ?? const [];
    return {
      FollowUpSection.doses: alerts
          .where((a) =>
              a.category == RabiesAlertCategory.protocole ||
              a.category == RabiesAlertCategory.retard ||
              a.category == RabiesAlertCategory.suivi)
          .length,
      FollowUpSection.reactions: alerts
          .where((a) => a.id.contains('MPVI'))
          .length,
    };
  }

  Widget _sectionFor(RabiesCaseRecord dossier, RabiesFollowUpSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (_current) {
          FollowUpSection.doses => DoseFollowUpSection(
              key: const ValueKey('doses'),
              record: dossier,
              summary: summary,
              onValiderDose: _validerDose,
              onReporterDose: _reporterDose,
              onMarquerManquee: _marquerManquee,
              onDoseDetails: _showDoseDetails,
            ),
          FollowUpSection.reactions => MpviFollowUpSection(
              key: const ValueKey('mpvi'),
              record: dossier,
              summary: summary,
            ),
          FollowUpSection.evolution => EvolutionFollowUpSection(
              key: const ValueKey('evolution'),
              record: dossier,
              summary: summary,
            ),
          FollowUpSection.tracabilite => TraceabilityFollowUpSection(
              key: const ValueKey('tracabilite'),
              record: dossier,
              summary: summary,
            ),
          FollowUpSection.animal => AnimalFollowUpSection(
              key: const ValueKey('animal'),
              record: dossier,
              summary: summary,
            ),
        },
      ),
    );
  }
}

/// Feuille de détail d'une dose (voie, lot, notes, dates).
class _DoseDetailsSheet extends StatelessWidget {
  final VaccineDose dose;

  const _DoseDetailsSheet({required this.dose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: EpidemiologyTheme.primaryGradientWarm,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.vaccines, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.etiquette,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                    Text(
                      dose.statut.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: dose.statut.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _row('Jour théorique', dose.jourTheorique),
          _row('Date prévue', _fmt(dose.datePrevue)),
          _row('Date administrée', _fmt(dose.dateReelle)),
          _row('Voie d\'administration', dose.voie.label),
          _row('N° de lot', dose.numeroLot),
          _row('Statut', dose.statut.label),
          if (dose.notes != null) _row('Notes', dose.notes!),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Fermer'),
            style: FilledButton.styleFrom(
              backgroundColor: EpidemiologyTheme.redPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: EpidemiologyTheme.slate500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? '—' : value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}