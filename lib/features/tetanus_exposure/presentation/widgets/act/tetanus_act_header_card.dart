import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';
import '../tetanus_evaluation_controls.dart';

/// Carte de contexte du cas affichée en tête de l'écran « Enregistrer un acte ».
///
/// Rappelle le patient (nom, identifiant, âge, sexe), le statut du dossier, la
/// décision clinique et le dernier acte enregistré.
class TetanusActHeaderCard extends StatelessWidget {
  const TetanusActHeaderCard({
    super.key,
    required this.patient,
    this.dossierStatut,
  });

  final TetanusPatientModel patient;
  final TetanusDossierStatut? dossierStatut;

  Color get _statutColor {
    switch (dossierStatut ?? patient.statutDossier) {
      case TetanusDossierStatut.enCours:
        return EpidemiologyTheme.info;
      case TetanusDossierStatut.acteEffectue:
        return EpidemiologyTheme.success;
      case TetanusDossierStatut.suiviClos:
        return EpidemiologyTheme.success;
      case TetanusDossierStatut.perduDeVue:
        return EpidemiologyTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = dossierStatut ?? patient.statutDossier;
    final dernier = patient.historique.isNotEmpty
        ? patient.historique.first
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EpidemiologyTheme.warm50, Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowCard(EpidemiologyTheme.redPrimary),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              gradient: EpidemiologyTheme.primaryGradientWarm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.healing_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enregistrer un acte',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        patient.nomComplet,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${patient.id} · ${patient.age} ans · ${patient.sexe}',
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                TetanusBadge(
                  label: statut.label,
                  color: Colors.white,
                  icon: Icons.folder_outlined,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 16,
                      color: _statutColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dossier ${statut.label.toLowerCase()}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.warm700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: EpidemiologyTheme.redPrimary.withValues(
                          alpha: 0.08,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: EpidemiologyTheme.redPrimary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                      ),
                      child: Text(
                        patient.decision.label,
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.redPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: EpidemiologyTheme.warm150),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TetanusBadge(
                      label: patient.statutVaccinal.label,
                      color: EpidemiologyTheme.indigo,
                      icon: Icons.vaccines_outlined,
                    ),
                    TetanusBadge(
                      label: patient.typePlaie.label,
                      color: EpidemiologyTheme.danger,
                      icon: Icons.healing_outlined,
                    ),
                    TetanusBadge(
                      label: patient.localisation,
                      color: EpidemiologyTheme.info,
                      icon: Icons.location_on_outlined,
                    ),
                    TetanusBadge(
                      label: 'Blessure ${patient.dateBlessure}',
                      color: EpidemiologyTheme.orange,
                      icon: Icons.event_outlined,
                    ),
                  ],
                ),
                if (dernier != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: EpidemiologyTheme.warm50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: EpidemiologyTheme.warm150),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt_outlined,
                          size: 16,
                          color: EpidemiologyTheme.amber,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dernier acte',
                                style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: EpidemiologyTheme.warm400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dernier.typeActe} · ${dernier.dateActe}',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: EpidemiologyTheme.warm700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
