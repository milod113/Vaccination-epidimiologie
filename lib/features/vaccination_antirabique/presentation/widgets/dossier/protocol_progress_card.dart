import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../domain/models/dossier/vaccination.dart';
import '../rabies_dossier_widgets.dart';
import 'dose_timeline.dart';
import 'status_components.dart';

/// Carte « Protocole vaccinal » : progression, prochaine dose et timeline.
class ProtocolProgressCard extends StatelessWidget {
  final RabiesFollowUpSummary followUp;
  final VaccinationProtocol protocol;
  final VoidCallback? onOpenFollowUp;

  const ProtocolProgressCard({
    super.key,
    required this.followUp,
    required this.protocol,
    this.onOpenFollowUp,
  });

  @override
  Widget build(BuildContext context) {
    final pct = followUp.progressionPercent;
    final next = followUp.prochaineDose;
    final statusColor = switch (followUp.protocoleStatut) {
      RabiesProtocolStatus.termine => EpidemiologyTheme.success,
      RabiesProtocolStatus.enRetard => EpidemiologyTheme.danger,
      RabiesProtocolStatus.enCours => EpidemiologyTheme.info,
      RabiesProtocolStatus.sansProtocole => EpidemiologyTheme.slate400,
    };

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
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.vaccines_outlined, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protocole vaccinal',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                    Text(
                      '${protocol.type.label} · ${followUp.dosesRealisees}/${followUp.totalDoses} doses',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: followUp.protocoleStatut.label,
                color: statusColor,
                filled: followUp.protocoleStatut == RabiesProtocolStatus.enRetard,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      children: [
                        Container(color: EpidemiologyTheme.warm150),
                        FractionallySizedBox(
                          widthFactor: (pct / 100).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [statusColor, statusColor.withValues(alpha: 0.7)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$pct%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (onOpenFollowUp != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenFollowUp,
                icon: const Icon(Icons.timeline, size: 16),
                label: const Text('Ouvrir le suivi'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (next != null) _nextDoseCard(next),
          if (next != null) const SizedBox(height: 16),
          const Divider(color: EpidemiologyTheme.warm150, height: 1),
          const SizedBox(height: 14),
          DoseTimeline(doses: protocol.doses),
        ],
      ),
    );
  }

  Widget _nextDoseCard(VaccineDose next) {
    final overdue = next.statut == DoseStatus.enRetard;
    final accent = overdue ? EpidemiologyTheme.warning : EpidemiologyTheme.info;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.10), accent.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(overdue ? Icons.schedule : Icons.event_available, size: 20, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overdue ? 'Dose en retard' : 'Prochaine dose',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${next.etiquette} — ${next.datePrevue != null ? ddMMyyyy(next.datePrevue) : 'date non planifiée'}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}