import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/patient_antirabique_model.dart';
import 'status_badge.dart';

class PremiumPatientCardAntirabique extends StatelessWidget {
  final PatientAntirabiqueModel patient;
  final VoidCallback? onTap;

  const PremiumPatientCardAntirabique({
    super.key,
    required this.patient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRetard = patient.statut == StatutSuivi.perduDeVue;
    final bool isUrgent = patient.categorieExposition == CategorieExposition.categorieIII;
    final Color leftAccent = isUrgent
        ? EpidemiologyTheme.danger
        : isRetard
            ? EpidemiologyTheme.warning
            : EpidemiologyTheme.redPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
            boxShadow: [
              ...EpidemiologyTheme.shadowMd,
              BoxShadow(
                color: leftAccent.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [leftAccent, leftAccent.withValues(alpha: 0.3)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(EpidemiologyTheme.radiusXl),
                      bottomLeft: Radius.circular(EpidemiologyTheme.radiusXl),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isUrgent
                                      ? [EpidemiologyTheme.danger, EpidemiologyTheme.redMedium]
                                      : [EpidemiologyTheme.slate300, EpidemiologyTheme.slate400],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                              ),
                              child: Icon(
                                patient.sexe == 'Masculin' ? Icons.person : Icons.person_2,
                                color: EpidemiologyTheme.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    patient.nomComplet,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: EpidemiologyTheme.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${patient.age} ans · ${patient.sexe}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: EpidemiologyTheme.slate400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StatusBadge.suivi(patient.statut),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (patient.protocole != null)
                              EpidemiologyTheme.infoChip(Icons.medical_services, patient.protocole!.label, EpidemiologyTheme.redMedium),
                            EpidemiologyTheme.infoChip(Icons.calendar_today, patient.dateExposition, EpidemiologyTheme.slate500),
                            EpidemiologyTheme.infoChip(
                              Icons.category,
                              patient.categorieExposition?.label ?? 'À évaluer',
                              isUrgent ? EpidemiologyTheme.danger : EpidemiologyTheme.warning,
                            ),
                            if (patient.enAttenteEvaluation)
                              EpidemiologyTheme.infoChip(Icons.schedule, 'Éval. J0 à réaliser', EpidemiologyTheme.warning),
                            EpidemiologyTheme.infoChip(Icons.biotech, patient.animalStatut.label, EpidemiologyTheme.slate500),
                            if (patient.rigAdministree)
                              EpidemiologyTheme.infoChip(Icons.science, 'RIG+', EpidemiologyTheme.teal),
                            if (patient.prochainRendezVous != null)
                              EpidemiologyTheme.infoChip(Icons.event, 'RDV: ${patient.prochainRendezVous}', EpidemiologyTheme.teal),
                          ],
                        ),
                        if (isRetard) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [EpidemiologyTheme.dangerLight, EpidemiologyTheme.warningLight],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_rounded, size: 16, color: EpidemiologyTheme.danger),
                                const SizedBox(width: 6),
                                Text(
                                  'Patient en retard · Suivi à reprendre',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: EpidemiologyTheme.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}
