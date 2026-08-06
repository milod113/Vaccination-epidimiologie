import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../widgets/tetanus_evaluation_controls.dart';

/// Héader hero premium de l'écran d'évaluation tétanos.
class TetanusEvaluationHero extends StatelessWidget {
  const TetanusEvaluationHero({
    super.key,
    required this.nom,
    required this.corps,
    required this.contexte,
    required this.statutLabel,
    required this.statutColor,
    required this.graviteLabel,
    required this.graviteColor,
    this.initials,
  });

  /// Nom du patient (ou « Nouvelle consultation »).
  final String nom;
  /// Ligne d'identité (ID · âge · sexe).
  final String corps;
  /// Contexte de consultation (ex : « Évaluation initiale »).
  final String contexte;
  final String graviteLabel;
  final Color graviteColor;
  final String statutLabel;
  final Color statutColor;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(22),
        boxShadow: EpidemiologyTheme.heroShadow(EpidemiologyTheme.redDeep),
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
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Text(
                  initials ?? (nom.split(' ').where((e) => e.isNotEmpty).take(2).map((e) => e[0]).join()),
                  style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.2),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      corps,
                      style: GoogleFonts.cairo(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.local_hospital_outlined, size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  contexte,
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.85)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TetanusBadge(
                label: graviteLabel,
                color: graviteColor,
                icon: Icons.shield_outlined,
              ),
              TetanusBadge(
                label: statutLabel,
                color: statutColor,
                icon: Icons.badge_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}