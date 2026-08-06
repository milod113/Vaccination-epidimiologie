import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import '../status_badge.dart';
import 'rabies_book_utils.dart';

/// Hero premium du carnet vaccinal antirabique : identité du patient,
/// catégorie, protocole, statut global et prochaine dose / message final.
class RabiesVaccinationBookHeader extends StatelessWidget {
  final PatientAntirabiqueModel patient;
  final ProtocoleVaccinalModel? protocol;

  const RabiesVaccinationBookHeader({
    super.key,
    required this.patient,
    this.protocol,
  });

  @override
  Widget build(BuildContext context) {
    final categorie = patient.categorieExposition;
    final catColor = switch (categorie) {
      CategorieExposition.categorieI => EpidemiologyTheme.success,
      CategorieExposition.categorieII => EpidemiologyTheme.warning,
      CategorieExposition.categorieIII => EpidemiologyTheme.danger,
      null => EpidemiologyTheme.warm400,
    };
    final catLabel = categorie?.label ?? 'À évaluer';
    final protoLabel = protocol?.type.label ?? 'À définir';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.28),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.10),
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
              _avatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Carnet vaccinal',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      patient.nomComplet,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${patient.age} ans · ${patient.sexe} · ${patient.id}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.menu_book_rounded, color: Colors.white.withValues(alpha: 0.35), size: 30),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                Icons.category_rounded,
                catLabel,
                color: catColor,
              ),
              _chip(Icons.vaccines_rounded, protoLabel, color: EpidemiologyTheme.teal),
              if (protocol?.rigAdministree == true)
                _chip(Icons.science_rounded, 'RIG administrée', color: EpidemiologyTheme.success),
              if (protocol?.rigIndiquee == true && protocol?.rigAdministree != true)
                _chip(Icons.science_rounded, 'RIG indiquée', color: EpidemiologyTheme.warning),
              if (patient.animalStatut != AnimauxStatut.inconnu)
                _chip(Icons.pets_rounded, patient.animalStatut.label, color: EpidemiologyTheme.info),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatusBadge.suivi(patient.statut),
              const Spacer(),
              _nextMessage(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final initials = patient.nomComplet
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.5),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label, {required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nextMessage() {
    final p = protocol;
    if (p == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Évaluation J0 à réaliser',
              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      );
    }
    if (p.estTermine) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.success.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Protocole terminé — complet',
              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      );
    }
    final next = p.prochaineDoseUrgente ?? p.prochaineDose;
    if (next == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              'Suivi en attente',
              style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ],
        ),
      );
    }
    final danger = next.statutDetaille == DoseStatutDetaille.enRetard;
    final today = next.statutDetaille == DoseStatutDetaille.prevueAujourdhui;
    final color = danger
        ? EpidemiologyTheme.danger
        : today
            ? EpidemiologyTheme.warning
            : EpidemiologyTheme.success;
    final label = danger
        ? 'Dose ${next.numeroDose} en retard'
        : today
            ? 'Dose ${next.numeroDose} ($next.jourTheorique) aujourd\'hui'
            : 'Prochaine dose ${next.jourTheorique} · ${formatBookDate(next.datePrevue)}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(danger ? Icons.warning_amber_rounded : Icons.event_available_rounded, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}