import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';
import '../../../domain/services/tetanus_evaluation_service.dart';
import '../tetanus_evaluation_controls.dart';

/// Héros premium du détail d'un cas tétanique.
///
/// Affiche l'identité du patient, le niveau de risque tétanique, le statut
/// du dossier et le statut vaccinal, avec une bannière d'urgence éventuelle.
class TetanusCaseDetailHero extends StatelessWidget {
  final TetanusPatientModel patient;
  final TetanusRiskLevel risk;
  final VoidCallback? onBack;

  const TetanusCaseDetailHero({
    super.key,
    required this.patient,
    required this.risk,
    this.onBack,
  });

  Color get _riskColor => switch (risk) {
        TetanusRiskLevel.faible => EpidemiologyTheme.success,
        TetanusRiskLevel.moyen => EpidemiologyTheme.warning,
        TetanusRiskLevel.eleve => EpidemiologyTheme.danger,
      };

  Color get _dossierColor => switch (patient.statutDossier) {
        TetanusDossierStatut.enCours => EpidemiologyTheme.info,
        TetanusDossierStatut.acteEffectue => EpidemiologyTheme.teal,
        TetanusDossierStatut.suiviClos => EpidemiologyTheme.success,
        TetanusDossierStatut.perduDeVue => EpidemiologyTheme.warm400,
      };

  @override
  Widget build(BuildContext context) {
    final initiales = patient.nomComplet
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0])
        .join();

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
              if (onBack != null) ...[
                _backButton(),
                const SizedBox(width: 10),
              ],
              Container(
                width: 54,
                height: 54,
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
                  initiales,
                  style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nomComplet,
                      style: GoogleFonts.cairo(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${patient.id} · ${patient.age} ans · ${patient.sexe}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (patient.estUrgent)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.danger,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: EpidemiologyTheme.danger.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'URGENT',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.event_outlined,
                  size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Blessure le ${patient.dateBlessure} · '
                  '${patient.typePlaie.label}',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
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
                label: 'Risque ${risk.label}',
                color: _riskColor,
                icon: Icons.shield_outlined,
              ),
              TetanusBadge(
                label: patient.statutDossier.label,
                color: _dossierColor,
                icon: Icons.badge_outlined,
              ),
              TetanusBadge(
                label: patient.statutVaccinal.label,
                color: patient.statutVaccinal == TetanusVaccinStatus.aJour
                    ? EpidemiologyTheme.success
                    : EpidemiologyTheme.warning,
                icon: Icons.vaccines_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}