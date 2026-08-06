import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Action rapide du tableau de bord d'accueil.
class QuickAction {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });
}

/// Paneau « Accès rapides » : réseau de tuiles d'actions contextuelles.
class QuickActionPanel extends StatelessWidget {
  final List<QuickAction> actions;
  final bool compact;

  const QuickActionPanel({
    super.key,
    required this.actions,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.bolt,
                  size: 18,
                  color: EpidemiologyTheme.redPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Accès rapides',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.warm900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560
                  ? 3
                  : constraints.maxWidth >= 340
                      ? 2
                      : 1;
              final cw = (constraints.maxWidth -
                      (columns - 1) * 12) /
                  columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: actions
                    .map((a) => SizedBox(
                          width: cw,
                          child: _QuickActionTile(action: a),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatefulWidget {
  final QuickAction action;
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
      child: GestureDetector(
        onTap: a.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: _hovered
              ? (Matrix4.identity()..translateByDouble(0, -2, 0, 1))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hovered
                ? a.color.withValues(alpha: 0.06)
                : EpidemiologyTheme.warm50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? a.color.withValues(alpha: 0.35)
                  : a.color.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(a.icon, size: 20, color: a.color),
              const SizedBox(height: 8),
              Text(
                a.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm900,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                a.description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: EpidemiologyTheme.warm400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}