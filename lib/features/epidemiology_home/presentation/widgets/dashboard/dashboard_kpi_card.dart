import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Carte indicateur (KPI) premium du dashboard d'accueil.
///
/// Affiche une tuile d'icône teintée, une valeur forte, un libellé et un
/// sous-texte contextuel. Utilisée dans la rangée des indicateurs clés.
class DashboardKpiCard extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? hint;
  final Color accent;
  final Color? tint;
  final VoidCallback? onTap;

  const DashboardKpiCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.hint,
    required this.accent,
    this.tint,
    this.onTap,
  });

  @override
  State<DashboardKpiCard> createState() => _DashboardKpiCardState();
}

class _DashboardKpiCardState extends State<DashboardKpiCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tint = widget.tint ?? widget.accent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..translateByDouble(0, -3, 0, 1))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? EpidemiologyTheme.white : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? tint.withValues(alpha: 0.4)
                  : EpidemiologyTheme.warm100.withValues(alpha: 0.8),
            ),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: tint.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: EpidemiologyTheme.warm900.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tint.withValues(alpha: 0.20),
                          tint.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tint.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(widget.icon, size: 19, color: widget.accent),
                  ),
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.warm900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.warm700,
                ),
              ),
              if (widget.hint != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.hint!,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: EpidemiologyTheme.warm400,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
