import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/suivi_clinique_model.dart';

class FollowUpNoteCard extends StatelessWidget {
  final SuiviCliniqueModel note;

  const FollowUpNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final (Color typeColor, Color typeBg, IconData icon) = switch (note.effetIndesirable) {
      EffetIndesirableType.aucun => (EpidemiologyTheme.success, EpidemiologyTheme.successLight, Icons.check_circle_outline),
      EffetIndesirableType.local => (EpidemiologyTheme.warning, EpidemiologyTheme.warningLight, Icons.healing),
      EffetIndesirableType.general => (EpidemiologyTheme.orange, EpidemiologyTheme.orangeLight, Icons.thermostat),
      EffetIndesirableType.grave => (EpidemiologyTheme.danger, EpidemiologyTheme.dangerLight, Icons.warning),
    };

    return Container(
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(
          color: note.doseReportee ? EpidemiologyTheme.warningLight : EpidemiologyTheme.slate100,
          width: note.doseReportee ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: EpidemiologyTheme.blackWith(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: EpidemiologyTheme.slate100)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [typeColor, typeColor.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        note.date,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.slate900,
                        ),
                      ),
                      Text(
                        'Par ${note.auteur}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: EpidemiologyTheme.slate400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (note.effetIndesirable != EffetIndesirableType.aucun)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: typeColor.withValues(alpha: 0.15)),
                    ),
                    child: Text(
                      note.effetIndesirable.label.split(' ').first,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note.note,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: EpidemiologyTheme.slate600,
                    height: 1.45,
                  ),
                ),
                if (note.descriptionEffet != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: typeBg.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: typeBg, width: 0.5),
                    ),
                    child: Text(
                      note.descriptionEffet!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: typeColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                if (note.doseReportee) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [EpidemiologyTheme.warningLight, EpidemiologyTheme.amberLight],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: EpidemiologyTheme.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Dose reportée',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: EpidemiologyTheme.warning,
                                ),
                              ),
                              Text(
                                note.motifReport ?? 'Motif non spécifié',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: EpidemiologyTheme.slate500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (note.dateNouveauRdv != null)
                          Text(
                            '→ ${note.dateNouveauRdv}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: EpidemiologyTheme.teal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
