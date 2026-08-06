import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_history.dart';
import 'actor_badge.dart';
import 'traceability_ui.dart';
import 'validation_status_chip.dart';

/// Élément d'une timeline d'historique.
///
/// Affiche l'action principale, la date/heure, l'acteur et son rôle, la section
/// concernée, la description courte, le delta de valeurs et le statut.
class HistoryEntryTile extends StatelessWidget {
  final RabiesDossierHistoryEntry entry;
  final bool isLast;

  const HistoryEntryTile({
    super.key,
    required this.entry,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = TraceabilityUi.actionColor(entry.typeAction);
    final wide = MediaQuery.of(context).size.width >= 760;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          alignment: Alignment.center,
          child: Icon(
            TraceabilityUi.actionIcon(entry.typeAction),
            size: 19,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.titre,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.slate900,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                TraceabilityUi.dateHeure(entry.dateHeure),
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.slate500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ValidationStatusChip(statut: entry.statut),
      ],
    );

    final meta = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _sectionChip(entry.sectionConcernee.label, color),
        if (entry.etapeValidee != null) _etapeChip(entry.etapeValidee!.label),
      ],
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 10),
        if (wide) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: ActorBadge(actor: entry.acteur)),
              meta,
            ],
          ),
        ] else ...[
          ActorBadge(actor: entry.acteur),
          const SizedBox(height: 10),
          meta,
        ],
        if (entry.description != null && entry.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            entry.description!,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.slate600,
              height: 1.4,
            ),
          ),
        ],
        if (entry.deltaValeurs != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EpidemiologyTheme.warm150),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, size: 14, color: EpidemiologyTheme.slate400),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    entry.deltaValeurs!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: EpidemiologyTheme.slate700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rail(color, isLast),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: EpidemiologyTheme.warm100),
              boxShadow: EpidemiologyTheme.shadowSm,
            ),
            child: body,
          ),
        ),
      ],
    );
  }

  Widget _rail(Color color, bool last) {
    return SizedBox(
      width: 16,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 5),
              ],
            ),
          ),
          if (!last)
            Container(
              width: 2,
              height: 120,
              color: EpidemiologyTheme.warm150,
            ),
        ],
      ),
    );
  }

  Widget _sectionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.subject, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _etapeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.indigoLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EpidemiologyTheme.indigo.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 12, color: EpidemiologyTheme.indigo),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.indigo,
            ),
          ),
        ],
      ),
    );
  }
}
