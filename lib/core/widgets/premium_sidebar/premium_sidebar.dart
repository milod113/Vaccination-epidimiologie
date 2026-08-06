import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/epidemiology_theme.dart';
import 'premium_sidebar_footer.dart';
import 'premium_sidebar_header.dart';
import 'premium_sidebar_models.dart';
import 'premium_sidebar_nav_item.dart';
import 'premium_sidebar_quick_actions.dart';
import 'premium_sidebar_section_title.dart';
import 'premium_sidebar_stats_card.dart';

/// Sidebar premium de la plateforme, générique sur la destination [T].
///
/// Chaque module reutilise ce composant en fournissant son [SidebarIdentity]
/// (titre, sous-titre, pictogramme, centre) et ses sections / actions /
/// stats. Assemble l'identité de marque, la navigation principale (avec
/// badges et indicateurs), les actions rapides, le résumé du centre et la
/// zone de contexte. Supporte un mode réduit (icônes seules).
class PremiumSidebar<T> extends StatefulWidget {
  final SidebarIdentity identity;
  final List<SidebarSection<T>> sections;
  final T current;
  final ValueChanged<T> onNavigate;
  final List<SidebarQuickAction> quickActions;
  final List<SidebarStatsEntry> stats;
  final String statsTitle;
  final bool collapsed;
  final VoidCallback? onToggleCollapsed;

  const PremiumSidebar({
    super.key,
    required this.identity,
    required this.sections,
    required this.current,
    required this.onNavigate,
    this.quickActions = const [],
    this.stats = const [],
    this.statsTitle = 'RÉSUMÉ DU CENTRE',
    this.collapsed = false,
    this.onToggleCollapsed,
  });

  @override
  State<PremiumSidebar<T>> createState() => _PremiumSidebarState<T>();
}

class _PremiumSidebarState<T> extends State<PremiumSidebar<T>> {
  @override
  Widget build(BuildContext context) {
    final collapsed = widget.collapsed;
    final bg = collapsed ? EpidemiologyTheme.white : const Color(0xFFFDFEFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOutCubic,
      width: collapsed ? 78 : 288,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg, collapsed ? bg : EpidemiologyTheme.warm50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          right: BorderSide(color: EpidemiologyTheme.warm150.withValues(alpha: 0.7), width: 1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(collapsed ? 8 : 16, 16, collapsed ? 8 : 16, 14),
            child: SidebarHeader(
              identity: widget.identity,
              collapsed: collapsed,
              onToggle: widget.onToggleCollapsed,
            ),
          ),
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: EpidemiologyTheme.warm150.withValues(alpha: 0.8), height: 1),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: collapsed ? 8 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._buildSections(collapsed),
                  if (!collapsed) ...[
                    const SizedBox(height: 10),
                    SidebarQuickActions(actions: widget.quickActions),
                    const SizedBox(height: 6),
                    SidebarStatsCard(stats: widget.stats, title: widget.statsTitle),
                  ],
                ],
              ),
            ),
          ),
          if (!collapsed)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: EpidemiologyTheme.warm150.withValues(alpha: 0.8), height: 1),
            ),
          SidebarFooter(identity: widget.identity, collapsed: collapsed),
        ],
      ),
    );
  }

  List<Widget> _buildSections(bool collapsed) {
    final widgets = <Widget>[];
    for (final section in widget.sections) {
      widgets.add(SidebarSectionTitle(title: section.title, collapsed: collapsed));
      for (final item in section.items) {
        widgets.add(SidebarNavItem<T>(
          item: item,
          selected: item.destination == widget.current,
          collapsed: collapsed,
          onTap: () {
            if (item.destination != widget.current) {
              widget.onNavigate(item.destination);
            }
          },
        ));
      }
    }
    return widgets;
  }
}

/// Version compacte de la sidebar pour les largeurs moyennes : une fine
/// rangée d'icônes reste visible quand l'espace est limité.
class PremiumSidebarRail<T> extends StatelessWidget {
  final List<SidebarNavItemModel<T>> items;
  final T current;
  final ValueChanged<T> onNavigate;

  const PremiumSidebarRail({
    super.key,
    required this.items,
    required this.current,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        border: Border(right: BorderSide(color: EpidemiologyTheme.warm150, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: items.map((item) {
          final isActive = item.destination == current;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onNavigate(item.destination),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                height: 44,
                decoration: BoxDecoration(
                  color: isActive ? EpidemiologyTheme.redLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isActive)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: _RailAccentBar(),
                      ),
                    Tooltip(
                      message: item.label,
                      waitDuration: const Duration(milliseconds: 400),
                      child: Icon(
                        item.icon,
                        size: 19,
                        color: isActive ? EpidemiologyTheme.redDeep : EpidemiologyTheme.warm400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RailAccentBar extends StatelessWidget {
  const _RailAccentBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 9),
      width: 3,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EpidemiologyTheme.redDeep, EpidemiologyTheme.red400],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// Petit compteur dédié à l'en-tête compact (cohérence visuelle des badges).
class SidebarMiniBadge extends StatelessWidget {
  final int count;
  final Color color;

  const SidebarMiniBadge({super.key, required this.count, this.color = EpidemiologyTheme.redPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}