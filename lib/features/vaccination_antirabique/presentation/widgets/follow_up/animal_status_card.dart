import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/animal.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import 'clinical_status_pill.dart';

/// Carte récapitulative du statut de l'animal en cause.
///
/// Trois blocs : identification, observation vétérinaire, laboratoire —
/// avec une conclusion forte (enragé / non enragé / en attente).
class AnimalStatusCard extends StatelessWidget {
  final AnimalInfo animal;
  final AnimalConclusion conclusion;

  const AnimalStatusCard({
    super.key,
    required this.animal,
    required this.conclusion,
  });

  (Color, IconData) get _conclusionStyle => switch (conclusion) {
        AnimalConclusion.enrageConfirme =>
          (EpidemiologyTheme.danger, Icons.pets),
        AnimalConclusion.nonEnrageConfirme =>
          (EpidemiologyTheme.success, Icons.verified_outlined),
        AnimalConclusion.enAttente =>
          (EpidemiologyTheme.warning, Icons.hourglass_top),
        AnimalConclusion.indetermine =>
          (EpidemiologyTheme.slate500, Icons.help_outline),
      };

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _conclusionStyle;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: conclusion == AnimalConclusion.enrageConfirme
              ? EpidemiologyTheme.danger.withValues(alpha: 0.40)
              : EpidemiologyTheme.warm100,
        ),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _conclusionHeader(color, icon),
          const SizedBox(height: 16),
          _block(
            'Animal en cause',
            Icons.pets,
            [
              _kv('Espèce', animal.espece.label),
              if (animal.autreEspecePrecision != null)
                _kv('Précision', animal.autreEspecePrecision!),
              _kv('Statut', animal.statut.label),
              _kv('Comportement', animal.comportement.label),
              _kv('Vaccination antirabique', animal.vaccination.label),
              if (animal.dateVaccination != null)
                _kv('Date vaccination', _fmt(animal.dateVaccination)),
            ],
          ),
          _block(
            'Observation vétérinaire',
            Icons.visibility_outlined,
            [
              _kv('Observation', animal.observationVeterinaire.label),
              _kv('Début', _fmt(animal.debutObservation)),
              _kv('Fin', _fmt(animal.finObservation)),
              _kv('Résultat', animal.resultatObservation.label),
              _kv('Sort', animal.sort.label),
            ],
          ),
          _block(
            'Laboratoire',
            Icons.biotech_outlined,
            [
              _kv('Envoi tête au labo', animal.envoiTeteLabo.label),
              _kv('Type d\'analyse', animal.typeAnalyse?.label),
              _kv('Date analyse', _fmt(animal.dateAnalyse)),
              _kv('Résultat labo', animal.resultatLabo.label),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conclusionHeader(Color color, IconData icon) {
    final bg = conclusion == AnimalConclusion.enrageConfirme
        ? EpidemiologyTheme.dangerLight
        : conclusion == AnimalConclusion.nonEnrageConfirme
            ? EpidemiologyTheme.successLight
            : conclusion == AnimalConclusion.enAttente
                ? EpidemiologyTheme.warningLight
                : EpidemiologyTheme.warm100;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conclusion',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  conclusion.label,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (conclusion == AnimalConclusion.enrageConfirme)
            ClinicalStatusPill(
              label: 'Risque confirmé',
              icon: Icons.warning_amber_rounded,
              color: EpidemiologyTheme.danger,
            ),
        ],
      ),
    );
  }

  Widget _block(String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: EpidemiologyTheme.slate400),
              const SizedBox(width: 7),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm400,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
          if (title != 'Laboratoire') ...[
            const SizedBox(height: 8),
            Divider(color: EpidemiologyTheme.warm100, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _kv(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: EpidemiologyTheme.slate500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? '—' : value,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.slate800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
