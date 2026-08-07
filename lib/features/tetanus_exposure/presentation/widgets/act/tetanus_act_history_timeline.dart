import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';
import '../tetanus_evaluation_controls.dart';
import 'tetanus_act_ui.dart';

/// Frise chronologique premium des actes enregistrés pour un patient.
///
/// Chaque acte est matérialisé par un point coloré selon son type, avec ses
/// métadonnées (vaccin, lot, voie, dose, zone, acteur, centre) et son statut.
class TetanusActHistoryTimeline extends StatelessWidget {
  const TetanusActHistoryTimeline({
    super.key,
    required this.acts,
    this.emptyMessage = 'Aucun acte enregistré pour ce dossier.',
    this.trailingTitle,
  });

  final List<TetanusActeModel> acts;
  final String emptyMessage;
  final String? trailingTitle;

  @override
  Widget build(BuildContext context) {
    if (acts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.warm50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: EpidemiologyTheme.warm150),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 20,
              color: EpidemiologyTheme.warm300,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                emptyMessage,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: EpidemiologyTheme.warm400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sorted = [...acts]..sort((a, b) => b.dateActe.compareTo(a.dateActe));
    return Column(
      children: [
        for (var i = 0; i < sorted.length; i++)
          _item(sorted[i], isLast: i == sorted.length - 1),
      ],
    );
  }

  Widget _item(TetanusActeModel acte, {required bool isLast}) {
    final type = acte.type;
    final color = type != null
        ? tetanusActColor(type)
        : EpidemiologyTheme.redPrimary;
    final icon = type != null ? tetanusActIcon(type) : Icons.vaccines_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: EpidemiologyTheme.warm150),
                  boxShadow: EpidemiologyTheme.shadowSm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, size: 16, color: color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                acte.typeActe,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: EpidemiologyTheme.warm800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  acte.dateActe,
                                  if (acte.heureActe != null)
                                    '${acte.heureActe} h',
                                ].join(' · '),
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: EpidemiologyTheme.warm400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (acte.valide)
                          TetanusBadge(
                            label: 'Validé',
                            color: EpidemiologyTheme.success,
                            icon: Icons.verified_outlined,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_hasProductMeta(acte) ||
                        acte.administrateur != null ||
                        acte.centre != null) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (acte.vaccin != null)
                            _chip(
                              Icons.medication_outlined,
                              acte.vaccin!,
                              color,
                            ),
                          if (acte.numeroLot != null)
                            _chip(
                              Icons.qr_code_rounded,
                              'Lot ${acte.numeroLot}',
                              EpidemiologyTheme.warning,
                            ),
                          if (acte.voie != null)
                            _chip(
                              Icons.arrow_outward_rounded,
                              'Voie ${acte.voie}',
                              color,
                            ),
                          if (acte.dose != null)
                            _chip(
                              Icons.speed_rounded,
                              acte.dose!,
                              EpidemiologyTheme.info,
                            ),
                          if (acte.zone != null)
                            _chip(
                              Icons.location_on_outlined,
                              acte.zone!,
                              EpidemiologyTheme.info,
                            ),
                          if (acte.administrateur != null)
                            _chip(
                              Icons.person_outline,
                              acte.administrateur!,
                              EpidemiologyTheme.warm500,
                            ),
                          if (acte.role != null)
                            _chip(
                              Icons.badge_outlined,
                              acte.role!,
                              EpidemiologyTheme.warm500,
                            ),
                          if (acte.centre != null)
                            _chip(
                              Icons.location_city_outlined,
                              acte.centre!,
                              EpidemiologyTheme.warm500,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (acte.observations != null &&
                        acte.observations!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: EpidemiologyTheme.warm50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          acte.observations!,
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            height: 1.4,
                            color: EpidemiologyTheme.warm500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasProductMeta(TetanusActeModel acte) =>
      acte.vaccin != null ||
      acte.numeroLot != null ||
      acte.voie != null ||
      acte.dose != null ||
      acte.zone != null;

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
