import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import 'rabies_book_utils.dart';

/// Détail du protocole vaccinal : type, schéma, durée, visites, décision.
class ProtocolSummaryCard extends StatelessWidget {
  final ProtocoleVaccinalModel protocol;
  final InitialRabiesAssessment? evaluation;

  const ProtocolSummaryCard({super.key, required this.protocol, this.evaluation});

  @override
  Widget build(BuildContext context) {
    final type = protocol.type;
    final schema = protocol.doses
        .map((d) => d.jourTheorique.isEmpty ? 'J${d.numeroDose}' : d.jourTheorique)
        .toList();

    return bookCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [EpidemiologyTheme.redPrimary, EpidemiologyTheme.burgundy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.vaccines_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.label, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800)),
                    Text('${type.totalDoses} doses · ${type.nombreVisites} visites · ${type.duree}',
                        style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm500)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _row(Icons.timeline_rounded, 'Schéma théorique', schema.join(' → ')),
          _row(
            Icons.event_rounded,
            'Début du protocole',
            formatBookDateOrNull(protocol.dateDebut.isEmpty ? null : protocol.dateDebut) ?? 'Non renseigné',
          ),
          _row(Icons.medical_services_rounded, 'Décision initiale', evaluation?.synthese.label ?? 'Non renseignée'),
          _row(Icons.notes_rounded, 'Justification', 'Schéma recommandé (OMS) selon catégorie / terrain'),
          const SizedBox(height: 12),
          Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: EpidemiologyTheme.redPrimary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type.description,
                          style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm600, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
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
                Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}