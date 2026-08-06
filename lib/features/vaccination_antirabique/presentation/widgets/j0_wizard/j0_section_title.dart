import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import 'j0_ui.dart';

/// Titre de sous-section avec icône et trait, style "SubSectionTitle"
/// de DossierAPP adapté au module antirabique.
class J0SectionTitle extends StatelessWidget {
  const J0SectionTitle(this.text, {super.key, this.icon, this.padding});

  final String text;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: EpidemiologyTheme.redPrimary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: J0Ui.text(
                size: 15,
                weight: FontWeight.w700,
                color: EpidemiologyTheme.redDeep,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
