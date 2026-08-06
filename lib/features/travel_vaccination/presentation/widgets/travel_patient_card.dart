import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/travel_models.dart';
import 'travel_status_badge.dart';

class TravelPatientCard extends StatelessWidget {
  final TravelPatient patient;
  final VoidCallback? onTap;

  const TravelPatientCard({super.key, required this.patient, this.onTap});

  Color get _accent {
    if (patient.estUrgent) return EpidemiologyTheme.danger;
    if (patient.estProche) return EpidemiologyTheme.warning;
    return EpidemiologyTheme.teal;
  }

  String get _countdownLabel {
    final j = patient.joursRestants;
    if (j <= 0) return 'Aujourd\'hui';
    if (j == 1) return 'Demain';
    return 'J-$j';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
          border: Border.all(color: _accent.withValues(alpha: 0.12), width: 1),
          boxShadow: [
            ...EpidemiologyTheme.shadowSm,
            BoxShadow(color: _accent.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [EpidemiologyTheme.teal, EpidemiologyTheme.emerald],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: EpidemiologyTheme.teal.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: Center(
                    child: Text(
                      '${patient.prenom[0]}${patient.nom[0]}',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EpidemiologyTheme.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.nomComplet, style: EpidemiologyTheme.subtitle(color: EpidemiologyTheme.warm800)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.flight, size: 12, color: EpidemiologyTheme.teal),
                          const SizedBox(width: 4),
                          Text(patient.destination, style: EpidemiologyTheme.caption(color: EpidemiologyTheme.teal)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _accent.withValues(alpha: 0.10),
                        _accent.withValues(alpha: 0.18),
                      ],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _accent.withValues(alpha: 0.15), width: 1),
                  ),
                  child: Text(_countdownLabel, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: _accent)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: patient.vaccins.map((v) => TravelStatusBadge(status: v.statut, fontSize: 10)).toList(),
            ),
            if (patient.conseils != null) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 13, color: EpidemiologyTheme.warm400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(patient.conseils!,
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w400, height: 1.4, color: EpidemiologyTheme.warm500)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
