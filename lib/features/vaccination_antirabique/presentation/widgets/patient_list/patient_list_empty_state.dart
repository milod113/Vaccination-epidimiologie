import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// État vide premium de la liste des patients.
///
/// Distingue deux situations : aucune donnée (CTA « Admettre un patient »)
/// ou aucun résultat après recherche / filtres (CTA « Réinitialiser »).
class PatientListEmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback? onReset;
  final VoidCallback? onCreate;

  const PatientListEmptyState({
    super.key,
    required this.hasActiveFilters,
    this.onReset,
    this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 44),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasActiveFilters ? Icons.filter_alt_off_outlined : Icons.person_add_alt,
              size: 34,
              color: EpidemiologyTheme.warm400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasActiveFilters ? 'Aucun patient trouvé' : 'Aucun patient pour le moment',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EpidemiologyTheme.slate900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters
                ? 'Aucun dossier ne correspond à la recherche ou aux filtres '
                    'appliqués. Réinitialisez pour élargir les résultats.'
                : 'Admettez un premier patient antirabique pour démarrer la '
                    'prise en charge et le suivi vaccinal.',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.5,
              color: EpidemiologyTheme.warm500,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasActiveFilters && onReset != null) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh, size: 17),
              label: const Text('Réinitialiser les filtres'),
              style: OutlinedButton.styleFrom(
                foregroundColor: EpidemiologyTheme.redPrimary,
                side: BorderSide(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          if (!hasActiveFilters && onCreate != null) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.person_add_alt, size: 18),
              label: const Text('Admettre un patient'),
              style: FilledButton.styleFrom(
                backgroundColor: EpidemiologyTheme.redPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
