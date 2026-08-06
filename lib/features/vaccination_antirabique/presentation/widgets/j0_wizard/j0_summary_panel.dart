import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_decision_summary.dart';
import 'j0_ui.dart';

/// Panneau de synthèse clinique temps réel.
///
/// Affiché en panneau latéral sur desktop (340 px) ou en cartouche dans
/// l'étape de validation. Il restitue la décision clinique produite par
/// `RabiesDecisionEngine` : catégorie, PPE, ERIG, protocole, prochaine dose
/// et alertes — sans jamais refaire la logique métier.
class J0SummaryPanel extends StatelessWidget {
  const J0SummaryPanel({
    super.key,
    required this.summary,
    this.criticalCount,
    this.saving = false,
    this.onSaveDraft,
    this.onValidate,
  });

  final RabiesDecisionSummary summary;
  final int? criticalCount;
  final bool saving;
  final VoidCallback? onSaveDraft;
  final VoidCallback? onValidate;

  @override
  Widget build(BuildContext context) {
    final crit = criticalCount ?? summary.alertesCritiques;
    final categoryColor = J0Ui.categoryColor(summary.categorie.categorie);

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
                  'Synthèse clinique',
                  style: J0Ui.text(size: 14.5, weight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: crit == 0
                      ? EpidemiologyTheme.successLight
                      : EpidemiologyTheme.warningLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  crit == 0 ? 'Prêt' : '$crit alerte(s)',
                  style: J0Ui.text(
                    size: 11,
                    weight: FontWeight.w800,
                    color: crit == 0
                        ? EpidemiologyTheme.successDark
                        : EpidemiologyTheme.warningDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Catégorie rabique',
            value: summary.categorie.categorie.label,
            valueColor: categoryColor,
          ),
          _SummaryRow(
            icon: Icons.shield_outlined,
            label: 'Prophylaxie post-exposition',
            value: summary.ppe.indiquee
                ? (summary.ppe.urgente ? 'PPE urgente' : 'PPE indiquée')
                : 'Pas de PPE',
            valueColor: summary.ppe.indiquee
                ? EpidemiologyTheme.redPrimary
                : EpidemiologyTheme.warm400,
          ),
          _SummaryRow(
            icon: Icons.bloodtype_outlined,
            label: 'Immunoglobulines (ERIG)',
            value: summary.erig.indiquee
                ? (summary.erig.administree ? 'ERIG administrée' : 'ERIG à administrer')
                : 'ERIG non indiquée',
            valueColor: summary.erig.indiquee
                ? (summary.erig.administree
                    ? EpidemiologyTheme.success
                    : EpidemiologyTheme.warning)
                : EpidemiologyTheme.warm400,
          ),
          if (summary.protocole != null) ...[
            _SummaryRow(
              icon: Icons.vaccines_outlined,
              label: 'Protocole vaccinal',
              value: summary.protocole!.type.label,
              valueColor: EpidemiologyTheme.redPrimary,
            ),
            _SummaryRow(
              icon: Icons.event_note_outlined,
              label: 'Schéma',
              value: summary.protocole!.schemaLabel,
              valueColor: EpidemiologyTheme.warm700,
            ),
          ],
          if (summary.prochaineDose != null) ...[
            _SummaryRow(
              icon: Icons.event_repeat_outlined,
              label: 'Prochaine dose',
              value: '${summary.prochaineDose!.etiquette} · ${summary.prochaineDose!.datePrevue == null ? 'à planifier' : _fmtDate(summary.prochaineDose!.datePrevue!)}',
              valueColor: summary.retard
                  ? EpidemiologyTheme.danger
                  : EpidemiologyTheme.success,
            ),
          ],
          if (summary.alertes.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Alertes',
              style: J0Ui.text(size: 12, weight: FontWeight.w800, color: EpidemiologyTheme.warm500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _AlertCountPill(
                  label: '${summary.alertesCritiques} critique(s)',
                  color: EpidemiologyTheme.danger,
                ),
                const SizedBox(width: 8),
                _AlertCountPill(
                  label: '${summary.alertesWarnings} avertissement(s)',
                  color: EpidemiologyTheme.warning,
                ),
              ],
            ),
          ],
          if (onSaveDraft != null || onValidate != null) ...[
            const SizedBox(height: 18),
            if (onSaveDraft != null) ...[
              OutlinedButton.icon(
                onPressed: saving ? null : onSaveDraft,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EpidemiologyTheme.redPrimary,
                  side: const BorderSide(color: EpidemiologyTheme.redPrimary, width: 1.4),
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
                  backgroundColor: EpidemiologyTheme.redPrimary,
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
                label: const Text('Valider J0'),
              ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
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

class _AlertCountPill extends StatelessWidget {
  const _AlertCountPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: J0Ui.text(
          size: 11,
          weight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}