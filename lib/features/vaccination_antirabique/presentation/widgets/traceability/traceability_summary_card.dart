import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_traceability_summary.dart';
import 'actor_badge.dart';
import 'traceability_ui.dart';

/// Carte de synthèse de la traçabilité réglementaire.
///
/// Affiche le statut global, les volets carte/registre, le nombre d'événements,
/// le dernier acteur et la dernière modification.
class TraceabilitySummaryCard extends StatelessWidget {
  final RabiesTraceabilitySummary summary;

  const TraceabilitySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final color = TraceabilityUi.traceabilityColor(summary.statut);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EpidemiologyTheme.indigo.withValues(alpha: 0.06),
            EpidemiologyTheme.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  TraceabilityUi.traceabilityIcon(summary.statut),
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traçabilité réglementaire',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                    Text(
                      '${summary.pointsOk}/${summary.totalPoints} volets renseignés',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(TraceabilityUi.traceabilityIcon(summary.statut),
                        size: 14, color: color),
                    const SizedBox(width: 5),
                    Text(
                      summary.statut.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _volet(
                  icon: Icons.badge_outlined,
                  label: 'Carte de vaccination',
                  ok: summary.carteRemise,
                  detail: summary.numeroCarte != null
                      ? 'N° ${summary.numeroCarte}'
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _volet(
                  icon: Icons.menu_book_outlined,
                  label: 'Registre de l\'UAR',
                  ok: summary.registreRenseigne,
                  detail: summary.numeroRegistre != null
                      ? 'N° ${summary.numeroRegistre}'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _progress(summary.completudePourcent, color),
          const SizedBox(height: 14),
          if (summary.dernierActeur != null)
            Row(
              children: [
                const Icon(Icons.history, size: 14, color: EpidemiologyTheme.slate400),
                const SizedBox(width: 6),
                Text(
                  '${summary.nombreEvenements} événements · dernière action :',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: EpidemiologyTheme.slate500,
                  ),
                ),
              ],
            ),
          if (summary.dernierActeur != null) ...[
            const SizedBox(height: 8),
            ActorBadge(actor: summary.dernierActeur!, compact: true),
          ],
          if (summary.derniereModification != null) ...[
            const SizedBox(height: 8),
            Text(
              'Modifié le ${TraceabilityUi.dateHeure(summary.derniereModification!)}',
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

  Widget _volet({
    required IconData icon,
    required String label,
    required bool ok,
    String? detail,
  }) {
    final color = ok ? EpidemiologyTheme.success : EpidemiologyTheme.warning;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ok ? 'Renseigné' : 'À compléter',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(
              detail,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: EpidemiologyTheme.slate700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _progress(int pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Complétude',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.slate500,
                ),
              ),
            ),
            Text(
              '$pct%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 7,
            child: Stack(
              children: [
                Container(color: EpidemiologyTheme.warm150),
                FractionallySizedBox(
                  widthFactor: pct / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.6)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
