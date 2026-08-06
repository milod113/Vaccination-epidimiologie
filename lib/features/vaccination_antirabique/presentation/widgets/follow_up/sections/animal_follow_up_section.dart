import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/epidemiology_theme.dart';
import '../../../../domain/models/dossier/rabies_case_record.dart';
import '../../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../animal_status_card.dart';
import '../follow_up_section_scaffold.dart';

/// Section « Statut de l'animal ».
///
/// Présente clairement l'animal en cause et son évolution (observation,
/// laboratoire, conclusion) car cela influence directement la conduite
/// clinique (arrêt ou poursuite du protocole).
class AnimalFollowUpSection extends StatelessWidget {
  final RabiesCaseRecord record;
  final RabiesFollowUpSummary summary;

  const AnimalFollowUpSection({
    super.key,
    required this.record,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final animal = record.animal;
    final subtitle = switch (summary.animalConclusion) {
      AnimalConclusion.enrageConfirme =>
        'Résultat positif — poursuivre impérativement le protocole',
      AnimalConclusion.nonEnrageConfirme =>
        'Animal non enragé — la décision vaccinale peut être réévaluée',
      AnimalConclusion.enAttente =>
        'Observation ou analyse en cours — statut à confirmer',
      AnimalConclusion.indetermine =>
        'Conclusion non établie à ce stade',
    };

    final accent = switch (summary.animalConclusion) {
      AnimalConclusion.enrageConfirme => EpidemiologyTheme.danger,
      AnimalConclusion.nonEnrageConfirme => EpidemiologyTheme.success,
      AnimalConclusion.enAttente => EpidemiologyTheme.warning,
      AnimalConclusion.indetermine => EpidemiologyTheme.slate500,
    };

    return FollowUpSectionScaffold(
      icon: Icons.pets,
      title: 'Statut de l\'animal en cause',
      subtitle: subtitle,
      accent: accent,
      children: [
        AnimalStatusCard(animal: animal, conclusion: summary.animalConclusion),
        if (summary.animalConclusion == AnimalConclusion.enrageConfirme) ...[
          const SizedBox(height: 14),
          _consequenceCard(),
        ],
      ],
    );
  }

  Widget _consequenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EpidemiologyTheme.dangerLight, EpidemiologyTheme.white],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 22, color: EpidemiologyTheme.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conséquence clinique',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.danger,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Un animal confirmé enragé impose la poursuite et la '
                  'finalisation complète du schéma vaccinal et de la prise en '
                  'charge (ERIG le cas échéant), sans interruption.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    color: EpidemiologyTheme.slate700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}