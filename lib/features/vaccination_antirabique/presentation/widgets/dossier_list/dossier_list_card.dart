import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../rabies_dossier_widgets.dart';
import 'dossier_list_models.dart';

/// Carte riche d'un dossier antirabique (tablette / mobile).
///
/// Combine avatar initiale, n° de dossier, catégorie, protocole avec
/// progression, prochaine dose / retard et mentions cliniques (ERIG, MPVI).
class DossierListCard extends StatelessWidget {
  final RabiesCaseRecord dossier;
  final VoidCallback? onTap;

  const DossierListCard({super.key, required this.dossier, this.onTap});

  @override
  Widget build(BuildContext context) {
    final urgent = dossier.estUrgent;
    final statut = statutProtocole(dossier);
    final statutColor = couleurProtocole(statut);
    final proto = dossier.vaccination.protocole;
    final enRetard = dossierEnRetard(dossier);
    final dueToday = dossierDueAujourdhui(dossier);

    final accent = urgent
        ? EpidemiologyTheme.danger
        : enRetard
        ? EpidemiologyTheme.warning
        : statut == DossierProtocoleStatut.termine
        ? EpidemiologyTheme.success
        : EpidemiologyTheme.redPrimary;

    final libelleProto = proto.doses.isEmpty
        ? 'Aucun protocole'
        : '${proto.type.label} (${proto.dosesRealisees}/${proto.totalDoses})';

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
            border: Border.all(color: accent.withValues(alpha: 0.16)),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            _avatar(),
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
                                    '${dossier.numeroDossier} · '
                                    '${dossier.patientAge} ans',
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
                            DossierChip(
                              label: libelleProto,
                              icon: Icons.vaccines,
                              color: statut == DossierProtocoleStatut.termine
                                  ? EpidemiologyTheme.success
                                  : EpidemiologyTheme.redPrimary,
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
                        if (proto.totalDoses > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: EpidemiologyTheme.doseProgress(
                                  current: proto.dosesRealisees,
                                  total: proto.totalDoses,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${proto.dosesRealisees}/${proto.totalDoses}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: EpidemiologyTheme.slate600,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              enRetard
                                  ? Icons.schedule
                                  : proto.prochaineDose != null
                                  ? Icons.event_available
                                  : Icons.event_note,
                              size: 14,
                              color: statutColor,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                libelleProchaineDose(dossier),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: statutColor,
                                ),
                              ),
                            ),
                            if (dueToday)
                              Icon(
                                Icons.notifications_active,
                                size: 15,
                                color: EpidemiologyTheme.danger,
                              ),
                          ],
                        ),
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

  Widget _avatar() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EpidemiologyTheme.redPrimary, EpidemiologyTheme.redMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
      ),
      child: Icon(
        dossier.identity.sexe == PatientGender.feminin
            ? Icons.person_2
            : Icons.person,
        color: EpidemiologyTheme.white,
        size: 24,
      ),
    );
  }
}
