import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/traceability.dart';
import 'clinical_status_pill.dart';

/// Carte de traçabilité administrative (carte de vaccination + registre).
///
/// Présentation compacte et professionnelle : deux volets (carte / registre)
/// avec statuts colorés et numéros lorsque disponibles.
class TraceabilityCard extends StatelessWidget {
  final TraceabilityInfo tracabilite;

  const TraceabilityCard({super.key, required this.tracabilite});

  @override
  Widget build(BuildContext context) {
    final carteOk = tracabilite.carteRemise;
    final registreOk = tracabilite.patientRepertorie;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.indigo.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long_outlined, size: 20, color: EpidemiologyTheme.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Traçabilité du dossier',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
              ),
              ClinicalStatusPill(
                label: carteOk && registreOk ? 'Complète' : 'À compléter',
                icon: carteOk && registreOk ? Icons.verified_outlined : Icons.pending_outlined,
                color: carteOk && registreOk
                    ? EpidemiologyTheme.success
                    : EpidemiologyTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _panel(
                  icon: Icons.badge_outlined,
                  color: carteOk ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
                  title: 'Carte de vaccination',
                  status: carteOk ? 'Remise' : 'Non remise',
                  detail: tracabilite.numeroCarte != null
                      ? 'N° ${tracabilite.numeroCarte}'
                      : null,
                  hint: carteOk && tracabilite.numeroCarte == null
                      ? 'Numéro non renseigné'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _panel(
                  icon: Icons.menu_book_outlined,
                  color: registreOk ? EpidemiologyTheme.success : EpidemiologyTheme.warning,
                  title: 'Registre de l\'UAR',
                  status: registreOk ? 'Inscrit' : 'Non inscrit',
                  detail: tracabilite.numeroRegistre != null
                      ? 'N° ${tracabilite.numeroRegistre}'
                      : null,
                  hint: registreOk && tracabilite.numeroRegistre == null
                      ? 'Numéro non renseigné'
                      : null,
                ),
              ),
            ],
          ),
          if (tracabilite.remarques != null && tracabilite.remarques!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EpidemiologyTheme.warm100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 16, color: EpidemiologyTheme.slate400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tracabilite.remarques!,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.slate700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _panel({
    required IconData icon,
    required Color color,
    required String title,
    required String status,
    String? detail,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: EpidemiologyTheme.slate700,
              ),
            ),
          ],
          if (hint != null) ...[
            const SizedBox(height: 2),
            Text(
              hint,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: EpidemiologyTheme.slate400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
