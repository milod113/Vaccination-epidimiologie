import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/epidemiology_theme.dart';
import 'premium_sidebar_models.dart';

/// Carte « Actions rapides » premium : actions clés du centre accessibles en
/// un geste, présentées sous forme de tuiles colorées.
class SidebarQuickActions extends StatelessWidget {
  final List<SidebarQuickAction> actions;

  const SidebarQuickActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.warm150, width: 1),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.blackWith(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, size: 14, color: EpidemiologyTheme.redPrimary),
              const SizedBox(width: 6),
              Text(
                'ACTIONS RAPIDES',
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm400,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.45,
            children: actions.map((a) => _QuickActionTile(action: a)).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final SidebarQuickAction action;

  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: a.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? a.color.withValues(alpha: 0.10) : EpidemiologyTheme.warm50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered ? a.color.withValues(alpha: 0.35) : EpidemiologyTheme.warm150,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: a.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(a.icon, size: 14, color: a.color),
              ),
              const SizedBox(height: 6),
              Text(
                a.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.warm700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}