import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// En-tête premium de la liste des dossiers antirabiques.
///
/// Présente le contexte opérationnel (titre, sous-titre), le total de dossiers
/// et un CTA « Nouveau dossier ». Utilise le dégradé bleu institutionnel et
/// les ombres multicouches de l'identité antirabique.
class DossierListHeroHeader extends StatelessWidget {
  final int totalCount;
  final VoidCallback? onCreateDossier;

  const DossierListHeroHeader({
    super.key,
    required this.totalCount,
    this.onCreateDossier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(24),
        boxShadow: EpidemiologyTheme.heroShadow(EpidemiologyTheme.redDeep),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 460;

          final titleBlock = Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: const Icon(
                  Icons.folder_copy_outlined,
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dossiers antirabiques',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Suivi clinique et vaccinal des expositions',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (!narrow && onCreateDossier != null) ...[
                const SizedBox(width: 12),
                _createButton(),
              ],
            ],
          );

          final countRow = Row(
            children: [
              _statChip(
                Icons.folder_outlined,
                '$totalCount dossier${totalCount > 1 ? 's' : ''}',
                Colors.white,
              ),
              const Spacer(),
              if (!narrow && totalCount > 0)
                Text(
                  '$totalCount sous suivi',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 16),
              countRow,
              if (narrow && onCreateDossier != null) ...[
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: _createButton()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createButton() {
    return FilledButton.icon(
      onPressed: onCreateDossier,
      icon: const Icon(Icons.folder_open, size: 18),
      label: const Text('Nouveau dossier'),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: EpidemiologyTheme.redDeep,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}
