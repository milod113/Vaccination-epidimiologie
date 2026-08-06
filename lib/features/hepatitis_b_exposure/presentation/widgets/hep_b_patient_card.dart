import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/hep_b_models.dart';
import 'hep_b_status_badge.dart';

class HepBPatientCard extends StatelessWidget {
  final HepBExposurePatient patient;
  final VoidCallback? onTap;

  const HepBPatientCard({super.key, required this.patient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
          border: Border.all(
            color: patient.niveauRisque.color.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            ...EpidemiologyTheme.shadowSm,
            BoxShadow(
              color: patient.niveauRisque.color.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [EpidemiologyTheme.indigo, Color(0xFF3730A3)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: EpidemiologyTheme.indigo.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${patient.prenom[0]}${patient.nom[0]}',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: EpidemiologyTheme.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.nomComplet,
                        style: EpidemiologyTheme.subtitle(color: EpidemiologyTheme.warm800),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.medical_services_outlined,
                            size: 12, color: EpidemiologyTheme.indigo),
                          const SizedBox(width: 4),
                          Text(
                            patient.typeExposition.label,
                            style: EpidemiologyTheme.caption(color: EpidemiologyTheme.indigo),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${patient.age} ans',
                            style: EpidemiologyTheme.caption(color: EpidemiologyTheme.warm400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                HepBStatusBadge.riskLevel(patient.niveauRisque),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (patient.statutDossier != HepBDossierStatut.enCours)
                  HepBStatusBadge.dossier(patient.statutDossier),
                if (patient.statutDossier != HepBDossierStatut.enCours)
                  const SizedBox(width: 6),
                HepBStatusBadge.vaccination(patient.statutVaccinal),
                const Spacer(),
                if (patient.dosesAdministrees > 0 || patient.dosesPlanifiees > 0)
                  _doseSummary(),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.assignment_outlined,
                  size: 13, color: EpidemiologyTheme.warm400),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    patient.prochaineAction.isNotEmpty
                        ? patient.prochaineAction
                        : 'En attente d\'évaluation',
                    style: GoogleFonts.inter(
                      fontSize: 11.5, fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.indigo, height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            if (patient.serologieEnAttente) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: EpidemiologyTheme.warning.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.biotech, size: 12,
                      color: EpidemiologyTheme.warning),
                    const SizedBox(width: 6),
                    Text(
                      'Sérologie en attente',
                      style: GoogleFonts.inter(
                        fontSize: 10.5, fontWeight: FontWeight.w600,
                        color: EpidemiologyTheme.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _doseSummary() {
    final total = patient.doses.length;
    final done = patient.dosesAdministrees;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.vaccines_outlined, size: 12, color: EpidemiologyTheme.warm400),
        const SizedBox(width: 4),
        Text(
          '$done/$total',
          style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: done == total
                ? EpidemiologyTheme.success
                : EpidemiologyTheme.warm500,
          ),
        ),
      ],
    );
  }
}
