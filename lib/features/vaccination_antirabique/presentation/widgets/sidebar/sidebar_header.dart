import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// En-tête de marque premium de la sidebar antirabique.
class SidebarHeader extends StatelessWidget {
  final bool collapsed;
  final VoidCallback? onToggle;

  const SidebarHeader({super.key, this.collapsed = false, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(collapsed ? 12 : 16),
        decoration: BoxDecoration(
          gradient: EpidemiologyTheme.primaryGradientWarm,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: EpidemiologyTheme.redDeep.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: EpidemiologyTheme.redDeep.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: collapsed
            ? _CollapsedHeader(onToggle: onToggle)
            : _ExpandedHeader(onToggle: onToggle),
      ),
    );
  }
}

class _CollapsedHeader extends StatelessWidget {
  const _CollapsedHeader({this.onToggle});
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LogoMark(size: 40),
        const SizedBox(height: 18),
        IconButton(
          onPressed: onToggle,
          tooltip: 'Agrandir le menu',
          padding: EdgeInsets.zero,
          icon: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.85), size: 22),
        ),
      ],
    );
  }
}

class _ExpandedHeader extends StatelessWidget {
  const _ExpandedHeader({this.onToggle});
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _LogoMark(size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vaccination\nAntirabique',
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.12,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Service d’Épidémiologie',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.78),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggle,
              tooltip: 'Réduire le menu',
              icon: Icon(Icons.chevron_left, color: Colors.white.withValues(alpha: 0.85), size: 22),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.14),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _StatusChip(),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(width: 5),
                  Text(
                    '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pastille logo avec halo doux.
class _LogoMark extends StatelessWidget {
  const _LogoMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A2A3F).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(Icons.biotech, color: Colors.white, size: size * 0.52),
    );
  }
}

/// Petit badge de statut « En service ».
class _StatusChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF34D399),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'En service',
            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
