import 'package:flutter/material.dart';

import '../../../../../core/theme/epidemiology_theme.dart';
import 'j0_step_model.dart';
import 'j0_ui.dart';

/// Stepper vertical / horizontal premium pour le wizard J0.
///
/// Sur grand écran, toutes les étapes sont affichées sur une seule ligne
/// horizontale (avec connecteurs de progression). Sur mobile, la barre est
/// compacte et défilable horizontalement. Chaque étape montre sa complétude :
/// ✓ verte quand terminée, ⚠ quand à vérifier, numéro en surbrillance quand
/// active, ternie quand non commencée.
class J0StepperHeader extends StatelessWidget {
  const J0StepperHeader({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.statusOf,
    required this.onTap,
  });

  final List<J0StepData> steps;
  final int currentIndex;
  final J0StepStatus Function(int index) statusOf;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960;
    final itemWidth = isDesktop ? 132.0 : 92.0;
    final connectorWidth = isDesktop ? 26.0 : 18.0;

    return Container(
      width: double.infinity,
      color: EpidemiologyTheme.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < steps.length; i++) ...[
              _StepItem(
                step: steps[i],
                isCurrent: i == currentIndex,
                status: statusOf(i),
                onTap: () => onTap(i),
                width: itemWidth,
              ),
              if (i < steps.length - 1)
                _Connector(
                  width: connectorWidth,
                  done: _isDone(i),
                ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isDone(int index) {
    // Connexion "verte" quand l'étape précédente est complète.
    final status = statusOf(index);
    return status == J0StepStatus.complete || index < currentIndex;
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.width, required this.done});

  final double width;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: width,
        child: Container(
          height: 2,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: done ? EpidemiologyTheme.success : EpidemiologyTheme.warm150,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.step,
    required this.isCurrent,
    required this.status,
    required this.onTap,
    required this.width,
  });

  final J0StepData step;
  final bool isCurrent;
  final J0StepStatus status;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Circle(step: step, status: status, isCurrent: isCurrent),
              const SizedBox(height: 8),
              Text(
                step.shortTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: J0Ui.text(
                  size: isCurrent ? 12.5 : 12,
                  weight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent
                      ? EpidemiologyTheme.redPrimary
                      : status == J0StepStatus.complete
                          ? EpidemiologyTheme.successDark
                          : EpidemiologyTheme.warm500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.step, required this.status, required this.isCurrent});

  final J0StepData step;
  final J0StepStatus status;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final IconData? icon;
    Color? ring;

    if (status == J0StepStatus.complete) {
      bg = EpidemiologyTheme.success;
      fg = Colors.white;
      icon = Icons.check_rounded;
    } else if (status == J0StepStatus.toReview) {
      bg = EpidemiologyTheme.warningLight;
      fg = EpidemiologyTheme.warning;
      icon = Icons.error_outline_rounded;
    } else if (isCurrent) {
      bg = EpidemiologyTheme.redPrimary;
      fg = Colors.white;
      icon = null;
      ring = EpidemiologyTheme.redDeep;
    } else if (status == J0StepStatus.inProgress) {
      bg = EpidemiologyTheme.redLight;
      fg = EpidemiologyTheme.redPrimary;
      icon = null;
    } else {
      bg = EpidemiologyTheme.warm100;
      fg = EpidemiologyTheme.warm300;
      icon = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: ring == null ? null : Border.all(color: ring, width: 2.5),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.35),
                  blurRadius: 9,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: icon != null
          ? Icon(icon, color: fg, size: 18)
          : Text(
              step.number,
              style: J0Ui.text(
                size: 12.5,
                weight: FontWeight.w800,
                color: fg,
              ),
            ),
    );
  }
}