import 'package:flutter/material.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Squelette de chargement premium de la liste des cas tétaniques.
///
/// Reproduit la structure des cartes cas (avatar, nom, badges, lignes
/// d'info) pour un état de chargement réaliste, adapté à la grille responsive.
class TetanusCaseSkeleton extends StatelessWidget {
  const TetanusCaseSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 1100
            ? 3
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        final gap = 14.0;
        final width = (constraints.maxWidth - gap * (cols - 1)) / cols;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < 6; i++)
              _card(width: width, tall: cols > 1),
          ],
        );
      },
    );
  }

  Widget _card({required double width, required bool tall}) {
    return Container(
      width: width,
      height: tall ? 224 : 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EpidemiologyTheme.shimmerBox(width: 46, height: 46, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EpidemiologyTheme.shimmerBox(width: 130, height: 16),
                    const SizedBox(height: 7),
                    EpidemiologyTheme.shimmerBox(width: 90, height: 12),
                  ],
                ),
              ),
              EpidemiologyTheme.shimmerBox(width: 86, height: 24, radius: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              EpidemiologyTheme.shimmerBox(width: 62, height: 22, radius: 8),
              const SizedBox(width: 8),
              EpidemiologyTheme.shimmerBox(width: 84, height: 22, radius: 8),
              const SizedBox(width: 8),
              EpidemiologyTheme.shimmerBox(width: 56, height: 22, radius: 8),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
              height: 1, thickness: 1, color: EpidemiologyTheme.warm100),
          const SizedBox(height: 12),
          Row(
            children: [
              EpidemiologyTheme.shimmerBox(width: 26, height: 14, radius: 6),
              const SizedBox(width: 10),
              Expanded(
                child: EpidemiologyTheme.shimmerBox(height: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              EpidemiologyTheme.shimmerBox(width: 26, height: 14, radius: 6),
              const SizedBox(width: 10),
              Expanded(
                child: EpidemiologyTheme.shimmerBox(height: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}