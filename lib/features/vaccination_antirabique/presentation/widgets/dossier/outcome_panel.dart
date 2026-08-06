import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../domain/models/dossier/traceability.dart';
import '../rabies_dossier_widgets.dart';
import 'info_grid.dart';
import 'status_components.dart';

/// Panneau d'issue finale du dossier : résultat, clôture, MPVI, traçabilité.
class OutcomePanel extends StatelessWidget {
  final FinalOutcome evolution;
  final RabiesFollowUpSummary followUp;

  const OutcomePanel({super.key, required this.evolution, required this.followUp});

  Color _outcomeColor(FinalCaseOutcome r) => switch (r) {
    FinalCaseOutcome.vaccinationComplete => EpidemiologyTheme.success,
    FinalCaseOutcome.vaccinationIncomplete => EpidemiologyTheme.warning,
    FinalCaseOutcome.dossierEnCours => EpidemiologyTheme.info,
    FinalCaseOutcome.abandonne => EpidemiologyTheme.danger,
    FinalCaseOutcome.transfere => EpidemiologyTheme.indigo,
  };

  @override
  Widget build(BuildContext context) {
    final ev = evolution;
    final color = _outcomeColor(ev.resultat);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.flag_outlined, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Évolution du dossier',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
              ),
              StatusPill(label: ev.resultat.label, color: color, filled: ev.estClos),
            ],
          ),
          const SizedBox(height: 16),
          InfoGrid(
            items: [
              InfoTile(
                label: 'Résultat final',
                value: ev.resultat.label,
                valueColor: color,
                icon: Icons.flag,
              ),
              InfoTile(
                label: 'Date de clôture',
                value: ev.dateCloture != null ? ddMMyyyy(ev.dateCloture) : ev.estClos ? 'Non renseignée' : 'Dossier ouvert',
                icon: Icons.event,
              ),
              InfoTile(
                label: 'Protocole',
                value: followUp.protocoleStatut.label,
                icon: Icons.timeline,
              ),
              InfoTile(
                label: 'MPVI',
                value: followUp.mpviPresent ? 'Signalé (${followUp.mpviGravite.label})' : 'Aucun signalé',
                valueColor: followUp.mpviPresent ? EpidemiologyTheme.warning : EpidemiologyTheme.success,
                icon: Icons.warning_amber_rounded,
              ),
              InfoTile(
                label: 'Traçabilité',
                value: followUp.traceComplete
                    ? 'Carte + registre'
                    : followUp.traceCarteOk
                        ? 'Carte uniquement'
                        : followUp.traceRegistreOk
                            ? 'Registre uniquement'
                            : 'À renseigner',
                valueColor: followUp.traceComplete ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
                icon: Icons.receipt_long,
              ),
            ],
          ),
          if (ev.observations != null && ev.observations!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 16, color: EpidemiologyTheme.warm400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ev.observations!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: EpidemiologyTheme.slate600,
                      ),
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
}