import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import '../status_badge.dart';
import 'rabies_book_utils.dart';

/// Timeline moderne du schéma vaccinal antirabique.
///
/// Couleurs : vert = administrée, orange = aujourd'hui, rouge = en retard,
/// bleu doux = à venir, gris = reportée / non effectuée.
class RabiesDoseTimeline extends StatelessWidget {
  final List<DoseModel> doses;
  final String? nextDoseId;

  const RabiesDoseTimeline({super.key, required this.doses, this.nextDoseId});

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) {
      return bookCard(
        child: Row(
          children: [
            Icon(Icons.timeline_rounded, color: EpidemiologyTheme.warm300, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucune dose programmée. Réalisez l\'évaluation initiale pour générer le schéma vaccinal.',
                style: GoogleFonts.cairo(fontSize: 13, color: EpidemiologyTheme.warm500),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < doses.length; i++)
          _DoseTile(
            dose: doses[i],
            isLast: i == doses.length - 1,
            isNext: doses[i].id == nextDoseId,
          ),
      ],
    );
  }
}

class _DoseTile extends StatelessWidget {
  final DoseModel dose;
  final bool isLast;
  final bool isNext;

  const _DoseTile({required this.dose, required this.isLast, required this.isNext});

  @override
  Widget build(BuildContext context) {
    final detail = dose.statutDetaille;
    final Color color = bookDoseColor(detail);
    final day = dose.jourTheorique.isEmpty ? 'J${dose.numeroDose}' : dose.jourTheorique;
    final isToday = detail == DoseStatutDetaille.prevueAujourdhui;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withValues(alpha: 0.35), width: 1.4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day,
                    style: GoogleFonts.cairo(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: EpidemiologyTheme.warm100,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: _card(color, detail, isToday),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Color color, DoseStatutDetaille detail, bool isToday) {
    return Container(
      decoration: BoxDecoration(
        color: isNext
            ? color.withValues(alpha: 0.05)
            : EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isNext ? color.withValues(alpha: 0.5) : EpidemiologyTheme.warm100,
          width: isNext ? 1.6 : 1,
        ),
        boxShadow: isNext
            ? [BoxShadow(color: color.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4))]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dose.etiquetteDose,
                  style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800),
                ),
                if (isNext) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Prochaine dose',
                      style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
                const Spacer(),
                StatusBadge.detail(detail),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                _dateItem(
                  Icons.event_rounded,
                  isToday ? "Aujourd'hui — ${formatBookDate(dose.datePrevue)}" : 'Prévue ${formatBookDate(dose.datePrevue)}',
                  color,
                ),
                if (dose.dateReelle != null)
                  _dateItem(Icons.check_circle_outline_rounded, 'Réelle ${formatBookDate(dose.dateReelle!)}', EpidemiologyTheme.success),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (dose.voieAdministration != null)
                  _metaChip(Icons.biotech_rounded, dose.voieAdministration! + (dose.injectionDouble ? ' ×2' : '')),
                if (dose.numeroLot != null)
                  _metaChip(Icons.confirmation_number_rounded, 'Lot ${dose.numeroLot}'),
                if (dose.administrateurNom != null)
                  _metaChip(Icons.person_rounded, dose.administrateurNom!),
                if (dose.centre != null)
                  _metaChip(Icons.local_hospital_rounded, dose.centre!),
                if (dose.salle != null)
                  _metaChip(Icons.meeting_room_rounded, dose.salle!),
              ],
            ),
            if (dose.observations != null) ...[
              const SizedBox(height: 10),
              _note(dose.observations!, EpidemiologyTheme.info, Icons.info_outline_rounded),
            ],
            if (dose.motifReport != null) ...[
              const SizedBox(height: 10),
              _note(dose.motifReport!, EpidemiologyTheme.warning, Icons.access_time_rounded),
            ],
            if (dose.effetsIndesirables != null) ...[
              const SizedBox(height: 10),
              _note('Effets indésirables : ${dose.effetsIndesirables}', EpidemiologyTheme.warning, Icons.warning_amber_rounded),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dateItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w700, color: color),
        ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EpidemiologyTheme.warm100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: EpidemiologyTheme.warm500),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm600)),
        ],
      ),
    );
  }

  Widget _note(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}