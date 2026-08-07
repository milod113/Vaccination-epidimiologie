import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/tetanus_models.dart';
import 'tetanus_act_ui.dart';

/// Sélecteur premium des types d'acte (cartes tactiles avec icône + description).
class TetanusActTypeSelector extends StatelessWidget {
  const TetanusActTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TetanusActType selected;
  final ValueChanged<TetanusActType> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 560
            ? 3
            : constraints.maxWidth >= 360
            ? 2
            : 1;
        final spacing = 10.0;
        final width = (constraints.maxWidth - (cols - 1) * spacing) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final type in TetanusActType.values)
              SizedBox(width: width, child: _card(type)),
          ],
        );
      },
    );
  }

  Widget _card(TetanusActType type) {
    final isSelected = type == selected;
    final color = tetanusActColor(type);
    final icon = tetanusActIcon(type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : EpidemiologyTheme.warm150,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.22)
                          : color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                type.shortLabel,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: isSelected ? Colors.white : EpidemiologyTheme.warm800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                type.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  height: 1.4,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.9)
                      : EpidemiologyTheme.warm400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
