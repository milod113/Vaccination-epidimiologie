import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import 'j0_completion_badge.dart';
import 'j0_step_model.dart';
import 'j0_ui.dart';

/// En-tête premium d'une étape du wizard : bandeau dégradé bleu avec numéro,
/// icône, titre, sous-titre et badge de complétude. S'inspire du header
/// `MedicalCard` de DossierAPP en version "hero".
class J0StepCard extends StatelessWidget {
  const J0StepCard({
    super.key,
    required this.step,
    required this.index,
    required this.total,
    required this.status,
    this.trailing,
    required this.child,
  });

  final J0StepData step;
  final int index;
  final int total;
  final J0StepStatus status;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final statusColor = J0Ui.statusColor(status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              gradient: EpidemiologyTheme.primaryGradientWarm,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Icon(step.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÉTAPE ${step.number} · ${index + 1} / $total',
                        style: J0Ui.text(
                          size: 10.5,
                          weight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.title,
                        style: J0Ui.text(
                          size: 17,
                          weight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        step.subtitle,
                        style: J0Ui.text(
                          size: 12,
                          weight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    J0CompletionBadge(status: status),
                    if (trailing != null) ...[
                      const SizedBox(height: 8),
                      trailing!,
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (status == J0StepStatus.toReview)
            Container(
              height: 3,
              color: statusColor,
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}
