import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import 'rabies_book_utils.dart';

/// Traçabilité vaccinale : carte de vaccination, registre, centre, évaluateur.
class TraceabilitySummaryCard extends StatelessWidget {
  final InitialRabiesAssessment? evaluation;
  final ProtocoleVaccinalModel? protocol;

  const TraceabilitySummaryCard({super.key, this.evaluation, this.protocol});

  @override
  Widget build(BuildContext context) {
    final e = evaluation;
    final carteRemise = e?.carteRemise ?? false;
    final inscritRegistre = e?.inscritRegistre ?? false;
    final carteC = carteRemise ? EpidemiologyTheme.success : EpidemiologyTheme.warning;
    final regC = inscritRegistre ? EpidemiologyTheme.success : EpidemiologyTheme.warning;

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
                  color: EpidemiologyTheme.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.verified_user_rounded, color: EpidemiologyTheme.info, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Traçabilité vaccinale', style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w800, color: EpidemiologyTheme.warm800)),
            ],
          ),
          const SizedBox(height: 14),
          _tile(
            Icons.credit_card_rounded,
            'Carte de vaccination',
            carteRemise ? 'Remise' : 'Non remise',
            e?.numeroCarte,
            carteC,
            yesNo: true,
          ),
          _tile(
            Icons.menu_book_rounded,
            'Registre',
            inscritRegistre ? 'Inscrit' : 'Non inscrit',
            e?.numeroRegistre,
            regC,
            yesNo: true,
          ),
          if (e?.centre != null)
            _tile(Icons.local_hospital_rounded, 'Centre / service', e!.centre!, null, EpidemiologyTheme.warm700),
          if (e?.medecinEvaluateur != null)
            _tile(Icons.medication_rounded, 'Évaluateur J0', e!.medecinEvaluateur!, null, EpidemiologyTheme.warm700),
          if (e?.structureOrientation != null)
            _tile(Icons.transfer_within_a_station_rounded, 'Structure d\'orientation', e!.structureOrientation!, null, EpidemiologyTheme.warm700),
          const SizedBox(height: 8),
          _adminLine(),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value, String? detail, Color color, {bool yesNo = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm400)),
                const SizedBox(height: 1),
                Text(value, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
                if (detail != null && detail.isNotEmpty)
                  Text('N° : $detail', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm600)),
              ],
            ),
          ),
          if (yesNo)
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                value.startsWith('Remise') || value.startsWith('Inscrit') || (detail != null && detail.isNotEmpty)
                    ? Icons.check_rounded
                    : Icons.close_rounded,
                size: 15,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  /// Dernière administration : date et administrateur issus du protocole.
  Widget _adminLine() {
    final doses = protocol?.doses ?? const <DoseModel>[];
    final last = doses.where((d) => d.estAdministree).toList().reversed.firstOrNull;
    if (last == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.warm50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 15, color: EpidemiologyTheme.warm400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aucune dose administrée pour le moment.',
                style: GoogleFonts.cairo(fontSize: 12.5, color: EpidemiologyTheme.warm600),
              ),
            ),
          ],
        ),
      );
    }
    final when = last.dateReelle ?? last.datePrevue;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.successLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EpidemiologyTheme.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.task_alt_rounded, size: 16, color: EpidemiologyTheme.success),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Dernière dose ${last.jourTheorique} administrée le ${formatBookDate(when)}'
              '${last.administrateurNom != null ? ' par ${last.administrateurNom}' : ''}'
              '${last.numeroLot != null ? ' · lot ${last.numeroLot}' : ''}.',
              style: GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w600, color: EpidemiologyTheme.successDark),
            ),
          ),
        ],
      ),
    );
  }
}