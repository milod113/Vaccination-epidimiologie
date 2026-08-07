import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// En-tête premium de la liste des cas tétaniques.
///
/// Présente le contexte opérationnel (titre, sous-titre, total de dossiers),
/// un indicateur d'urgence et le CTA « Nouvelle évaluation ».
class TetanusCasesHeroHeader extends StatelessWidget {
  final int totalCount;
  final int urgentCount;
  final VoidCallback? onBack;
  final VoidCallback? onCreateEvaluation;

  const TetanusCasesHeroHeader({
    super.key,
    required this.totalCount,
    required this.urgentCount,
    this.onBack,
    this.onCreateEvaluation,
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
              if (onBack != null) ...[_backButton(), const SizedBox(width: 10)],
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
                  Icons.healing_outlined,
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
                      'Cas tétanos',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Prophylaxie antitétanique post-exposition — vue clinique',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              if (!narrow && onCreateEvaluation != null) ...[
                const SizedBox(width: 12),
                _createButton(),
              ],
            ],
          );

          final countRow = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip(
                Icons.people_alt_outlined,
                '$totalCount dossiers',
                Colors.white,
              ),
              if (urgentCount > 0)
                _statChip(
                  Icons.warning_amber_rounded,
                  '$urgentCount urgents',
                  EpidemiologyTheme.danger,
                ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleBlock,
              const SizedBox(height: 16),
              countRow,
              if (narrow && onCreateEvaluation != null) ...[
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: _createButton()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _backButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onBack,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
        ),
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
      onPressed: onCreateEvaluation,
      icon: const Icon(Icons.note_add_outlined, size: 18),
      label: const Text('Nouvelle évaluation'),
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
