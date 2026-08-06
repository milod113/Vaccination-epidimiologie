import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import 'sidebar_models.dart';

/// Item de navigation premium : pill actif, icône mise en avant, badge,
/// survol élégant et micro-interactions.
class SidebarNavItem extends StatefulWidget {
  final SidebarNavItemModel item;
  final bool selected;
  final bool collapsed;
  final VoidCallback? onTap;

  const SidebarNavItem({
    super.key,
    required this.item,
    this.selected = false,
    this.collapsed = false,
    this.onTap,
  });

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected;
    final isCollapsed = widget.collapsed;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        height: 46,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: isActive
              ? EpidemiologyTheme.redLight
              : _hovered
                  ? EpidemiologyTheme.warm100
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Barre d'accent gauche sur l'élément actif.
            AnimatedOpacity(
              opacity: isActive ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(vertical: 9),
                width: 3.5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [EpidemiologyTheme.redDeep, EpidemiologyTheme.red400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: isCollapsed ? 46 : 40,
                  child: Center(
                    child: _IconSquare(
                      icon: widget.item.icon,
                      active: isActive,
                      hovered: _hovered,
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 160),
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? EpidemiologyTheme.redDeep : EpidemiologyTheme.warm500,
                        letterSpacing: -0.1,
                      ),
                      child: Text(
                        widget.item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SidebarBadge(item: widget.item),
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Carré d'icône mis en avant selon l'état.
class _IconSquare extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool hovered;

  const _IconSquare({required this.icon, required this.active, required this.hovered});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? EpidemiologyTheme.redDeep
        : hovered
            ? EpidemiologyTheme.redMedium
            : EpidemiologyTheme.warm400;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active
            ? Colors.white.withValues(alpha: 0.7)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? Colors.white.withValues(alpha: 0.6) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// Badge de compteur / alerte positionné sur la droite de l'item.
class _SidebarBadge extends StatelessWidget {
  final SidebarNavItemModel item;

  const _SidebarBadge({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.showDot && (item.badge == null || item.badge == 0)) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: item.dotColor ?? EpidemiologyTheme.danger,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (item.dotColor ?? EpidemiologyTheme.danger).withValues(alpha: 0.4),
              blurRadius: 6,
            ),
          ],
        ),
      );
    }

    if (item.badge == null || item.badge == 0) return const SizedBox.shrink();

    final (bg, fg) = switch (item.badgeTone) {
      SidebarBadgeTone.danger => (EpidemiologyTheme.dangerLight, EpidemiologyTheme.dangerDark),
      SidebarBadgeTone.warning => (EpidemiologyTheme.warningLight, EpidemiologyTheme.warningDark),
      SidebarBadgeTone.success => (EpidemiologyTheme.successLight, EpidemiologyTheme.successDark),
      SidebarBadgeTone.info || SidebarBadgeTone.neutral => (
        EpidemiologyTheme.redLight,
        EpidemiologyTheme.redMedium
      ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.14), width: 1),
      ),
      child: Text(
        '${item.badge}',
        style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
