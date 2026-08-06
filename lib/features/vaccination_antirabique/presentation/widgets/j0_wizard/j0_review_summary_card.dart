import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/models/dossier/rabies_decision_summary.dart';
import 'j0_completion_badge.dart';
import 'j0_step_model.dart';
import 'j0_ui.dart';

/// Carte de révision finale affichée dans l'étape "Résumé · Validation".
///
/// Récapitule la complétude des 8 étapes, la décision clinique et l'état de
/// la traçabilité avant validation de la fiche J0.
class ReviewSummaryCard extends StatelessWidget {
  const ReviewSummaryCard({
    super.key,
    required this.record,
    required this.summary,
    required this.steps,
    required this.statuses,
  });

  final RabiesCaseRecord record;
  final RabiesDecisionSummary summary;
  final List<J0StepData> steps;
  final List<J0StepStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final completed = statuses.where((s) => s == J0StepStatus.complete).length;
    final toReview = statuses.where((s) => s == J0StepStatus.toReview).length;

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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: EpidemiologyTheme.primaryGradientWarm,
            ),
            child: Row(
              children: [
                const Icon(Icons.fact_check_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Révision avant validation',
                    style: J0Ui.text(
                      size: 15,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$completed / ${steps.length} étapes complètes',
                    style: J0Ui.text(
                      size: 11,
                      weight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < steps.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          steps[i].icon,
                          size: 17,
                          color: J0Ui.statusColor(statuses[i]),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${steps[i].number} · ${steps[i].title}',
                            style: J0Ui.text(
                              size: 13,
                              weight: FontWeight.w700,
                              color: EpidemiologyTheme.warm800,
                            ),
                          ),
                        ),
                        J0CompletionBadge(status: statuses[i], compact: true),
                      ],
                    ),
                  ),
                const Divider(height: 26),
                Text(
                  'Décision clinique',
                  style: J0Ui.text(
                    size: 12,
                    weight: FontWeight.w800,
                    color: EpidemiologyTheme.warm500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FactPill(
                      label: summary.categorie.categorie.label,
                      color: J0Ui.categoryColor(summary.categorie.categorie),
                    ),
                    const SizedBox(width: 8),
                    _FactPill(
                      label: summary.ppe.indiquee ? 'PPE' : 'Pas de PPE',
                      color: summary.ppe.indiquee
                          ? EpidemiologyTheme.redPrimary
                          : EpidemiologyTheme.warm400,
                    ),
                    const SizedBox(width: 8),
                    _FactPill(
                      label: summary.erig.indiquee
                          ? 'ERIG ${summary.erig.administree ? 'administrée' : 'à administrer'}'
                          : 'Sans ERIG',
                      color: summary.erig.indiquee
                          ? (summary.erig.administree
                              ? EpidemiologyTheme.success
                              : EpidemiologyTheme.warning)
                          : EpidemiologyTheme.warm400,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _FactPill(
                      label: toReview > 0
                          ? '$toReview étape(s) à vérifier'
                          : 'Aucune alerte critique',
                      color: toReview > 0
                          ? EpidemiologyTheme.warning
                          : EpidemiologyTheme.success,
                    ),
                    const SizedBox(width: 8),
                    _FactPill(
                      label: record.tracabilite.statut.label,
                      color: record.tracabilite.statut == TraceabilityStatus.complete
                          ? EpidemiologyTheme.success
                          : EpidemiologyTheme.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FactPill extends StatelessWidget {
  const _FactPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: J0Ui.text(
          size: 11.5,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}