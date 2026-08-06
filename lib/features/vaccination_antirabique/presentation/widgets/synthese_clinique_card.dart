import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/evaluation_initiale_model.dart';

class SyntheseCliniqueCard extends StatelessWidget {
  final InitialRabiesAssessment evaluation;

  const SyntheseCliniqueCard({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final synthese = evaluation.synthese;

    final (Color accent, Color lightBg, IconData icon, String badgeLabel) =
        switch (synthese) {
      DecisionSynthese.compatibleDemarrage => (
        EpidemiologyTheme.success,
        EpidemiologyTheme.successLight,
        Icons.check_circle_rounded,
        'Protocole autorisé',
      ),
      DecisionSynthese.precautionsComplementaires => (
        EpidemiologyTheme.warning,
        EpidemiologyTheme.warningLight,
        Icons.shield_rounded,
        'Précautions à prendre',
      ),
      DecisionSynthese.avisSpecialiseRequis => (
        EpidemiologyTheme.danger,
        EpidemiologyTheme.dangerLight,
        Icons.warning_amber_rounded,
        'Avis spécialisé requis',
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: EpidemiologyTheme.spaceMd),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        boxShadow: [
          ...EpidemiologyTheme.shadowSm,
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRibbon(accent, lightBg, icon, badgeLabel, synthese),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              EpidemiologyTheme.spaceXl,
              EpidemiologyTheme.spaceLg,
              EpidemiologyTheme.spaceXl,
              EpidemiologyTheme.spaceXl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryBlock(accent),
                const SizedBox(height: EpidemiologyTheme.spaceLg),
                _buildDetailBlocks(),
                const SizedBox(height: EpidemiologyTheme.spaceLg),
                _buildMetaRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRibbon(
    Color accent,
    Color lightBg,
    IconData icon,
    String badgeLabel,
    DecisionSynthese synthese,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        EpidemiologyTheme.spaceXl,
        EpidemiologyTheme.spaceMd,
        EpidemiologyTheme.spaceXl,
        EpidemiologyTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightBg, lightBg.withValues(alpha: 0.3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(EpidemiologyTheme.radiusXl),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(EpidemiologyTheme.radiusMd),
            ),
            child: Icon(icon, size: 24, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Synthèse clinique',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  synthese.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate900,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          _badgePill(badgeLabel, accent),
        ],
      ),
    );
  }

  Widget _badgePill(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }

  Widget _buildSummaryBlock(Color accent) {
    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceLg),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.04),
        borderRadius:
            BorderRadius.circular(EpidemiologyTheme.radiusLg),
        border: Border.all(
          color: accent.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              evaluation.messageSynthese,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.7,
                color: EpidemiologyTheme.slate700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBlocks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (evaluation.observationsCliniques != null &&
            evaluation.observationsCliniques!.isNotEmpty)
          _detailField(
            'Observations cliniques',
            evaluation.observationsCliniques!,
          ),
        if (evaluation.conclusionMedicale != null &&
            evaluation.conclusionMedicale!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: evaluation.observationsCliniques != null &&
                      evaluation.observationsCliniques!.isNotEmpty
                  ? EpidemiologyTheme.spaceSm
                  : 0,
            ),
            child: _detailField(
              'Conclusion médicale',
              evaluation.conclusionMedicale!,
            ),
          ),
      ],
    );
  }

  Widget _detailField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceMd),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.slate50,
        borderRadius:
            BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(
          color: EpidemiologyTheme.slate100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.slate500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: EpidemiologyTheme.slate800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _metaChip(
          Icons.person_outline,
          evaluation.medecinEvaluateur ?? 'Non renseigné',
        ),
        _metaChip(
          Icons.calendar_today,
          evaluation.dateEvaluation,
        ),
        if (evaluation.centre != null && evaluation.centre!.isNotEmpty)
          _metaChip(
            Icons.business_outlined,
            evaluation.centre!,
          ),
      ],
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.slate50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: EpidemiologyTheme.slate100,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: EpidemiologyTheme.slate500),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.slate600,
            ),
          ),
        ],
      ),
    );
  }
}
