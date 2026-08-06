import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/protocole_vaccinal_model.dart';
import 'status_badge.dart';

class ProtocoleTimelineCard extends StatelessWidget {
  final DoseModel dose;
  final bool isLast;
  final bool isNextDose;

  const ProtocoleTimelineCard({
    super.key,
    required this.dose,
    this.isLast = false,
    this.isNextDose = false,
  });

  @override
  Widget build(BuildContext context) {
    final statut = dose.statutDetaille;

    final (Color dotColor, Color lineColor, Color cardBg, Color cardBorder, Color dotInner) = switch (statut) {
      DoseStatutDetaille.realisee => (
        EpidemiologyTheme.success,
        EpidemiologyTheme.successLight,
        EpidemiologyTheme.successLight.withValues(alpha: 0.12),
        EpidemiologyTheme.successLight,
        EpidemiologyTheme.successDark,
      ),
      DoseStatutDetaille.enRetard => (
        EpidemiologyTheme.danger,
        EpidemiologyTheme.dangerLight,
        EpidemiologyTheme.dangerLight.withValues(alpha: 0.08),
        EpidemiologyTheme.dangerLight,
        EpidemiologyTheme.danger,
      ),
      DoseStatutDetaille.prevueAujourdhui => (
        EpidemiologyTheme.warning,
        EpidemiologyTheme.warningLight,
        EpidemiologyTheme.warningLight.withValues(alpha: 0.15),
        EpidemiologyTheme.warningLight,
        EpidemiologyTheme.warning,
      ),
      DoseStatutDetaille.reportee => (
        EpidemiologyTheme.warning,
        EpidemiologyTheme.warningLight,
        EpidemiologyTheme.warningLight.withValues(alpha: 0.08),
        EpidemiologyTheme.warningLight,
        EpidemiologyTheme.warningDark,
      ),
      DoseStatutDetaille.nonEffectuee => (
        EpidemiologyTheme.danger,
        EpidemiologyTheme.dangerLight,
        EpidemiologyTheme.dangerLight.withValues(alpha: 0.05),
        EpidemiologyTheme.dangerLight,
        EpidemiologyTheme.dangerDark,
      ),
      DoseStatutDetaille.aVenir => (
        isNextDose ? EpidemiologyTheme.redPrimary : EpidemiologyTheme.slate300,
        isNextDose ? EpidemiologyTheme.redLight : EpidemiologyTheme.slate100,
        isNextDose ? EpidemiologyTheme.redSurface : EpidemiologyTheme.white,
        isNextDose ? EpidemiologyTheme.redLight : EpidemiologyTheme.slate100,
        isNextDose ? EpidemiologyTheme.redPrimary : EpidemiologyTheme.slate400,
      ),
    };

    final hasDotIcon = statut == DoseStatutDetaille.realisee ||
        statut == DoseStatutDetaille.enRetard;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: dose.estAdministree
                        ? LinearGradient(
                            colors: [EpidemiologyTheme.success, EpidemiologyTheme.successDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: dose.estAdministree ? null : dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: EpidemiologyTheme.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(color: dotColor.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2)),
                      if (isNextDose && !dose.estAdministree)
                        BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 0)),
                    ],
                  ),
                  child: hasDotIcon
                      ? Icon(
                          statut == DoseStatutDetaille.realisee ? Icons.check : Icons.warning,
                          size: 12,
                          color: Colors.white,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: dose.estAdministree && !isLast
                            ? LinearGradient(
                                colors: [EpidemiologyTheme.successLight, EpidemiologyTheme.slate100],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: dose.estAdministree ? null : lineColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                border: Border.all(
                  color: cardBorder,
                  width: isNextDose && !dose.estAdministree ? 1.5 : 0.5,
                ),
                boxShadow: [
                  BoxShadow(color: cardBorder.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2)),
                  if (isNextDose && !dose.estAdministree)
                    BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (dose.jourTheorique.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: dotColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            dose.jourTheorique,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: dotInner,
                            ),
                          ),
                        ),
                      if (dose.jourTheorique.isNotEmpty) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dose.etiquetteDose,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.slate900,
                          ),
                        ),
                      ),
                      StatusBadge.detail(dose.statutDetaille),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: EpidemiologyTheme.slate400),
                      const SizedBox(width: 6),
                      Text(
                        dose.estAdministree && dose.dateReelle != null
                            ? 'Réelle : ${dose.dateReelle}'
                            : 'Prévue : ${dose.datePrevue}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: dose.estAujourdhui ? EpidemiologyTheme.warning : EpidemiologyTheme.slate500,
                        ),
                      ),
                      if (dose.estAujourdhui) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 14, color: EpidemiologyTheme.warning),
                        const SizedBox(width: 2),
                        Text(
                          "Aujourd'hui",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.warning,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (dose.numeroLot != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.inventory_2, size: 14, color: EpidemiologyTheme.slate400),
                        const SizedBox(width: 6),
                        Text(
                          'Lot : ${dose.numeroLot}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate500),
                        ),
                      ],
                    ),
                  ],
                  if (dose.administrateurNom != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: EpidemiologyTheme.slate400),
                        const SizedBox(width: 6),
                        Text(
                          'Par : ${dose.administrateurNom}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate500),
                        ),
                      ],
                    ),
                  ],
                  if (dose.voieAdministration != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.science, size: 14, color: EpidemiologyTheme.slate400),
                        const SizedBox(width: 6),
                        Text(
                          'Voie : ${dose.voieAdministration}${dose.injectionDouble ? ' (×2 sites simultanés)' : ''}',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate500),
                        ),
                      ],
                    ),
                  ],
                  if (dose.motifReport != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [EpidemiologyTheme.warningLight, EpidemiologyTheme.warningLight.withValues(alpha: 0.5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: EpidemiologyTheme.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dose.motifReport!,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate700),
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
    );
  }
}
