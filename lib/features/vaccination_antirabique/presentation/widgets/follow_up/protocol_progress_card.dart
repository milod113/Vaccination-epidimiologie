import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import 'clinical_status_pill.dart';

/// Carte de progression du protocole vaccinal.
///
/// Affiche le protocole actif, la barre de progression, les doses réalisées /
/// restantes, la durée estimée et le statut global.
class ProtocolProgressCard extends StatelessWidget {
  final RabiesFollowUpSummary summary;
  final VaccinationProtocolType protocolType;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int dureeJours;

  const ProtocolProgressCard({
    super.key,
    required this.summary,
    required this.protocolType,
    required this.dateDebut,
    required this.dateFin,
    required this.dureeJours,
  });

  Color get _statusColor => switch (summary.protocoleStatut) {
        RabiesProtocolStatus.termine => EpidemiologyTheme.success,
        RabiesProtocolStatus.enRetard => EpidemiologyTheme.danger,
        RabiesProtocolStatus.enCours => EpidemiologyTheme.redPrimary,
        RabiesProtocolStatus.sansProtocole => EpidemiologyTheme.slate400,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
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
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.vaccines, size: 20, color: _statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protocolType.label,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                    Text(
                      summary.protocoleStatut.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              ClinicalStatusPill(
                label: '${summary.progressionPercent}%',
                icon: Icons.trending_up,
                color: _statusColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                '${summary.dosesRealisees}/${summary.totalDoses} doses',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.slate700,
                ),
              ),
              const Spacer(),
              Text(
                summary.totalDoses - summary.dosesRealisees > 0
                    ? '${summary.totalDoses - summary.dosesRealisees} restante(s)'
                    : 'Schéma complet',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          EpidemiologyTheme.doseProgress(
            current: summary.dosesRealisees,
            total: summary.totalDoses,
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today, 'Début', _fmt(dateDebut)),
          if (dureeJours > 0)
            _infoRow(Icons.event_available, 'Fin estimée', _fmt(dateFin)),
          _infoRow(Icons.timeline, 'Durée estimée',
              dureeJours > 0 ? '$dureeJours jours' : '—'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: EpidemiologyTheme.slate400),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.slate500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.slate900,
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
