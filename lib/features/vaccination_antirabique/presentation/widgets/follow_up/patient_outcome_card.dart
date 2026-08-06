import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../domain/models/dossier/traceability.dart';
import 'clinical_status_pill.dart';

/// Carte de synthèse de l'évolution clinique du patient.
///
/// Badge d'état principal, statut du dossier, indicateurs de complétude
/// (protocole, traçabilité) et observations finales.
class PatientOutcomeCard extends StatelessWidget {
  final RabiesFollowUpSummary summary;
  final FinalOutcome evolution;

  const PatientOutcomeCard({
    super.key,
    required this.summary,
    required this.evolution,
  });

  (Color, IconData) get _outcomeStyle => switch (summary.evolutionResultat) {
        FinalCaseOutcome.vaccinationComplete => (EpidemiologyTheme.success, Icons.verified_outlined),
        FinalCaseOutcome.vaccinationIncomplete => (EpidemiologyTheme.warning, Icons.warning_amber_rounded),
        FinalCaseOutcome.dossierEnCours => (EpidemiologyTheme.redPrimary, Icons.insights),
        FinalCaseOutcome.abandonne => (EpidemiologyTheme.danger, Icons.person_off_outlined),
        FinalCaseOutcome.transfere => (EpidemiologyTheme.info, Icons.swap_horiz),
      };

  Color get _statutColor => switch (summary.protocoleStatut) {
        RabiesProtocolStatus.termine => EpidemiologyTheme.success,
        RabiesProtocolStatus.enRetard => EpidemiologyTheme.danger,
        _ => EpidemiologyTheme.warning,
      };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _outcomeStyle;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.06), EpidemiologyTheme.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État principal',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                    Text(
                      summary.evolutionResultat.label,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              ClinicalStatusPill(
                label: summary.dossierClos ? 'Clôturé' : 'En cours',
                icon: summary.dossierClos ? Icons.lock_outline : Icons.timelapse,
                color: summary.dossierClos ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _metricRow(
            icon: Icons.vaccines,
            color: _statutColor,
            label: 'Protocole',
            value: summary.protocoleStatut.label,
          ),
          _metricRow(
            icon: Icons.receipt_long,
            color: summary.traceComplete ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
            label: 'Traçabilité',
            value: summary.traceComplete ? 'Carte + registre OK' : 'À compléter',
          ),
          _metricRow(
            icon: Icons.calendar_today,
            color: EpidemiologyTheme.slate500,
            label: 'Date de clôture',
            value: _fmt(evolution.dateCloture),
          ),
          if (evolution.observations != null && evolution.observations!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: EpidemiologyTheme.warm100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Observations finales',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: EpidemiologyTheme.warm400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    evolution.observations!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      color: EpidemiologyTheme.slate700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: EpidemiologyTheme.slate500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: color,
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