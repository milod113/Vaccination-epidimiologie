import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/vaccination.dart';
import 'clinical_status_pill.dart';
import 'dose_status_badge.dart';

/// Élément de la timeline vaccinale : une dose avec son statut, ses dates,
/// sa voie, son lot et les actions possibles.
///
/// [onValider] / [onReporter] / [onMarquerManquee] / [onDetails] sont des
/// hooks d'action — l'UI est prête même si le dépôt métier est encore mocké.
class DoseTimelineCard extends StatelessWidget {
  final VaccineDose dose;
  final bool isLast;
  final bool isNext;
  final VoidCallback? onValider;
  final VoidCallback? onReporter;
  final VoidCallback? onMarquerManquee;
  final VoidCallback? onDetails;

  const DoseTimelineCard({
    super.key,
    required this.dose,
    this.isLast = false,
    this.isNext = false,
    this.onValider,
    this.onReporter,
    this.onMarquerManquee,
    this.onDetails,
  });

  Color get _accent => dose.statut.color;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rail(),
          const SizedBox(width: 14),
          Expanded(child: _card()),
        ],
      ),
    );
  }

  Widget _rail() {
    return SizedBox(
      width: 28,
      child: Column(
        children: [
          _dot(),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: dose.estRealisee
                      ? EpidemiologyTheme.success.withValues(alpha: 0.35)
                      : EpidemiologyTheme.warm150,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dot() {
    final done = dose.estRealisee;
    final color = dose.statut.color;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        gradient: done
            ? LinearGradient(
                colors: [EpidemiologyTheme.success, EpidemiologyTheme.successDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
        border: Border.all(color: EpidemiologyTheme.white, width: 2.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
          if (isNext && !done)
            BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.14), blurRadius: 10, offset: Offset.zero),
        ],
      ),
      child: done
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : (dose.statut == DoseStatus.manquee
              ? const Icon(Icons.close, size: 14, color: Colors.white)
              : Icon(Icons.vaccines, size: 13, color: Colors.white)),
    );
  }

  Widget _card() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext && !dose.estRealisee
              ? EpidemiologyTheme.redPrimary.withValues(alpha: 0.45)
              : EpidemiologyTheme.warm100,
        ),
        boxShadow: [
          EpidemiologyTheme.shadowSm.first,
          if (isNext && !dose.estRealisee)
            BoxShadow(
              color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (dose.jourTheorique.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dose.jourTheorique,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: dose.statut.color,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Dose ${dose.numero}',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
              ),
              DoseStatusBadge(status: dose.statut),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _meta(Icons.event_available, 'Prévue', _fmt(dose.datePrevue)),
              if (dose.dateReelle != null)
                _meta(Icons.check_circle, 'Réelle', _fmt(dose.dateReelle)),
              _meta(Icons.science, 'Voie', dose.voie.label),
              if (dose.numeroLot != null)
                _meta(Icons.inventory_2, 'Lot', dose.numeroLot!),
              if (dose.notes != null && dose.notes!.isNotEmpty)
                _meta(Icons.notes, 'Note', dose.notes!),
            ],
          ),
          if (!dose.estRealisee && (onValider != null || onReporter != null || onMarquerManquee != null)) ...[
            const SizedBox(height: 12),
            Divider(color: EpidemiologyTheme.warm100, height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                if (onValider != null)
                  _action(
                    label: 'Valider',
                    icon: Icons.check_circle_outline,
                    color: EpidemiologyTheme.success,
                    onTap: onValider!,
                  ),
                if (onReporter != null)
                  _action(
                    label: 'Reporter',
                    icon: Icons.event_repeat,
                    color: EpidemiologyTheme.warning,
                    onTap: onReporter!,
                  ),
                if (onMarquerManquee != null)
                  _action(
                    label: 'Manquée',
                    icon: Icons.cancel_outlined,
                    color: EpidemiologyTheme.danger,
                    onTap: onMarquerManquee!,
                  ),
                const Spacer(),
                if (onDetails != null)
                  IconButton(
                    onPressed: onDetails,
                    icon: const Icon(Icons.info_outline, size: 18),
                    color: EpidemiologyTheme.slate400,
                    tooltip: 'Détails',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _action({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: EpidemiologyTheme.slate400),
        const SizedBox(width: 5),
        Text(
          '$label : ',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: EpidemiologyTheme.slate500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.slate700,
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
