import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import '../status_badge.dart';
import 'rabies_book_utils.dart';

/// Carte premium dédiée à la prochaine dose, très visible.
class NextDoseCard extends StatelessWidget {
  final ProtocoleVaccinalModel? protocol;

  const NextDoseCard({super.key, this.protocol});

  @override
  Widget build(BuildContext context) {
    final p = protocol;
    if (p == null) {
      return _empty('Évaluation J0 requise',
          "L'évaluation initiale n'a pas encore été réalisée. Renseignez la fiche J0 pour démarrer le protocole vaccinal.");
    }
    if (p.estTermine) {
      return _completed();
    }
    final next = p.prochaineDoseUrgente ?? p.prochaineDose;
    if (next == null) {
      return _empty('Suivi en attente', 'Aucune dose prévue à ce jour. Consultez le médecin pour la suite du schéma vaccinal.');
    }
    return _due(next);
  }

  Widget _due(DoseModel dose) {
    final detail = dose.statutDetaille;
    final Color color = bookDoseColor(detail);
    final isToday = detail == DoseStatutDetaille.prevueAujourdhui;
    final isDelayed = detail == DoseStatutDetaille.enRetard;

    final action = isDelayed
        ? 'Dose en retard — prendre un rendez-vous en urgence'
        : isToday
            ? 'Se présenter au centre aujourd\'hui'
            : 'Se présenter au centre à la date prévue';

    return bookCard(
      padding: const EdgeInsets.all(20),
      borderColor: isDelayed ? EpidemiologyTheme.danger : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              dose.jourTheorique.isEmpty ? 'J${dose.numeroDose}' : dose.jourTheorique,
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Prochaine dose', style: EpidemiologyTheme.overline(color: EpidemiologyTheme.warm500)),
                    const Spacer(),
                    StatusBadge.detail(detail),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dose.etiquetteDose,
                  style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(
                      isToday ? "Aujourd'hui — ${formatBookDate(dose.datePrevue)}" : 'Prévue le ${formatBookDate(dose.datePrevue)}',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag_rounded, size: 16, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          action,
                          style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _completed() {
    return bookCard(
      borderColor: EpidemiologyTheme.success,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.successLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.verified_rounded, color: EpidemiologyTheme.success, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protocole terminé', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: EpidemiologyTheme.successDark)),
                const SizedBox(height: 2),
                Text('Toutes les doses prescrites ont été administrées. Suivi vaccinal complet.', style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String title, String message) {
    return bookCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.event_available_rounded, color: EpidemiologyTheme.warm500, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800)),
                const SizedBox(height: 2),
                Text(message, style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}