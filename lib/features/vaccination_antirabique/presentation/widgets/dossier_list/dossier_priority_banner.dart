import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import 'dossier_list_models.dart';

/// Bannière « suivi requis aujourd'hui » : signale les doses attendues ce
/// jour ainsi que les protocoles en retard nécessitant une action rapide.
///
/// Présente les dossiers prioritaires (dose du jour puis retards) sous forme
/// de tuiles cliquables.
class DossierPriorityBanner extends StatelessWidget {
  final List<RabiesCaseRecord> dossiers;
  final ValueChanged<String> onOpenDossier;

  const DossierPriorityBanner({
    super.key,
    required this.dossiers,
    required this.onOpenDossier,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);

    final priorities = <RabiesCaseRecord>[
      ...dossiers.where((d) => dossierDueAujourdhui(d, now)),
      ...dossiers.where(
        (d) => dossierEnRetard(d, now) && !dossierDueAujourdhui(d, now),
      ),
    ];
    if (priorities.isEmpty) return const SizedBox.shrink();

    final due = priorities.where((d) => dossierDueAujourdhui(d, now)).length;
    final retards = priorities
        .where((d) => dossierEnRetard(d, now) && !dossierDueAujourdhui(d, now))
        .length;

    final title = due > 0
        ? '$due dossier${due > 1 ? 's' : ''} nécessite${due > 1 ? 'nt' : ''} un suivi aujourd\'hui'
        : '$retards dossier${retards > 1 ? 's' : ''} à suivre en priorité (retard)';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EpidemiologyTheme.danger.withValues(alpha: 0.08),
            EpidemiologyTheme.warning.withValues(alpha: 0.06),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EpidemiologyTheme.warning.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notification_important_outlined,
                  size: 18,
                  color: EpidemiologyTheme.danger,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.danger,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${priorities.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: priorities
                // Limite d'affichage pour ne pas saturer l'espace.
                .take(6)
                .map((d) => _pill(d))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _pill(RabiesCaseRecord d) {
    final due = dossierDueAujourdhui(d);
    final colour = due ? EpidemiologyTheme.danger : EpidemiologyTheme.warning;
    final label = due ? 'Suivi aujourd\'hui' : 'En retard';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onOpenDossier(d.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colour.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                due ? Icons.event_available : Icons.schedule,
                size: 14,
                color: colour,
              ),
              const SizedBox(width: 6),
              Text(
                d.patientNomComplet,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.slate800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: colour,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
