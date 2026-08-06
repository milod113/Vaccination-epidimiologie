import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../domain/models/dossier/vaccination.dart';

/// Bannière « Prochaine dose » — CTA principal du suivi vaccinal.
///
/// Affichée en haut du suivi des doses : met en avant la dose à administrer
/// (ou l'état de complétude), avec un bouton d'action optionnel.
class NextDoseBanner extends StatelessWidget {
  final RabiesFollowUpSummary summary;
  final VoidCallback? onValider;
  final VoidCallback? onDetails;

  const NextDoseBanner({
    super.key,
    required this.summary,
    this.onValider,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final next = summary.prochaineDose;

    // Aucun protocole → état neutre.
    if (summary.protocoleStatut == RabiesProtocolStatus.sansProtocole) {
      return _banner(
        color: EpidemiologyTheme.slate400,
        gradient: const [EpidemiologyTheme.warm100, EpidemiologyTheme.warm50],
        icon: Icons.medical_information_outlined,
        title: 'Aucun protocole actif',
        subtitle: 'Catégorie I ou vaccination non initiée à la fiche J0.',
        trailing: const Icon(Icons.more_horiz, color: EpidemiologyTheme.slate400),
      );
    }

    // Protocole terminé.
    if (summary.protocoleStatut == RabiesProtocolStatus.termine) {
      return _banner(
        color: EpidemiologyTheme.success,
        gradient: const [EpidemiologyTheme.successLight, EpidemiologyTheme.white],
        icon: Icons.verified_outlined,
        title: 'Protocole vaccinal terminé',
        subtitle: 'Toutes les doses du schéma ont été administrées.',
        trailing: const Icon(Icons.check_circle, color: EpidemiologyTheme.success),
      );
    }

    final inRetard = summary.protocoleStatut == RabiesProtocolStatus.enRetard;
    final color = inRetard ? EpidemiologyTheme.danger : EpidemiologyTheme.redPrimary;
    final gradient = inRetard
        ? const [EpidemiologyTheme.dangerLight, EpidemiologyTheme.white]
        : const [EpidemiologyTheme.red50, EpidemiologyTheme.white];

    final dueAujourdhui = summary.doseDueAujourdhui;

    return _banner(
      color: color,
      gradient: gradient,
      icon: inRetard ? Icons.schedule : (dueAujourdhui ? Icons.alarm : Icons.arrow_circle_right),
      title: next != null
          ? '${next.etiquette} à administrer'
          : 'Suivi en cours',
      subtitle: _subtitle(next, inRetard, dueAujourdhui),
      trailing: _actions(next),
    );
  }

  String _subtitle(VaccineDose? next, bool inRetard, bool dueAujourdhui) {
    if (next == null || next.datePrevue == null) {
      return inRetard ? 'Reprendre le schéma au plus vite.' : 'Schéma en cours.';
    }
    final date = next.datePrevue!;
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    final dateStr = '$dd/$mm/${date.year}';
    if (inRetard) return 'Initialement prévue le $dateStr — rattraper la dose.';
    if (dueAujourdhui) return 'Prévue aujourd\'hui ($dateStr).';
    return 'Prévue le $dateStr.';
  }

  Widget _actions(VaccineDose? next) {
    if (onValider == null || next == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      children: [
        if (onDetails != null)
          IconButton(
            onPressed: onDetails,
            icon: const Icon(Icons.info_outline, size: 18),
            color: EpidemiologyTheme.slate500,
            tooltip: 'Détails',
          ),
        FilledButton.icon(
          onPressed: onValider,
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Valider la dose'),
          style: FilledButton.styleFrom(
            backgroundColor: EpidemiologyTheme.redPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _banner({
    required Color color,
    required List<Color> gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: EpidemiologyTheme.slate600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}
