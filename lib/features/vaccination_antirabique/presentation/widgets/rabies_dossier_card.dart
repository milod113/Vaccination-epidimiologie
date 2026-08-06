import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/models/dossier/dossier_enums.dart';
import '../../domain/models/dossier/rabies_case_record.dart';
import 'rabies_dossier_widgets.dart';

/// Carte d'un dossier antirabique dans la liste.
class RabiesDossierCard extends StatelessWidget {
  final RabiesCaseRecord dossier;
  final VoidCallback? onTap;

  const RabiesDossierCard({super.key, required this.dossier, this.onTap});

  @override
  Widget build(BuildContext context) {
    final urgent = dossier.estUrgent;
    final retard = dossier.aRetard;
    final termine = dossier.protocoleTermine;
    final accent = urgent
        ? EpidemiologyTheme.danger
        : retard
            ? EpidemiologyTheme.warning
            : termine
                ? EpidemiologyTheme.teal
                : EpidemiologyTheme.redPrimary;

    final proto = dossier.vaccination.protocole;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        child: Container(
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
            boxShadow: EpidemiologyTheme.shadowMd,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withValues(alpha: 0.25)],
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
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    EpidemiologyTheme.redPrimary,
                                    EpidemiologyTheme.redMedium,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius:
                                    BorderRadius.circular(EpidemiologyTheme.radiusMd),
                              ),
                              child: Icon(
                                dossier.identity.sexe == PatientGender.feminin
                                    ? Icons.person_2
                                    : Icons.person,
                                color: EpidemiologyTheme.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dossier.patientNomComplet,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: EpidemiologyTheme.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${dossier.numeroDossier} · ${dossier.patientAge} ans',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: EpidemiologyTheme.warm500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DossierChip(
                              label: dossier.categorie.label,
                              icon: Icons.category,
                              color: urgent
                                  ? EpidemiologyTheme.danger
                                  : EpidemiologyTheme.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (proto.doses.isNotEmpty)
                              DossierChip(
                                label:
                                    '${proto.type.label} (${proto.dosesRealisees}/${proto.totalDoses})',
                                icon: Icons.vaccines,
                                color: termine ? EpidemiologyTheme.teal : EpidemiologyTheme.redPrimary,
                                subtle: true,
                              )
                            else
                              DossierChip(
                                label: 'Aucun protocole',
                                icon: Icons.block,
                                color: EpidemiologyTheme.warm400,
                                subtle: true,
                              ),
                            DossierChip(
                              label: dossier.animal.espece.label,
                              icon: Icons.pets,
                              color: EpidemiologyTheme.slate500,
                              subtle: true,
                            ),
                            if (dossier.aErigAdministree)
                              DossierChip(
                                label: 'ERIG',
                                icon: Icons.science,
                                color: EpidemiologyTheme.teal,
                                subtle: true,
                              ),
                            if (dossier.aMpvi)
                              DossierChip(
                                label: 'MPVI',
                                icon: Icons.warning_amber_rounded,
                                color: EpidemiologyTheme.warning,
                                subtle: true,
                              ),
                          ],
                        ),
                        if (retard) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: EpidemiologyTheme.warning),
                              const SizedBox(width: 5),
                              Text(
                                'Doses en retard — ${proto.dosesEnRetard.length} à rattraper',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: EpidemiologyTheme.warning,
                                ),
                              ),
                            ],
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
