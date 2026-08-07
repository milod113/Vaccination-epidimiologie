import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../tetanus_evaluation_controls.dart';
import 'tetanus_act_ui.dart';

/// Section traçabilité de l'écran « Enregistrer un acte ».
///
/// Capture la date, l'heure, l'acteur, son rôle, le centre et le statut de
/// validation. Les champs sont contrôlés depuis l'écran parent.
class TetanusActTraceabilityCard extends StatelessWidget {
  const TetanusActTraceabilityCard({
    super.key,
    required this.date,
    required this.heure,
    required this.acteur,
    required this.role,
    required this.centre,
    required this.valide,
    required this.onDateChanged,
    required this.onHeureChanged,
    required this.onActeurChanged,
    required this.onRoleChanged,
    required this.onCentreChanged,
    required this.onValideChanged,
  });

  final String date;
  final String heure;
  final String acteur;
  final String role;
  final String centre;
  final bool valide;
  final ValueChanged<String> onDateChanged;
  final ValueChanged<String> onHeureChanged;
  final ValueChanged<String> onActeurChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<String> onCentreChanged;
  final ValueChanged<bool> onValideChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowCard(EpidemiologyTheme.indigo),
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
                      EpidemiologyTheme.indigo.withValues(alpha: 0.12),
                      EpidemiologyTheme.indigo.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  size: 20,
                  color: EpidemiologyTheme.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traçabilité',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.warm900,
                      ),
                    ),
                    Text(
                      'Acteur, rôle, centre et validation',
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
              final dateField = _field(
                'Date (JJ/MM/AAAA)',
                date,
                onDateChanged,
                'ex : 07/08/2026',
                twoCols: twoCols,
                maxWidth: constraints.maxWidth,
              );
              final heureField = _field(
                'Heure (HH:MM)',
                heure,
                onHeureChanged,
                'ex : 14:30',
                twoCols: twoCols,
                maxWidth: constraints.maxWidth,
              );
              final acteurField = _field(
                'Acteur',
                acteur,
                onActeurChanged,
                'Nom de l\'agent',
                twoCols: twoCols,
                maxWidth: constraints.maxWidth,
              );
              final centreField = _field(
                'Centre',
                centre,
                onCentreChanged,
                'ex : EPSP Alger',
                twoCols: twoCols,
                maxWidth: constraints.maxWidth,
              );
              if (twoCols) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 0,
                  children: [dateField, heureField, acteurField, centreField],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [dateField, heureField, acteurField, centreField],
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Rôle',
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.warm500,
            ),
          ),
          const SizedBox(height: 8),
          TetanusChoiceChips<String>(
            options: [for (final r in tetanusRoles) TetanusChoiceOption(r, r)],
            selected: role.isEmpty ? null : role,
            onChanged: onRoleChanged,
            accent: EpidemiologyTheme.indigo,
          ),
          const SizedBox(height: 10),
          TetanusToggleTile(
            label: 'Acte validé',
            help: 'Confirme que l\'acte a été réalisé et contrôlé',
            icon: Icons.verified_outlined,
            value: valide,
            accent: EpidemiologyTheme.success,
            onChanged: onValideChanged,
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String value,
    ValueChanged<String> onChanged,
    String hint, {
    required bool twoCols,
    required double maxWidth,
  }) {
    return SizedBox(
      width: twoCols ? (maxWidth - 12) / 2 : maxWidth,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
      ),
    );
  }
}
