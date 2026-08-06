import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/vaccination.dart';
import '../rabies_dossier_widgets.dart';

/// Timeline verticale des doses du protocole vaccinal.
class DoseTimeline extends StatelessWidget {
  final List<VaccineDose> doses;
  final bool showDivider;

  const DoseTimeline({super.key, required this.doses, this.showDivider = true});

  Color _color(DoseStatus s) => switch (s) {
    DoseStatus.realisee => EpidemiologyTheme.success,
    DoseStatus.enRetard => EpidemiologyTheme.warning,
    DoseStatus.manquee => EpidemiologyTheme.danger,
    DoseStatus.prevue => EpidemiologyTheme.slate400,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < doses.length; i++) _row(doses[i], isLast: i == doses.length - 1),
      ],
    );
  }

  Widget _row(VaccineDose dose, {required bool isLast}) {
    final color = _color(dose.statut);
    final realized = dose.estRealisee;
    final dateLabel = dose.dateReelle != null
        ? ddMMyyyy(dose.dateReelle)
        : dose.datePrevue != null
            ? ddMMyyyy(dose.datePrevue)
            : '—';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: realized ? color : Colors.white,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: realized
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: EpidemiologyTheme.warm150,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dose.etiquette,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.slate800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dose.statut.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.warm500,
                    ),
                  ),
                  if (dose.numeroLot != null && dose.numeroLot!.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      'Lot ${dose.numeroLot}',
                      style: GoogleFonts.inter(fontSize: 10.5, color: EpidemiologyTheme.warm400),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (showDivider) const SizedBox(width: 10),
        ],
      ),
    );
  }
}