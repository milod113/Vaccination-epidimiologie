import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import 'j0_ui.dart';

/// Barre de navigation d'étape du wizard (bas d'écran) : Précédent,
/// compteur d'étape, Enregistrer brouillon et Suivant / Valider J0.
class J0StepNavigationBar extends StatelessWidget {
  const J0StepNavigationBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.hasPrevious,
    required this.isLast,
    this.saving = false,
    required this.onPrevious,
    required this.onNext,
    required this.onSaveDraft,
    required this.onValidate,
  });

  final int currentIndex;
  final int totalSteps;
  final bool hasPrevious;
  final bool isLast;
  final bool saving;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSaveDraft;
  final VoidCallback onValidate;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 640;

    return Container(
      width: double.infinity,
      color: EpidemiologyTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (hasPrevious)
              OutlinedButton.icon(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  foregroundColor: EpidemiologyTheme.redPrimary,
                  side: const BorderSide(
                    color: EpidemiologyTheme.redPrimary,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: isWide
                    ? const Text('Précédent')
                    : const SizedBox.shrink(),
              ),
            const Spacer(),
            if (isWide) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warm50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Étape ${currentIndex + 1} / $totalSteps',
                  style: J0Ui.text(
                    size: 12.5,
                    weight: FontWeight.w700,
                    color: EpidemiologyTheme.warm600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            OutlinedButton.icon(
              onPressed: saving ? null : onSaveDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: EpidemiologyTheme.warm600,
                side: const BorderSide(color: EpidemiologyTheme.warm150),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.save_outlined, size: 18),
              label: isWide
                  ? const Text('Brouillon')
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: saving ? null : (isLast ? onValidate : onNext),
              style: FilledButton.styleFrom(
                backgroundColor: isLast
                    ? EpidemiologyTheme.success
                    : EpidemiologyTheme.redPrimary,
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
                  : Icon(
                      isLast ? Icons.check_circle_outline : Icons.arrow_forward,
                      size: 18,
                    ),
              label: Text(isLast ? 'Valider J0' : 'Suivant'),
            ),
          ],
        ),
      ),
    );
  }
}