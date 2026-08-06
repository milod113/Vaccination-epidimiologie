import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import 'rabies_book_utils.dart';

/// Synthèse clinique du patient : catégorie, ERIG, animal, statut et prochain acte.
class ClinicalSynthesisCard extends StatelessWidget {
  final PatientAntirabiqueModel patient;
  final ProtocoleVaccinalModel? protocol;
  final InitialRabiesAssessment? evaluation;

  const ClinicalSynthesisCard({
    super.key,
    required this.patient,
    this.protocol,
    this.evaluation,
  });

  String get _statutProtocole {
    final p = protocol;
    if (p == null) return 'Non démarré';
    if (p.estTermine) return 'Terminé';
    if (p.aRetard) return 'En retard';
    if (p.estEnCours) return 'En cours';
    return 'Non démarré';
  }

  String get _prochainActe {
    final p = protocol;
    if (evaluation == null) return "Réaliser l'évaluation initiale (J0)";
    if (p == null) return 'Définir le protocole vaccinal';
    if (p.estTermine) return 'Aucun — protocole complet';
    final next = p.prochaineDoseUrgente ?? p.prochaineDose;
    if (next == null) return 'Consultation médicale de suivi';
    final detail = next.statutDetaille;
    if (detail == DoseStatutDetaille.enRetard) return 'Rattraper la dose ${next.jourTheorique} (retard)';
    if (detail == DoseStatutDetaille.prevueAujourdhui) return 'Administrer la dose ${next.jourTheorique} aujourd\'hui';
    return 'Présenter le patient le ${formatBookDate(next.datePrevue)}';
  }

  @override
  Widget build(BuildContext context) {
    final p = protocol;
    final erigLabel = p == null
        ? 'Non renseigné'
        : p.rigAdministree
            ? 'Administrée'
            : p.rigIndiquee
                ? 'Indiquée mais non administrée'
                : 'Non indiquée';
    final erigColor = p == null
        ? EpidemiologyTheme.warm400
        : p.rigAdministree
            ? EpidemiologyTheme.success
            : p.rigIndiquee
                ? EpidemiologyTheme.warning
                : EpidemiologyTheme.warm500;

    return bookCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.medication_rounded, color: EpidemiologyTheme.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Synthèse clinique', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800)),
            ],
          ),
          const SizedBox(height: 14),
          _row(Icons.category_rounded, 'Catégorie rabique', patient.categorieExposition?.label ?? 'À évaluer'),
          _row(Icons.science_rounded, 'ERIG (immunoglobulines)', erigLabel, valueColor: erigColor),
          _row(
            Icons.pets_rounded,
            'Animal',
            patient.animalSource == null
                ? patient.animalStatut.label
                : '${patient.animalSource} · ${patient.animalStatut.label}',
          ),
          _row(Icons.vaccines_rounded, 'Statut du protocole', _statutProtocole),
          _row(Icons.trending_up_rounded, 'Évolution du patient', patient.statut.label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [EpidemiologyTheme.redPrimary.withValues(alpha: 0.08), EpidemiologyTheme.burgundy.withValues(alpha: 0.06)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_rounded, size: 16, color: EpidemiologyTheme.redPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Prochain acte : $_prochainActe',
                    style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w800, color: EpidemiologyTheme.redDeep),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, {Color valueColor = EpidemiologyTheme.warm800}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm50,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: EpidemiologyTheme.warm500),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm400)),
                const SizedBox(height: 1),
                Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}