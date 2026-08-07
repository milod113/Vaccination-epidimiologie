import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';
import 'tetanus_act_ui.dart';

/// Récapitulatif pré-validation de l'acte à enregistrer.
///
/// Affiche les informations saisies et la liste des éléments manquants.
class TetanusActSummaryCard extends StatelessWidget {
  const TetanusActSummaryCard({
    super.key,
    required this.type,
    required this.missing,
    required this.onSubmit,
    required this.submitting,
  });

  final TetanusActType type;
  final List<String> missing;
  final VoidCallback onSubmit;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    final color = tetanusActColor(type);
    final ready = missing.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ready
            ? EpidemiologyTheme.successLight.withValues(alpha: 0.5)
            : EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ready
              ? EpidemiologyTheme.success.withValues(alpha: 0.3)
              : EpidemiologyTheme.warm150,
        ),
        boxShadow: EpidemiologyTheme.shadowCard(color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (ready ? EpidemiologyTheme.success : color).withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  ready
                      ? Icons.check_circle_outline
                      : Icons.fact_check_outlined,
                  size: 20,
                  color: ready ? EpidemiologyTheme.success : color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ready ? 'Acte prêt à être enregistré' : 'Acte incomplet',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.warm900,
                      ),
                    ),
                    Text(
                      ready
                          ? 'Vérifiez puis validez l\'enregistrement'
                          : 'Complétez les champs requis ci-dessous',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: EpidemiologyTheme.warm400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!ready) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in missing)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: EpidemiologyTheme.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: EpidemiologyTheme.danger.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 13,
                          color: EpidemiologyTheme.danger,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          m,
                          style: GoogleFonts.cairo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: ready ? onSubmit : null,
              icon: submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      ready ? Icons.verified_outlined : Icons.lock_outline,
                      size: 18,
                    ),
              label: Text(
                submitting ? 'Enregistrement…' : 'Enregistrer l\'acte',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: EpidemiologyTheme.warm200,
                disabledForegroundColor: EpidemiologyTheme.warm400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
