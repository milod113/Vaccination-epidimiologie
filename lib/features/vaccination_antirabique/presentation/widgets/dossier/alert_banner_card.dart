import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_clinical_alert.dart';

/// Bannière d'alertes cliniques, codée par sévérité (info / warning / critical).
class AlertBannerCard extends StatelessWidget {
  final List<RabiesClinicalAlert> alerts;
  final VoidCallback? onCta;

  const AlertBannerCard({super.key, required this.alerts, this.onCta});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    final critical = alerts.any((a) => a.severity == RabiesAlertSeverity.critical);
    final severity = critical
        ? RabiesAlertSeverity.critical
        : alerts.any((a) => a.severity == RabiesAlertSeverity.warning)
            ? RabiesAlertSeverity.warning
            : RabiesAlertSeverity.info;
    final color = switch (severity) {
      RabiesAlertSeverity.critical => EpidemiologyTheme.danger,
      RabiesAlertSeverity.warning => EpidemiologyTheme.warning,
      RabiesAlertSeverity.info => EpidemiologyTheme.info,
    };
    final bg = switch (severity) {
      RabiesAlertSeverity.critical => EpidemiologyTheme.dangerLight,
      RabiesAlertSeverity.warning => EpidemiologyTheme.warningLight,
      RabiesAlertSeverity.info => EpidemiologyTheme.infoLight,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                critical ? Icons.gpp_maybe : Icons.report_problem,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${alerts.length} point${alerts.length > 1 ? 's' : ''} d\'attention',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final a in alerts)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(a.icon, size: 15, color: _lineColor(a.severity)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${a.titre} — ${a.message}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: _lineColor(a.severity),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (onCta != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onCta,
                icon: const Icon(Icons.timeline, size: 15),
                label: const Text('Ouvrir le suivi'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _lineColor(RabiesAlertSeverity s) => switch (s) {
    RabiesAlertSeverity.critical => EpidemiologyTheme.danger,
    RabiesAlertSeverity.warning => EpidemiologyTheme.warningDark,
    RabiesAlertSeverity.info => EpidemiologyTheme.slate600,
  };
}