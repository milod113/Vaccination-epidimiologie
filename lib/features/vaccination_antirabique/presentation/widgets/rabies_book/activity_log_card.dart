import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import 'rabies_book_utils.dart';

/// Journal des événements majeurs du schéma vaccinal (activity log premium).
///
/// Construit un historique ordonné à partir du protocole (doses), de la
/// traçabilité et du statut patient : début de protocole, dose validée,
/// dose reportée, dose en retard, ERIG, carte/registre, protocole terminé…
class ActivityLogCard extends StatelessWidget {
  final PatientAntirabiqueModel patient;
  final ProtocoleVaccinalModel? protocol;
  final InitialRabiesAssessment? evaluation;

  const ActivityLogCard({
    super.key,
    required this.patient,
    this.protocol,
    this.evaluation,
  });

  List<_Event> _buildEvents() {
    final events = <_Event>[];
    final p = protocol;

    if (p != null) {
      final start = DateTime.tryParse(p.dateDebut);
      events.add(_Event(
        keyDate: start ?? DateTime.now(),
        color: EpidemiologyTheme.info,
        icon: Icons.play_circle_fill_rounded,
        title: 'Protocole démarré',
        subtitle: '${p.type.label} initié — schéma ${p.doses.map((d) => d.jourTheorique.isEmpty ? 'J${d.numeroDose}' : d.jourTheorique).join(', ')}',
      ));

      for (final d in p.doses) {
        if (d.estAdministree) {
          events.add(_Event(
            keyDate: DateTime.tryParse(d.dateReelle ?? d.datePrevue) ?? DateTime.now(),
            color: EpidemiologyTheme.success,
            icon: Icons.vaccines_rounded,
            title: 'Dose ${d.numeroDose} validée (${d.jourTheorique})',
            subtitle: d.administrateurNom != null
                ? 'Administrée par ${d.administrateurNom}${d.numeroLot != null ? ' · lot ${d.numeroLot}' : ''}'
                : 'Administrée le ${formatBookDate(d.dateReelle ?? d.datePrevue)}',
          ));
        } else if (d.statut == DoseStatut.reportee) {
          events.add(_Event(
            keyDate: DateTime.tryParse(d.datePrevue) ?? DateTime.now(),
            color: EpidemiologyTheme.warning,
            icon: Icons.access_time_rounded,
            title: 'Dose ${d.numeroDose} reportée (${d.jourTheorique})',
            subtitle: d.motifReport ?? 'Reportée à une date ultérieure',
          ));
        } else if (d.estEnRetard) {
          events.add(_Event(
            keyDate: DateTime.tryParse(d.datePrevue) ?? DateTime.now(),
            color: EpidemiologyTheme.danger,
            icon: Icons.warning_amber_rounded,
            title: 'Rappel ${d.jourTheorique} manqué',
            subtitle: 'Date prévue ${formatBookDate(d.datePrevue)} — secteur en retard',
          ));
        }
      }

      if (p.rigAdministree) {
        events.add(_Event(
          keyDate: DateTime.tryParse(p.rigDateAdministration ?? '') ?? DateTime.now(),
          color: EpidemiologyTheme.teal,
          icon: Icons.science_rounded,
          title: 'ERIG administrée',
          subtitle: p.rigNumeroLot != null ? 'Lot ${p.rigNumeroLot}' : 'Immunoglobulines antirabiques',
        ));
      }

      if (p.estTermine) {
        events.add(_Event(
          keyDate: DateTime.now(),
          color: EpidemiologyTheme.success,
          icon: Icons.emoji_events_rounded,
          title: 'Protocole terminé',
          subtitle: 'Toutes les doses ont été administrées (${p.dosesAdministrees}/${p.totalDoses}).',
        ));
      }
    }

    final e = evaluation;
    if (e != null) {
      if (e.carteRemise) {
        events.add(_Event(
          keyDate: DateTime.now(),
          color: EpidemiologyTheme.info,
          icon: Icons.credit_card_rounded,
          title: 'Carte de vaccination remise',
          subtitle: e.numeroCarte != null ? 'N° ${e.numeroCarte}' : 'Document délivré au patient',
        ));
      }
      if (e.inscritRegistre) {
        events.add(_Event(
          keyDate: DateTime.now(),
          color: EpidemiologyTheme.info,
          icon: Icons.menu_book_rounded,
          title: 'Inscription au registre',
          subtitle: e.numeroRegistre != null ? 'N° ${e.numeroRegistre}' : 'Registre du centre',
        ));
      }
    }

    if (patient.statut == StatutSuivi.perduDeVue) {
      events.add(_Event(
        keyDate: DateTime.now(),
        color: EpidemiologyTheme.danger,
        icon: Icons.person_off_rounded,
        title: 'Patient perdu de vue',
        subtitle: 'Suivi à reprendre — patient ne se présente plus',
      ));
    }

    events.sort((a, b) => b.keyDate.compareTo(a.keyDate));
    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();
    if (events.isEmpty) {
      return bookCard(
        child: Row(
          children: [
            Icon(Icons.history_rounded, color: EpidemiologyTheme.warm300, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Aucun événement enregistré pour le moment.',
                style: GoogleFonts.cairo(fontSize: 13, color: EpidemiologyTheme.warm500),
              ),
            ),
          ],
        ),
      );
    }
    return bookCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 18, color: EpidemiologyTheme.burgundy),
              const SizedBox(width: 8),
              Text('Historique', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800)),
            ],
          ),
          const SizedBox(height: 8),
          for (final ev in events) _eventTile(ev),
        ],
      ),
    );
  }

  Widget _eventTile(_Event ev) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: ev.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(ev.icon, size: 17, color: ev.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ev.title,
                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800),
                ),
                const SizedBox(height: 1),
                Text(
                  ev.subtitle,
                  style: GoogleFonts.cairo(fontSize: 12, color: EpidemiologyTheme.warm500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Event {
  final DateTime keyDate;
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  _Event({
    required this.keyDate,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}