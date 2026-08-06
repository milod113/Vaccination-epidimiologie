import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import '../../domain/services/tetanus_evaluation_service.dart';

/// Carte centrale mettant en avant le niveau de risque tétanique.
class TetanusRiskCard extends StatelessWidget {
  const TetanusRiskCard({
    super.key,
    required this.input,
    required this.resolution,
  });

  final TetanusEvaluationInput input;
  final TetanusDecisionResolution resolution;

  (Color, IconData) get _riskViz {
    switch (resolution.risk) {
      case TetanusRiskLevel.faible:
        return (EpidemiologyTheme.success, Icons.verified_rounded);
      case TetanusRiskLevel.moyen:
        return (EpidemiologyTheme.warning, Icons.info_outline_rounded);
      case TetanusRiskLevel.eleve:
        return (EpidemiologyTheme.danger, Icons.warning_amber_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _riskViz;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Niveau de risque',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: color.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resolution.risk.label,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              _riskBar(color),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: color),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    resolution.risk.description,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      height: 1.45,
                      color: EpidemiologyTheme.warm700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _factorChip(
                Icons.healing,
                input.typePlaie.label,
                input.typePlaie == TetanusWoundType.tetanigene
                    ? EpidemiologyTheme.danger
                    : input.typePlaie == TetanusWoundType.aRisque
                        ? EpidemiologyTheme.warning
                        : EpidemiologyTheme.success,
              ),
              if (input.corpsEtranger)
                _factorChip(Icons.casino_outlined, 'Corps étranger', color),
              if (input.profond)
                _factorChip(Icons.arrow_downward, 'Profonde', color),
              if (input.souillee)
                _factorChip(Icons.grass, 'Souillée', color),
            ],
          ),
        ],
      ),
    );
  }

  int get _riskIndex {
    switch (resolution.risk) {
      case TetanusRiskLevel.faible:
        return 0;
      case TetanusRiskLevel.moyen:
        return 1;
      case TetanusRiskLevel.eleve:
        return 2;
    }
  }

  Widget _riskBar(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (k) {
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: k <= _riskIndex ? 1 : 0.22),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _factorChip(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.warm700,
            ),
          ),
        ],
      ),
    );
  }
}