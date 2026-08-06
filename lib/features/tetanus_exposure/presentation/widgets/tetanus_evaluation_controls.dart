import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

/// Option d'un ensemble de choice chips.
class TetanusChoiceOption<T> {
  final T value;
  final String label;
  final String? help;
  final IconData? icon;
  const TetanusChoiceOption(this.value, this.label, {this.help, this.icon});
}

/// Ensemble de choice chips premium, multicolonnes, tactile.
class TetanusChoiceChips<T> extends StatelessWidget {
  const TetanusChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.accent,
    this.gridColumns,
  });

  final List<TetanusChoiceOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final Color? accent;
  final int? gridColumns;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? EpidemiologyTheme.redPrimary;
    final wide = gridColumns; // null => auto wrap
    return LayoutBuilder(builder: (context, constraints) {
      final cols = wide ??
          (constraints.maxWidth >= 560
              ? 2
              : constraints.maxWidth >= 320
                  ? 2
                  : 1);
      if (cols <= 1) {
        return Column(
          children: options.map((o) => _chip(o, accentColor)).toList(),
        );
      }
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final o in options)
            SizedBox(
              width: (constraints.maxWidth - 10) / cols,
              child: _chip(o, accentColor),
            ),
        ],
      );
    });
  }

  Widget _chip(TetanusChoiceOption<T> o, Color accent) {
    final isSelected = o.value == selected;
    return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onChanged(o.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        accent,
                        accent.withValues(alpha: 0.82),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : EpidemiologyTheme.warm150,
                width: 1.4,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : EpidemiologyTheme.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (o.icon != null) ...[
                      Icon(o.icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : accent),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        o.label,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : EpidemiologyTheme.warm800,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: Colors.white),
                  ],
                ),
                if (o.help != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    o.help!,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      height: 1.3,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : EpidemiologyTheme.warm400,
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

/// Rangée de contrôle toggle (interrupteur) premium.
class TetanusToggleTile extends StatelessWidget {
  const TetanusToggleTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
    this.help,
    this.accent,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;
  final String? help;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent ?? EpidemiologyTheme.info;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? accentColor.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? accentColor.withValues(alpha: 0.35)
              : EpidemiologyTheme.warm150,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 20, color: value ? accentColor : EpidemiologyTheme.warm400),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: value
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: value
                            ? EpidemiologyTheme.warm800
                            : EpidemiologyTheme.warm600,
                      ),
                    ),
                    if (help != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        help!,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: EpidemiologyTheme.warm400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 26,
                decoration: BoxDecoration(
                  color: value
                      ? accentColor
                      : EpidemiologyTheme.warm200,
                  borderRadius: BorderRadius.circular(13),
                ),
                padding: const EdgeInsets.all(3),
                alignment: value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: EpidemiologyTheme.blackWith(0.15),
                          blurRadius: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alerte premium avec niveau de sévérité.
class TetanusAlertItem extends StatelessWidget {
  const TetanusAlertItem({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.08), color.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    height: 1.4,
                    color: EpidemiologyTheme.warm600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge de risque / statut premium.
class TetanusBadge extends StatelessWidget {
  const TetanusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 11,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d'information clé d'une carte de synthèse.
class TetanusInfoRow extends StatelessWidget {
  const TetanusInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: EpidemiologyTheme.warm400),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: EpidemiologyTheme.warm500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.warm800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}