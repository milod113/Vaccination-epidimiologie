import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/patient_antirabique_model.dart';
import 'patient_list_models.dart';
import 'patient_status_badge.dart';

/// Carte patient premium pour la liste antirabique.
///
/// Hiérarchie visuelle forte : accent latéral par gravité, avatar initiales,
/// badges de statut / catégorie / protocole, exposition et rendez-vous relatifs,
/// bannière contextuelle et affordance vers le dossier.
class PremiumRabiesPatientCard extends StatelessWidget {
  final PatientAntirabiqueModel patient;
  final VoidCallback? onTap;

  const PremiumRabiesPatientCard({
    super.key,
    required this.patient,
    this.onTap,
  });

  DateTime get _today {
    final t = DateTime.now();
    return DateTime(t.year, t.month, t.day);
  }

  @override
  Widget build(BuildContext context) {
    final now = _today;
    final overdue = patientEnRetard(patient, now);
    final dueToday = patientDueAujourdhui(patient, now);
    final riskColor = _accentColor(now);

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
              color: dueToday
                  ? EpidemiologyTheme.warning.withValues(alpha: 0.5)
                  : (overdue
                      ? EpidemiologyTheme.danger.withValues(alpha: 0.35)
                      : EpidemiologyTheme.warm100),
            ),
            boxShadow: [
              ...EpidemiologyTheme.shadowMd,
              BoxShadow(
                color: riskColor.withValues(alpha: 0.04),
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
                        colors: [riskColor, riskColor.withValues(alpha: 0.25)],
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
                          _header(),
                          const SizedBox(height: 12),
                          _chips(),
                          const SizedBox(height: 12),
                          _infoRows(),
                          const SizedBox(height: 12),
                          _rdvRow(now, overdue, dueToday),
                          _banner(now, overdue, dueToday),
                          if (onTap != null) ...[
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: EpidemiologyTheme.warm100),
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

  Color _accentColor(DateTime now) {
    if (patient.categorieExposition == CategorieExposition.categorieIII) {
      return EpidemiologyTheme.danger;
    }
    if (patientEnRetard(patient, now)) return EpidemiologyTheme.warning;
    if (patient.statut == StatutSuivi.termine) return EpidemiologyTheme.success;
    if (patient.rigAdministree) return EpidemiologyTheme.teal;
    return EpidemiologyTheme.redPrimary;
  }

  Widget _header() {
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        _statusBadge(),
      ],
    );
  }

  Widget _statusBadge() {
    final statut = patient.statut;
    if (patientEnRetard(patient)) {
      if (statut == StatutSuivi.perduDeVue) {
        return PatientStatusBadge.suivi(statut);
      }
      return PatientStatusBadge.enRetard(joursDeRetard(patient));
    }
    return PatientStatusBadge.suivi(statut);
  }

  Widget _initialsAvatar() {
    final colors = patient.categorieExposition == CategorieExposition.categorieIII
        ? [EpidemiologyTheme.danger, EpidemiologyTheme.redMedium]
        : patientEnRetard(patient)
            ? [EpidemiologyTheme.warning, EpidemiologyTheme.orange]
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
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  Widget _chips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        PatientRiskPill(categorie: patient.categorieExposition),
        if (patient.protocole != null)
          _chip(Icons.vaccines, patient.protocole!.label, EpidemiologyTheme.indigo),
        if (patient.rigAdministree)
          _chip(Icons.science_outlined, 'ERIG', EpidemiologyTheme.teal),
        if (patient.immunocompromis)
          _chip(Icons.shield_outlined, 'Immunodéprimé', EpidemiologyTheme.warning),
        _chip(Icons.pets, patient.animalStatut.label, EpidemiologyTheme.slate500),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
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
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
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
        _kv(Icons.medical_information_outlined, 'Exposition', _expoLabel()),
        if (patient.animalSource != null)
          _kv(Icons.pets_outlined, 'Animal', patient.animalSource!),
      ],
    );
  }

  String _expoLabel() {
    final base = patient.typeExposition?.label ?? 'Non évaluée';
    if (patient.siteMorsure == null || patient.siteMorsure!.isEmpty) return base;
    return '$base — ${patient.siteMorsure}';
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

  Widget _rdvRow(DateTime now, bool overdue, bool dueToday) {
    final color = overdue
        ? EpidemiologyTheme.danger
        : dueToday
            ? EpidemiologyTheme.warning
            : EpidemiologyTheme.teal;
    final icon = overdue
        ? Icons.schedule
        : dueToday
            ? Icons.notifications_active
            : Icons.event_available_outlined;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              'Prochain RDV : ${libelleRendezVous(patient, now)}'
              '${patient.prochainRendezVous != null ? ' · ${formatDateIso(patient.prochainRendezVous)}' : ''}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _banner(DateTime now, bool overdue, bool dueToday) {
    Widget? inner;
    if (dueToday) {
      inner = _bannerInner(
        color: EpidemiologyTheme.warning,
        icon: Icons.notifications_active,
        text: 'Dose à administrer aujourd\'hui',
      );
    } else if (overdue && patient.statut != StatutSuivi.perduDeVue) {
      inner = _bannerInner(
        color: EpidemiologyTheme.danger,
        icon: Icons.warning_amber_rounded,
        text: 'Rendez-vous dépassé · suivi à reprendre',
      );
    } else if (patient.enAttenteEvaluation) {
      inner = _bannerInner(
        color: EpidemiologyTheme.orange,
        icon: Icons.rule_outlined,
        text: 'Évaluation J0 à réaliser',
      );
    } else if (patient.statut == StatutSuivi.termine) {
      inner = _bannerInner(
        color: EpidemiologyTheme.success,
        icon: Icons.check_circle_outline,
        text: 'Schéma vaccinal terminé',
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
          const Icon(Icons.arrow_forward, size: 15, color: EpidemiologyTheme.redPrimary),
        ],
      ),
    );
  }
}
