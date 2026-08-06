import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_actor.dart';
import '../../../domain/models/dossier/dossier_traceability_summary.dart';
import 'actor_badge.dart';
import 'traceability_ui.dart';

/// Carte détaillée des volets administratifs : carte de vaccination et
/// inscription au registre, avec acteur et date de chaque opération.
class RegistryCard extends StatelessWidget {
  final RabiesTraceabilitySummary summary;

  const RegistryCard({super.key, required this.summary});

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
                child: const Icon(
                  Icons.account_balance_outlined,
                  size: 20,
                  color: EpidemiologyTheme.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Volets administratifs',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.slate900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _volet(
            icon: Icons.badge_outlined,
            title: 'Carte de vaccination',
            ok: summary.carteRemise,
            okLabel: 'Remise',
            koLabel: 'Non remise',
            numero: summary.numeroCarte != null
                ? 'N° ${summary.numeroCarte}'
                : null,
            acteur: summary.carteRemisePar,
            date: summary.dateCarteRemise,
          ),
          const SizedBox(height: 12),
          _volet(
            icon: Icons.menu_book_outlined,
            title: 'Registre de l\'UAR',
            ok: summary.registreRenseigne,
            okLabel: 'Inscrit',
            koLabel: 'Non inscrit',
            numero: summary.numeroRegistre != null
                ? 'N° ${summary.numeroRegistre}'
                : null,
            acteur: summary.registreRenseignePar,
            date: summary.dateInscriptionRegistre,
          ),
          if (summary.remarques != null && summary.remarques!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: EpidemiologyTheme.warm50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: EpidemiologyTheme.warm100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes, size: 16, color: EpidemiologyTheme.slate400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      summary.remarques!,
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

  Widget _volet({
    required IconData icon,
    required String title,
    required bool ok,
    required String okLabel,
    required String koLabel,
    String? numero,
    DossierActor? acteur,
    DateTime? date,
  }) {
    final color = ok ? EpidemiologyTheme.success : EpidemiologyTheme.warning;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.22)),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate800,
                  ),
                ),
              ),
              Text(
                ok ? okLabel : koLabel,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          if (numero != null) ...[
            const SizedBox(height: 6),
            Text(
              numero,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: EpidemiologyTheme.slate900,
              ),
            ),
          ],
          if (acteur != null) ...[
            const SizedBox(height: 10),
            ActorBadge(actor: acteur, compact: true),
          ],
          if (date != null) ...[
            const SizedBox(height: 4),
            Text(
              'Le ${TraceabilityUi.dateHeure(date)}',
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
