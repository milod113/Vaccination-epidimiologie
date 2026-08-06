import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/epidemiology_theme.dart';
import '../../../../domain/models/dossier/rabies_case_record.dart';
import '../../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../clinical_status_pill.dart';
import '../follow_up_section_scaffold.dart';
import '../patient_outcome_card.dart';

/// Section « Évolution du patient ».
///
/// Badge d'état principal, carte de synthèse, chronologie du parcours
/// (J0 → protocole → clôture) et indicateurs de complétude.
class EvolutionFollowUpSection extends StatelessWidget {
  final RabiesCaseRecord record;
  final RabiesFollowUpSummary summary;

  const EvolutionFollowUpSection({
    super.key,
    required this.record,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final evolution = record.evolution;
    return FollowUpSectionScaffold(
      icon: Icons.flag_outlined,
      title: 'Évolution du patient',
      subtitle: 'Statut clinique et administratif du dossier',
      accent: EpidemiologyTheme.info,
      children: [
        PatientOutcomeCard(summary: summary, evolution: evolution),
        const SizedBox(height: 14),
        _timeline(),
        const SizedBox(height: 14),
        _completionRow(),
      ],
    );
  }

  Widget _timeline() {
    final steps = [
      _step(
        Icons.medical_information_outlined,
        'Évaluation J0',
        '${record.categorie.label} · ${record.classification.justification ?? 'Classification renseignée'}',
        completed: true,
      ),
      _step(
        Icons.vaccines,
        'Protocole vaccinal',
        summary.protocoleStatut.label,
        completed: summary.dosesRealisees > 0,
      ),
      _step(
        Icons.receipt_long_outlined,
        'Traçabilité',
        summary.traceComplete ? 'Carte + registre renseignés' : 'Carte / registre à compléter',
        completed: summary.traceComplete,
      ),
      _step(
        Icons.flag,
        'Clôture du dossier',
        summary.dossierClos ? 'Dossier clôturé le ${_fmt(record.evolution.dateCloture)}' : 'Dossier en cours',
        completed: summary.dossierClos,
        last: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chronologie du parcours',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.warm400,
          ),
        ),
        const SizedBox(height: 10),
        ...steps,
      ],
    );
  }

  Widget _step(IconData icon, String title, String subtitle, {required bool completed, bool last = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: completed
                        ? LinearGradient(
                            colors: [EpidemiologyTheme.success, EpidemiologyTheme.successDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: completed ? null : EpidemiologyTheme.warm150,
                    shape: BoxShape.circle,
                    border: Border.all(color: EpidemiologyTheme.white, width: 2),
                  ),
                  child: completed
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Icon(icon, size: 13, color: EpidemiologyTheme.slate400),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed ? EpidemiologyTheme.success.withValues(alpha: 0.4) : EpidemiologyTheme.warm150,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: EpidemiologyTheme.slate900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.slate600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _completionRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Indicateurs de complétude',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.warm400,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _indicator(
                'Protocole',
                summary.protocoleStatut == RabiesProtocolStatus.termine,
              ),
              _indicator('Traçabilité', summary.traceComplete),
              _indicator(
                'Animal statué',
                summary.animalConclusion != AnimalConclusion.indetermine,
              ),
              _indicator(
                'MPVI suivi',
                record.mpvi.present ? true : true,
              ),
              _indicator('Dossier clôturé', summary.dossierClos),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicator(String label, bool ok) {
    return ClinicalStatusPill(
      label: ok ? label : '$label à faire',
      icon: ok ? Icons.check_circle_outline : Icons.radio_button_unchecked,
      color: ok ? EpidemiologyTheme.success : EpidemiologyTheme.slate400,
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
