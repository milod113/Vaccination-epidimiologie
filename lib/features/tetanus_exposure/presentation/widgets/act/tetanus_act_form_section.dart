import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';
import '../tetanus_evaluation_controls.dart';
import 'tetanus_act_ui.dart';

/// Formulaire dynamique des champs spécifiques à chaque type d'acte.
///
/// Seuls les champs pertinents pour la nature de l'acte sont affichés
/// (vaccin, lot, expiration, voie, dose, zone, observations…).
class TetanusActFormSection extends StatelessWidget {
  const TetanusActFormSection({
    super.key,
    required this.type,
    required this.vaccin,
    required this.onVaccinChanged,
    required this.numeroLot,
    required this.onNumeroLotChanged,
    required this.dateExpiration,
    required this.onDateExpirationChanged,
    required this.voie,
    required this.onVoieChanged,
    required this.dose,
    required this.onDoseChanged,
    required this.zone,
    required this.onZoneChanged,
    required this.observations,
    required this.onObservationsChanged,
  });

  final TetanusActType type;
  final String vaccin;
  final ValueChanged<String> onVaccinChanged;
  final String numeroLot;
  final ValueChanged<String> onNumeroLotChanged;
  final String dateExpiration;
  final ValueChanged<String> onDateExpirationChanged;
  final String voie;
  final ValueChanged<String> onVoieChanged;
  final String dose;
  final ValueChanged<String> onDoseChanged;
  final String zone;
  final ValueChanged<String> onZoneChanged;
  final String observations;
  final ValueChanged<String> onObservationsChanged;

  static const _vaccinPresets = [
    'VAT (Anatoxine tétanique)',
    'VAT + Ig (Immunoglobulines)',
    'DTCaP (Diphtérie-Tétanos-Coqueluche)',
    'Td (Tétanos-Diphtérie)',
  ];

  @override
  Widget build(BuildContext context) {
    final color = tetanusActColor(type);
    final icon = tetanusActIcon(type);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowCard(color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails de l\'acte',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.warm900,
                      ),
                    ),
                    Text(
                      type.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: EpidemiologyTheme.warm400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final twoCols = constraints.maxWidth >= 560;
              final half = (constraints.maxWidth - 12) / 2;

              Widget field(
                String label,
                String value,
                ValueChanged<String> onChanged,
                String hint, {
                int lines = 1,
                bool wide = false,
              }) {
                return SizedBox(
                  width: (wide || !twoCols) ? constraints.maxWidth : half,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      initialValue: value,
                      onChanged: onChanged,
                      maxLines: lines,
                      decoration: InputDecoration(
                        labelText: label,
                        hintText: hint,
                        alignLabelWithHint: lines > 1,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (type.requiresVaccin) ...[
                    _label('Produit vaccinal'),
                    TetanusChoiceChips<String>(
                      options: [
                        for (final p in _vaccinPresets)
                          TetanusChoiceOption(p, p),
                      ],
                      selected: vaccin.isEmpty ? null : vaccin,
                      onChanged: onVaccinChanged,
                      accent: color,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (type.requiresLot) ...[
                    Wrap(
                      spacing: 12,
                      runSpacing: 0,
                      children: [
                        field(
                          'Numéro de lot',
                          numeroLot,
                          onNumeroLotChanged,
                          'ex : L26T060',
                        ),
                        field(
                          'Date d\'expiration',
                          dateExpiration,
                          onDateExpirationChanged,
                          'ex : 2028-06-28',
                        ),
                      ],
                    ),
                  ],
                  if (type.requiresOrganisation) ...[
                    _label('Voie d\'administration'),
                    TetanusChoiceChips<String>(
                      options: [
                        for (final v in tetanusVoieChoices)
                          TetanusChoiceOption(v, v),
                      ],
                      selected: voie.isEmpty ? null : voie,
                      onChanged: onVoieChanged,
                      accent: EpidemiologyTheme.info,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 0,
                      children: [
                        field('Dose', dose, onDoseChanged, 'ex : 0,5 ml'),
                        field(
                          'Site (zone)',
                          zone,
                          onZoneChanged,
                          'ex : Deltoïde droit',
                        ),
                      ],
                    ),
                  ],
                  if (type == TetanusActType.soinsLocaux)
                    field(
                      'Zone traitée',
                      zone,
                      onZoneChanged,
                      'ex : Jambe droite',
                      wide: true,
                    ),
                  _label('Observations'),
                  field(
                    'Notes cliniques',
                    observations,
                    onObservationsChanged,
                    _hintFor(type),
                    lines: 3,
                    wide: true,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _hintFor(TetanusActType type) {
    switch (type) {
      case TetanusActType.vaccination:
      case TetanusActType.serumIg:
        return 'Tolérance, réaction observée…';
      case TetanusActType.evaluationMedicale:
        return 'Résumé de l\'évaluation ou de la réévaluation…';
      case TetanusActType.prescription:
        return 'Détail de la prescription (produit, posologie)…';
      case TetanusActType.soinsLocaux:
        return 'Nettoyage, antisepsie, parage effectués…';
      case TetanusActType.controleSuivi:
        return 'Résultats du contrôle et évolution clinique…';
      case TetanusActType.clotureDossier:
        return 'Bilan final et motif de clôture…';
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: EpidemiologyTheme.warm500,
        ),
      ),
    );
  }
}
