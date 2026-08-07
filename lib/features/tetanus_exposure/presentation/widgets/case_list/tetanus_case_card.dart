import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';

/// Carte premium d'un cas tétanique pour la liste.
///
/// Hiérarchie visuelle forte : accent latéral par gravité, avatar initiales,
/// badges (dossier / vaccinal / décision), contexte de la plaie, bannière
/// contextuelle et affordance vers le dossier.
class TetanusCaseCard extends StatelessWidget {
  final TetanusPatientModel patient;
  final VoidCallback? onTap;

  const TetanusCaseCard({super.key, required this.patient, this.onTap});

  Color get _accent {
    if (patient.estUrgent) return EpidemiologyTheme.danger;
    if (patient.plaieTetaniegene) return EpidemiologyTheme.danger;
    if (patient.decision == TetanusDecision.rappelIndique) {
      return EpidemiologyTheme.warning;
    }
    if (patient.decision == TetanusDecision.vaccinationComplete) {
      return EpidemiologyTheme.info;
    }
    if (patient.statutDossier == TetanusDossierStatut.suiviClos) {
      return EpidemiologyTheme.success;
    }
    return EpidemiologyTheme.redPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
            border: Border.all(
              color: patient.estUrgent
                  ? EpidemiologyTheme.danger.withValues(alpha: 0.35)
                  : EpidemiologyTheme.warm100,
            ),
            boxShadow: [
              ...EpidemiologyTheme.shadowMd,
              BoxShadow(
                color: accent.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.25)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _header(accent),
                          const SizedBox(height: 12),
                          _chips(),
                          const SizedBox(height: 12),
                          _infoRows(),
                          const SizedBox(height: 12),
                          _banner(),
                          if (onTap != null) ...[
                            const SizedBox(height: 12),
                            const Divider(
                              height: 1,
                              color: EpidemiologyTheme.warm100,
                            ),
                            const SizedBox(height: 10),
                            _footer(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(Color accent) {
    return Row(
      children: [
        _initialsAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient.nomComplet,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.slate900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: EpidemiologyTheme.warm100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      patient.id,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: EpidemiologyTheme.warm500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${patient.age} ans · ${patient.sexe}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.warm400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (patient.estUrgent) _urgentChip(),
      ],
    );
  }

  Widget _initialsAvatar() {
    final colors = patient.estUrgent
        ? [EpidemiologyTheme.danger, EpidemiologyTheme.orange]
        : [EpidemiologyTheme.redMedium, EpidemiologyTheme.redPrimary];
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  String get _initials {
    final parts = patient.nomComplet.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Widget _chips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _chip(
          Icons.healing,
          patient.typePlaie.label,
          patient.plaieTetaniegene
              ? EpidemiologyTheme.danger
              : patient.typePlaie == TetanusWoundType.aRisque
              ? EpidemiologyTheme.warning
              : EpidemiologyTheme.success,
        ),
        _chip(
          patient.decisionIcon,
          patient.decision.label,
          patient.decisionColor,
          showIcon: true,
        ),
        if (patient.immunoglobulines)
          _chip(Icons.bloodtype_outlined, 'Ig', EpidemiologyTheme.indigo),
        if (patient.corpsEtranger)
          _chip(
            Icons.casino_outlined,
            'Corps étranger',
            EpidemiologyTheme.orange,
          ),
      ],
    );
  }

  Widget _chip(
    IconData icon,
    String label,
    Color color, {
    bool showIcon = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRows() {
    return Column(
      children: [
        _kv(Icons.my_location_outlined, 'Localisation', patient.localisation),
        _kv(Icons.event_outlined, 'Blessure', patient.dateBlessure),
        _kv(Icons.schedule, 'Délai', patient.delaiConsultation),
      ],
    );
  }

  Widget _kv(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: EpidemiologyTheme.warm400),
          const SizedBox(width: 7),
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: EpidemiologyTheme.warm400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: EpidemiologyTheme.slate700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner() {
    Widget? inner;
    if (patient.estUrgent) {
      inner = _bannerInner(
        color: EpidemiologyTheme.danger,
        icon: Icons.warning_amber_rounded,
        text: 'VAT + immunoglobulines à administrer sans délai',
      );
    } else if (patient.decision == TetanusDecision.rappelIndique) {
      inner = _bannerInner(
        color: EpidemiologyTheme.warning,
        icon: Icons.vaccines_outlined,
        text: 'Rappel VAT à planifier',
      );
    } else if (patient.necessiteIg) {
      inner = _bannerInner(
        color: EpidemiologyTheme.indigo,
        icon: Icons.bloodtype_outlined,
        text: 'Immunoglobulines requises',
      );
    } else if (patient.statutDossier == TetanusDossierStatut.perduDeVue) {
      inner = _bannerInner(
        color: EpidemiologyTheme.warm400,
        icon: Icons.visibility_off_outlined,
        text: 'Patient perdu de vue · suivi interrompu',
      );
    } else if (patient.statutDossier == TetanusDossierStatut.suiviClos) {
      inner = _bannerInner(
        color: EpidemiologyTheme.success,
        icon: Icons.check_circle_outline,
        text: 'Prise en charge terminée',
      );
    }

    if (inner == null) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.only(top: 8), child: inner);
  }

  Widget _bannerInner({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _urgentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EpidemiologyTheme.danger.withValues(alpha: 0.9),
            EpidemiologyTheme.orange.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.danger.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'URGENT',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Text(
            'Consulter le dossier',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.redPrimary,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward,
            size: 15,
            color: EpidemiologyTheme.redPrimary,
          ),
        ],
      ),
    );
  }
}

/// Extensions visuelles locales (fichier carte uniquement).
extension on TetanusPatientModel {
  IconData get decisionIcon {
    switch (decision) {
      case TetanusDecision.simpleSurveillance:
        return Icons.check_circle_outline;
      case TetanusDecision.rappelIndique:
        return Icons.vaccines_outlined;
      case TetanusDecision.vaccinationComplete:
        return Icons.medication_outlined;
      case TetanusDecision.vaccinationEtIg:
        return Icons.warning_amber_outlined;
      case TetanusDecision.avisSpecialise:
        return Icons.local_hospital_outlined;
    }
  }

  Color get decisionColor {
    switch (decision) {
      case TetanusDecision.simpleSurveillance:
        return EpidemiologyTheme.success;
      case TetanusDecision.rappelIndique:
        return EpidemiologyTheme.warning;
      case TetanusDecision.vaccinationComplete:
        return EpidemiologyTheme.info;
      case TetanusDecision.vaccinationEtIg:
        return EpidemiologyTheme.danger;
      case TetanusDecision.avisSpecialise:
        return EpidemiologyTheme.orange;
    }
  }
}
