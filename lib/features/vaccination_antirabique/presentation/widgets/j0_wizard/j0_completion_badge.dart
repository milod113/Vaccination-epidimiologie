import 'package:flutter/material.dart';

import 'j0_step_model.dart';
import 'j0_ui.dart';

/// Pastille de complétude d'une étape (non commencée / en cours / complète /
/// à vérifier), utilisée dans le stepper et sur les cartes d'étape.
class J0CompletionBadge extends StatelessWidget {
  const J0CompletionBadge({super.key, required this.status, this.compact = false});

  final J0StepStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = J0Ui.statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(J0Ui.statusIcon(status), size: compact ? 12 : 14, color: color),
          if (!compact) ...[
            const SizedBox(width: 5),
            Text(
              status.label,
              style: J0Ui.text(
                size: 11,
                weight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
