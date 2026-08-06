import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// En-tête héro premium de la plateforme épidémiologie.
///
/// Nom de la plateforme, sous-titre institutionnel, date du jour,
/// indicateur d'état des services et bouton d'action principal (CTA).
class PlatformHeroHeader extends StatefulWidget {
  final String platformName;
  final String subtitle;
  final String dateLabel;
  final int modulesActifs;
  final int modulesTotal;
  final String ctaLabel;
  final VoidCallback? onCta;
  final bool servicesOperational;

  const PlatformHeroHeader({
    super.key,
    required this.platformName,
    required this.subtitle,
    required this.dateLabel,
    required this.modulesActifs,
    required this.modulesTotal,
    required this.ctaLabel,
    this.onCta,
    this.servicesOperational = true,
  });

  @override
  State<PlatformHeroHeader> createState() => _PlatformHeroHeaderState();
}

class _PlatformHeroHeaderState extends State<PlatformHeroHeader> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        widget.servicesOperational ? EpidemiologyTheme.success : EpidemiologyTheme.orange;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EpidemiologyTheme.redDeep, EpidemiologyTheme.redPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Halo décoratif haut-droit.
          Positioned(
            right: -70,
            top: -90,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final iconTile = Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: const Icon(
                        Icons.monitor_heart_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
                    );
                    final titleBlock = Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.platformName,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    );
                    final statusChip = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: statusColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.servicesOperational
                                  ? 'Services opérationnels'
                                  : 'Maintenance',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                    final wide = constraints.maxWidth >= 430;
                    if (!wide) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [iconTile, const SizedBox(width: 14), titleBlock]),
                          const SizedBox(height: 10),
                          statusChip,
                        ],
                      );
                    }
                    return Row(children: [iconTile, const SizedBox(width: 14), titleBlock, statusChip]);
                  },
                ),
                const SizedBox(height: 22),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 620;
                    final meta = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.dateLabel,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.hub_outlined,
                          size: 15,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${widget.modulesActifs}/${widget.modulesTotal} modules actifs',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                      ],
                    );
                    final cta = MouseRegion(
                      onEnter: (_) => setState(() => _hovered = true),
                      onExit: (_) => setState(() => _hovered = false),
                      child: GestureDetector(
                        onTap: widget.onCta,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          transform: _hovered
                              ? (Matrix4.identity()..translateByDouble(0, -2, 0, 1))
                              : Matrix4.identity(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: _hovered
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.ctaLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: EpidemiologyTheme.redDeep,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_downward_rounded,
                                size: 16,
                                color: EpidemiologyTheme.redDeep,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          meta,
                          const SizedBox(height: 16),
                          cta,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: meta),
                        const SizedBox(width: 12),
                        cta,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
