import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import 'tetanus_status_badge.dart';

class TetanusPatientCard extends StatelessWidget {
  final TetanusPatientModel patient;
  final VoidCallback onTap;

  const TetanusPatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = patient.estUrgent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isUrgent
                  ? EpidemiologyTheme.danger.withValues(alpha: 0.03)
                  : EpidemiologyTheme.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isUrgent
                    ? EpidemiologyTheme.danger.withValues(alpha: 0.18)
                    : EpidemiologyTheme.warm100,
                width: isUrgent ? 1.2 : 1,
              ),
              boxShadow: isUrgent
                  ? [
                      BoxShadow(
                        color: EpidemiologyTheme.danger.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 3),
                      ),
                      ...EpidemiologyTheme.shadowSm,
                    ]
                  : EpidemiologyTheme.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _avatar(),
                    const SizedBox(width: 14),
                    Expanded(child: _identity()),
                    if (isUrgent) _urgentChip(),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(
                  height: 1,
                  color: EpidemiologyTheme.warm100,
                  thickness: 1,
                ),
                const SizedBox(height: 14),
                _buildInfoRow(
                  Icons.healing_outlined,
                  patient.typePlaie.label,
                  patient.localisation,
                  patient.typePlaie == TetanusWoundType.tetanigene
                      ? EpidemiologyTheme.danger
                      : null,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.event_outlined,
                  'Blessure : ${patient.dateBlessure}',
                  'Délai : ${patient.delaiConsultation}',
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TetanusStatusBadge(
                      statut: patient.statutDossier,
                      fontSize: 10,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TetanusVaccinStatusBadge(
                      status: patient.statutVaccinal,
                      fontSize: 10,
                      compact: true,
                    ),
                    const Spacer(),
                    if (patient.decision != TetanusDecision.simpleSurveillance)
                      TetanusDecisionBadge(
                        decision: patient.decision,
                        fontSize: 9,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar() {
    final isUrgent = patient.estUrgent;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: isUrgent
            ? LinearGradient(
                colors: [EpidemiologyTheme.danger, EpidemiologyTheme.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : EpidemiologyTheme.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                (isUrgent
                        ? EpidemiologyTheme.danger
                        : EpidemiologyTheme.redDeep)
                    .withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          patient.nomComplet
              .split(' ')
              .map((e) => e.isNotEmpty ? e[0] : '')
              .take(2)
              .join(''),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _identity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          patient.nomComplet,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.warm800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${patient.age} ans \u2022 ${patient.sexe} \u2022 ${patient.id}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: EpidemiologyTheme.warm400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String left,
    String right, [
    Color? accent,
  ]) {
    return Row(
      children: [
        Icon(icon, size: 15, color: accent ?? EpidemiologyTheme.warm400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            left,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: accent ?? EpidemiologyTheme.warm600,
            ),
          ),
        ),
        Text(
          right,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accent ?? EpidemiologyTheme.warm500,
          ),
        ),
      ],
    );
  }

  Widget _urgentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EpidemiologyTheme.danger.withValues(alpha: 0.9),
            EpidemiologyTheme.orange.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.danger.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'URGENT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
