import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/models/dossier/rabies_decision_summary.dart';
import '../../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../../domain/models/dossier/vaccination.dart';

/// Hero premium en tête du dossier patient : identité, catégorie, statut et
/// prochaine action à réaliser.
class PatientDossierHeroHeader extends StatelessWidget {
  final RabiesCaseRecord dossier;
  final RabiesDecisionSummary decision;
  final RabiesFollowUpSummary followUp;
  final VoidCallback? onBack;
  final VoidCallback? onEditJ0;
  final VoidCallback? onFollowUp;

  const PatientDossierHeroHeader({
    super.key,
    required this.dossier,
    required this.decision,
    required this.followUp,
    this.onBack,
    this.onEditJ0,
    this.onFollowUp,
  });

  Color get _statusColor => switch (decision.statut) {
    RabiesDossierStatus.prete => const Color(0xFF38BDF8),
    RabiesDossierStatus.aCompleter => EpidemiologyTheme.warning,
    RabiesDossierStatus.enRetard => EpidemiologyTheme.danger,
    RabiesDossierStatus.terminee => const Color(0xFF4ADE80),
  };

  Color get _animalColor => switch (followUp.animalConclusion) {
    AnimalConclusion.enrageConfirme => EpidemiologyTheme.danger,
    AnimalConclusion.nonEnrageConfirme => EpidemiologyTheme.success,
    AnimalConclusion.enAttente => EpidemiologyTheme.warning,
    AnimalConclusion.indetermine => EpidemiologyTheme.slate400,
  };

  @override
  Widget build(BuildContext context) {
    final d = dossier;
    final next = followUp.prochaineDose;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (onBack != null)
                _GlassIconButton(
                  icon: Icons.arrow_back,
                  tooltip: 'Retour',
                  onTap: onBack!,
                ),
              const SizedBox(width: 12),
              _Logomark(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOSSIER ${d.numeroDossier}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.patientNomComplet.isNotEmpty ? d.patientNomComplet : 'Patient',
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.patientAge} ans · ${d.identity.sexe.label}'
                      '${d.identity.telephone != null && d.identity.telephone!.isNotEmpty ? ' · ${d.identity.telephone}' : ''}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              _CategoryGlassBadge(category: d.categorie),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final statusChips = <Widget>[
                _StatusChip(
                  label: decision.statut.label,
                  icon: Icons.verified_outlined,
                  color: _statusColor,
                ),
                if (decision.protocole != null)
                  _StatusChip(
                    label: decision.protocole!.type.label,
                    icon: Icons.timeline,
                    color: const Color(0xFF93C5FD),
                  ),
                _StatusChip(
                  label: followUp.animalConclusion.label,
                  icon: Icons.pets,
                  color: _animalColor,
                ),
              ];
              final stats = _HeroStats(d: d, next: next);
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: stats),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: statusChips,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  stats,
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, children: statusChips),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _NextDoseBanner(
                    next: next,
                    delayed: followUp.joursRetard,
                    overdue: followUp.protocoleStatut == RabiesProtocolStatus.enRetard,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionButton(
                  label: 'Modifier J0',
                  icon: Icons.edit_note,
                  filled: false,
                  onTap: onEditJ0,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Suivi',
                  icon: Icons.timeline,
                  filled: true,
                  onTap: onFollowUp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  final RabiesCaseRecord d;
  final VaccineDose? next;

  const _HeroStats({required this.d, required this.next});

  @override
  Widget build(BuildContext context) {
    final p = d.vaccination.protocole;
    return Row(
      children: [
        _Stat(
          value: '${p.dosesRealisees}/${p.totalDoses}',
          label: 'doses réalisées',
        ),
        _Stat(
          value: next?.jourTheorique ?? '—',
          label: 'prochaine dose',
          valueColor: Colors.white,
        ),
        _Stat(
          value: d.exposition.dateExposition != null
              ? _fmt(d.exposition.dateExposition!)
              : '—',
          label: 'exposition',
          valueColor: Colors.white,
        ),
      ],
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _Stat({required this.value, required this.label, this.valueColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.0,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextDoseBanner extends StatelessWidget {
  final VaccineDose? next;
  final int delayed;
  final bool overdue;

  const _NextDoseBanner({required this.next, required this.delayed, required this.overdue});

String get _label {
    if (next == null) return 'Protocole sans dose planifiée';
    final journey = next!.jourTheorique;
    return overdue ? 'Dose $journey en retard ($delayed j)' : 'Prochaine dose : $journey';
  }

  @override
  Widget build(BuildContext context) {
    final accent = overdue ? EpidemiologyTheme.warning : const Color(0xFF4ADE80);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.55), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available, size: 18, color: accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _label,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, required this.icon, required this.filled, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = filled
        ? FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: EpidemiologyTheme.redDeep,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          )
        : OutlinedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.10),
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
    return onTap == null
        ? const SizedBox.shrink()
        : filled
            ? FilledButton.icon(onPressed: onTap, icon: Icon(icon, size: 16), label: Text(label), style: style)
            : OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 16), label: Text(label), style: style);
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _Logomark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2A3F).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(Icons.biotech, color: Colors.white, size: 24),
    );
  }
}

class _CategoryGlassBadge extends StatelessWidget {
  final RabiesRiskCategory category;

  const _CategoryGlassBadge({required this.category});

  Color get _color => switch (category) {
    RabiesRiskCategory.categorieI => const Color(0xFF4ADE80),
    RabiesRiskCategory.categorieII => const Color(0xFFFBBF24),
    RabiesRiskCategory.categorieIII => const Color(0xFFF87171),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 15, color: _color),
          const SizedBox(width: 6),
          Text(
            category.label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}