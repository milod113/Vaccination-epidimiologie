import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';

/// En-tête sticky de synthèse du parcours de suivi.
///
/// Résume l'état global du patient : patient, catégorie, protocole,
/// progression, prochaine dose, ERIG, statut animal, alertes et état du
/// dossier — visible en haut de tous les écrans de suivi.
class FollowUpSummaryHeader extends StatelessWidget {
  final RabiesCaseRecord record;
  final RabiesFollowUpSummary summary;

  const FollowUpSummaryHeader({
    super.key,
    required this.record,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _identityRow(),
          const SizedBox(height: 14),
          _progressRow(),
          const SizedBox(height: 12),
          _chipsRow(),
        ],
      ),
    );
  }

  Widget _identityRow() {
    final urgent = record.estUrgent;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.folder_copy_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.patientNomComplet,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${record.numeroDossier} · ${record.patientAge} ans · ${record.identity.sexe.label}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
        _whiteChip(
          record.categorie.label,
          Icons.category,
          urgent ? Colors.white : Colors.amberAccent,
        ),
      ],
    );
  }

  Widget _progressRow() {
    final pct = summary.progressionPercent;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Protocole ${summary.protocoleStatut.label}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${summary.dosesRealisees}/${summary.totalDoses} doses',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 7,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withValues(alpha: 0.25)),
                      FractionallySizedBox(
                        widthFactor: pct / 100,
                        child: Container(
                          color: pct >= 100
                              ? const Color(0xFF4ADE80)
                              : Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Prochain : ${_nextLabel()}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _nextLabel() {
    final next = summary.prochaineDose;
    if (summary.protocoleStatut == RabiesProtocolStatus.termine) {
      return 'schéma terminé';
    }
    if (summary.protocoleStatut == RabiesProtocolStatus.sansProtocole) {
      return 'aucun protocole';
    }
    if (next == null) return '—';
    final date = next.datePrevue;
    if (date == null) return next.jourTheorique;
    final dd = date.day.toString().padLeft(2, '0');
    final mm = date.month.toString().padLeft(2, '0');
    return '${next.jourTheorique} · $dd/$mm/${date.year}';
  }

  Widget _chipsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _whiteChip(
          'Progression ${summary.progressionPercent}%',
          Icons.trending_up,
          Colors.white,
          onDark: true,
        ),
        if (record.aErigAdministree)
          _whiteChip(
            'ERIG administrée',
            Icons.science,
            Colors.tealAccent,
            onDark: true,
          ),
        _animalChip(),
        if (summary.alertesCritiques > 0)
          _whiteChip(
            '${summary.alertesCritiques} alerte(s) critique(s)',
            Icons.error_outline,
            const Color(0xFFFF8A80),
            onDark: true,
          ),
        if (summary.mpviPresent)
          _whiteChip(
            'MPVI ${summary.mpviGravite.label}',
            Icons.warning_amber_rounded,
            const Color(0xFFFFD54F),
            onDark: true,
          ),
        _whiteChip(
          summary.evolutionResultat.label,
          Icons.flag_outlined,
          Colors.white,
          onDark: true,
        ),
      ],
    );
  }

  Widget _animalChip() {
    return switch (summary.animalConclusion) {
      AnimalConclusion.enrageConfirme =>
        _whiteChip('Animal enragé', Icons.pets, const Color(0xFFFF8A80), onDark: true),
      AnimalConclusion.nonEnrageConfirme =>
        _whiteChip('Animal non enragé', Icons.verified_outlined, const Color(0xFF80EFB0), onDark: true),
      AnimalConclusion.enAttente =>
        _whiteChip('Animal en attente', Icons.hourglass_top, const Color(0xFFFFD54F), onDark: true),
      AnimalConclusion.indetermine =>
        _whiteChip('Animal indéterminé', Icons.help_outline, Colors.white, onDark: true),
    };
  }

  Widget _whiteChip(
    String label,
    IconData icon,
    Color accent, {
    bool onDark = false,
  }) {
    final color = onDark ? accent : accent.withValues(alpha: 0.9);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: onDark ? Colors.white.withValues(alpha: 0.95) : color,
            ),
          ),
        ],
      ),
    );
  }
}