import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/follow_up.dart';
import 'clinical_status_pill.dart';

/// Carte MPVI (manifestation post-vaccinale indésirable).
///
/// Alerte visuelle si réaction sévère, badges de gravité, résumé des
/// manifestations, mesures prises et statut de déclaration pharmacovigilance.
class MpviAlertCard extends StatelessWidget {
  final MpviInfo mpvi;

  const MpviAlertCard({super.key, required this.mpvi});

  @override
  Widget build(BuildContext context) {
    if (!mpvi.present) {
      return _noneCard();
    }

    final severe = mpvi.gravite == MpviSeverity.severe;
    final color = switch (mpvi.gravite) {
      MpviSeverity.benigne => EpidemiologyTheme.success,
      MpviSeverity.moderee => EpidemiologyTheme.warning,
      MpviSeverity.severe => EpidemiologyTheme.danger,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: severe
              ? const [EpidemiologyTheme.dangerLight, EpidemiologyTheme.white]
              : [color.withValues(alpha: 0.10), EpidemiologyTheme.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  severe ? Icons.warning_amber_rounded : Icons.health_and_safety_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      severe ? 'Réaction sévère' : 'Réaction post-vaccinale',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                    Text(
                      'Détectée et enregistrée au dossier',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              ClinicalStatusPill(
                label: mpvi.gravite.label,
                icon: severe ? Icons.report : Icons.medical_information,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _row(Icons.calendar_today, 'Date d\'apparition', _fmt(mpvi.dateApparition)),
          if (mpvi.manifestations != null)
            _row(Icons.subject, 'Manifestations', mpvi.manifestations!),
          if (mpvi.mesuresPrises != null)
            _row(Icons.medication, 'Mesures prises', mpvi.mesuresPrises!),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                mpvi.declarationPharmacovigilance
                    ? Icons.assignment_turned_in
                    : Icons.assignment_late,
                size: 15,
                color: mpvi.declarationPharmacovigilance
                    ? EpidemiologyTheme.success
                    : EpidemiologyTheme.warning,
              ),
              const SizedBox(width: 8),
              Text(
                mpvi.declarationPharmacovigilance
                    ? 'Déclaration pharmacovigilance effectuée'
                    : 'Pharmacovigilance non déclarée',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: mpvi.declarationPharmacovigilance
                      ? EpidemiologyTheme.success
                      : EpidemiologyTheme.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noneCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.check_circle_outline, size: 20, color: EpidemiologyTheme.success),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Aucune réaction post-vaccinale déclarée à ce jour.',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: EpidemiologyTheme.slate700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: EpidemiologyTheme.slate400),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: EpidemiologyTheme.slate500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
