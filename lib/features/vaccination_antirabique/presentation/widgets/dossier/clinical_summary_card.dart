import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_decision_summary.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import 'status_components.dart';

/// Synthèse clinique du dossier : catégorie, PPE, ERIG, protocole, animal.
class ClinicalSummaryCard extends StatelessWidget {
  final RabiesDecisionSummary decision;
  final RabiesFollowUpSummary followUp;
  final bool ppeNonIndiquee;

  const ClinicalSummaryCard({
    super.key,
    required this.decision,
    required this.followUp,
    required this.ppeNonIndiquee,
  });

  @override
  Widget build(BuildContext context) {
    final d = decision;
    final cat = d.categorie.categorie;
    final animalColor = switch (followUp.animalConclusion) {
      AnimalConclusion.enrageConfirme => EpidemiologyTheme.danger,
      AnimalConclusion.enAttente => EpidemiologyTheme.warning,
      AnimalConclusion.nonEnrageConfirme => EpidemiologyTheme.success,
      AnimalConclusion.indetermine => EpidemiologyTheme.slate500,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_information_outlined, size: 18, color: EpidemiologyTheme.redPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Décision clinique',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
              ),
              RiskBadge(category: cat, compact: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: KeyFactChip(
                  label: cat.label,
                  value: _categorySummary(cat),
                  icon: Icons.shield_outlined,
                  color: RiskBadge.colorFor(cat),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCols = constraints.maxWidth >= 480;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: twoCols ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth,
                    child: KeyFactChip(
                      label: 'PPE',
                      value: d.ppe.urgente ? 'Urgente' : d.ppe.indiquee ? 'Indiquée' : ppeNonIndiquee ? 'Non indiquée' : 'Indiquée',
                      icon: Icons.vaccines,
                      color: d.ppe.indiquee ? EpidemiologyTheme.info : EpidemiologyTheme.slate400,
                    ),
                  ),
                  SizedBox(
                    width: twoCols ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth,
                    child: KeyFactChip(
                      label: 'ERIG',
                      value: d.erig.indiquee ? (d.erig.administree ? 'Administrée' : 'À administrer') : 'Non indiquée',
                      icon: Icons.science,
                      color: d.erig.bloquante
                          ? EpidemiologyTheme.danger
                          : d.erig.indiquee
                              ? (d.erig.administree ? EpidemiologyTheme.success : EpidemiologyTheme.warning)
                              : EpidemiologyTheme.slate400,
                    ),
                  ),
                  if (d.protocole != null)
                    SizedBox(
                      width: twoCols ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth,
                      child: KeyFactChip(
                        label: 'Protocole',
                        value: d.protocole!.schemaLabel,
                        icon: Icons.timeline,
                        color: EpidemiologyTheme.teal,
                      ),
                    ),
                  SizedBox(
                    width: twoCols ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth,
                    child: KeyFactChip(
                      label: 'Animal',
                      value: followUp.animalConclusion.label,
                      icon: Icons.pets,
                      color: animalColor,
                    ),
                  ),
                ],
              );
            },
          ),
          if (d.protocole?.remarques != null) ...[
            const SizedBox(height: 12),
            Text(
              d.protocole!.remarques!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: EpidemiologyTheme.slate500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _categorySummary(RabiesRiskCategory c) => switch (c) {
    RabiesRiskCategory.categorieII => 'Vaccin seul',
    RabiesRiskCategory.categorieIII => 'Vaccin + ERIG',
    RabiesRiskCategory.categorieI => 'Aucune prophylaxie',
  };
}