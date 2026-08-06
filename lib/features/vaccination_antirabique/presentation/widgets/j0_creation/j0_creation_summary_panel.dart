import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../j0_wizard/j0_ui.dart';
import 'j0_creation_steps.dart';

/// Panneau de synthèse clinique de la création J0.
///
/// Affiché en panneau latéral sur desktop ou dans l'étape de validation.
/// Restitue la décision en temps réel à partir de `J0CreationSummary`
/// (catégorie, PPE, ERIG, protocole, prochaine action, points à compléter)
/// sans refaire la logique métier.
class J0CreationSummaryPanel extends StatelessWidget {
  const J0CreationSummaryPanel({
    super.key,
    required this.summary,
    this.saving = false,
    this.onSaveDraft,
    this.onValidate,
  });

  final J0CreationSummary summary;
  final bool saving;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onValidate;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(summary.categorie);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_heart_outlined,
                  size: 18,
                  color: EpidemiologyTheme.redPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Résumé clinique · J0',
                  style: J0Ui.text(size: 14.5, weight: FontWeight.w800),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: summary.manquants.isEmpty
                      ? EpidemiologyTheme.successLight
                      : EpidemiologyTheme.warningLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  summary.manquants.isEmpty
                      ? 'Prêt'
                      : '${summary.manquants.length} à compléter',
                  style: J0Ui.text(
                    size: 11,
                    weight: FontWeight.w800,
                    color: summary.manquants.isEmpty
                        ? EpidemiologyTheme.successDark
                        : EpidemiologyTheme.warningDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CategoryHero(category: summary.categorie, color: categoryColor),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.shield_outlined,
            label: 'Prophylaxie post-exposition',
            value: summary.ppeIndiquee ? 'PPE indiquée' : 'PPE non indiquée',
            valueColor: summary.ppeIndiquee
                ? EpidemiologyTheme.redPrimary
                : EpidemiologyTheme.warm400,
          ),
          _SummaryRow(
            icon: Icons.bloodtype_outlined,
            label: 'Immunoglobulines (ERIG)',
            value: summary.erigIndiquee
                ? 'ERIG recommandée'
                : 'ERIG non recommandée',
            valueColor: summary.erigIndiquee
                ? EpidemiologyTheme.warning
                : EpidemiologyTheme.warm400,
          ),
          if (summary.protocole != null) ...[
            _SummaryRow(
              icon: Icons.vaccines_outlined,
              label: 'Protocole vaccinal',
              value: summary.protocole!,
              valueColor: EpidemiologyTheme.redPrimary,
            ),
            if (summary.protocoleDuree != null)
              _SummaryRow(
                icon: Icons.event_note_outlined,
                label: 'Durée du schéma',
                value: summary.protocoleDuree!,
                valueColor: EpidemiologyTheme.warm700,
              ),
          ],
          _SummaryRow(
            icon: Icons.next_plan_outlined,
            label: 'Prochaine action',
            value: summary.prochaineAction,
            valueColor: summary.synthese == DecisionSynthese.compatibleDemarrage
                ? EpidemiologyTheme.success
                : summary.synthese == DecisionSynthese.avisSpecialiseRequis
                    ? EpidemiologyTheme.danger
                    : EpidemiologyTheme.warning,
          ),
          const Divider(height: 24),
          _CompletionBlock(summary: summary),
          if (summary.manquants.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Points à compléter',
              style: J0Ui.text(
                  size: 12, weight: FontWeight.w800,
                  color: EpidemiologyTheme.warm500),
            ),
            const SizedBox(height: 8),
            ...summary.manquants.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 14, color: EpidemiologyTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        m,
                        style: J0Ui.text(
                          size: 12,
                          weight: FontWeight.w600,
                          color: EpidemiologyTheme.warm600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (onSaveDraft != null || onValidate != null) ...[
            const SizedBox(height: 18),
            if (onSaveDraft != null) ...[
              OutlinedButton.icon(
                onPressed: saving ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EpidemiologyTheme.redPrimary,
                  side: const BorderSide(
                      color: EpidemiologyTheme.redPrimary, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Enregistrer brouillon'),
              ),
              const SizedBox(height: 8),
            ],
            if (onValidate != null)
              FilledButton.icon(
                onPressed: saving ? null : onValidate,
                style: FilledButton.styleFrom(
                  backgroundColor: EpidemiologyTheme.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Valider la fiche J0'),
              ),
          ],
        ],
      ),
    );
  }

  Color _categoryColor(CategorieExposition? categorie) {
    switch (categorie) {
      case CategorieExposition.categorieI:
        return EpidemiologyTheme.success;
      case CategorieExposition.categorieII:
        return EpidemiologyTheme.warning;
      case CategorieExposition.categorieIII:
        return EpidemiologyTheme.danger;
      case null:
        return EpidemiologyTheme.warm400;
    }
  }
}

class _CategoryHero extends StatelessWidget {
  const _CategoryHero({required this.category, required this.color});

  final CategorieExposition? category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              category == null ? '—' : _roman(category!),
              style: J0Ui.text(
                size: 18,
                weight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catégorie de risque',
                  style: J0Ui.text(
                    size: 11,
                    weight: FontWeight.w600,
                    color: EpidemiologyTheme.warm400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category?.label ?? 'À déterminer',
                  style: J0Ui.text(
                    size: 15,
                    weight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category?.description ??
                      'Complétez l\'exposition pour calculer la catégorie.',
                  style: J0Ui.text(
                    size: 11,
                    weight: FontWeight.w500,
                    color: EpidemiologyTheme.warm500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roman(CategorieExposition c) {
    switch (c) {
      case CategorieExposition.categorieI:
        return 'I';
      case CategorieExposition.categorieII:
        return 'II';
      case CategorieExposition.categorieIII:
        return 'III';
    }
  }
}

class _CompletionBlock extends StatelessWidget {
  const _CompletionBlock({required this.summary});

  final J0CreationSummary summary;

  @override
  Widget build(BuildContext context) {
    final ratio = summary.completionRatio;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Complétude',
                style: J0Ui.text(
                    size: 11, weight: FontWeight.w600,
                    color: EpidemiologyTheme.warm400),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: EpidemiologyTheme.warm100,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    ratio >= 0.75
                        ? EpidemiologyTheme.success
                        : ratio >= 0.4
                            ? EpidemiologyTheme.warning
                            : EpidemiologyTheme.warm300,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${summary.completedSteps}/${summary.totalSteps} étapes',
          style: J0Ui.text(
            size: 12,
            weight: FontWeight.w800,
            color: EpidemiologyTheme.redPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm50,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: EpidemiologyTheme.warm500),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: J0Ui.text(
                    size: 11,
                    weight: FontWeight.w600,
                    color: EpidemiologyTheme.warm400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: J0Ui.text(
                    size: 13,
                    weight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
