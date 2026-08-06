import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_clinical_alert.dart';
import 'j0_ui.dart';

/// Bannière d'alerte clinique premium (info / avertissement / critique),
/// inspirée du `AlertBanner` de DossierAPP.
class J0AlertBanner extends StatelessWidget {
  const J0AlertBanner({super.key, required this.alert, this.onTap});

  final RabiesClinicalAlert alert;
  final VoidCallback? onTap;

  Color get _color {
    switch (alert.severity) {
      case RabiesAlertSeverity.critical:
        return EpidemiologyTheme.danger;
      case RabiesAlertSeverity.warning:
        return EpidemiologyTheme.warning;
      case RabiesAlertSeverity.info:
        return EpidemiologyTheme.redPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(alert.icon, color: color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.titre,
                    style: J0Ui.text(
                      size: 13.5,
                      weight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alert.message,
                    style: J0Ui.text(
                      size: 12.5,
                      weight: FontWeight.w500,
                      color: EpidemiologyTheme.warm700,
                    ),
                  ),
                  if (alert.recommendation != null) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 13,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '→ ${alert.recommendation}',
                              style: J0Ui.text(
                                size: 12,
                                weight: FontWeight.w700,
                                color: color,
                              ),
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
      ),
    );
  }
}