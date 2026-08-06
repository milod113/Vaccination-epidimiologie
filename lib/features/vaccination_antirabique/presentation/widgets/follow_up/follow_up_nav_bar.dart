import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Destination du parcours de suivi.
enum FollowUpSection {
  doses('Suivi des doses', Icons.vaccines),
  reactions('Réactions post-vaccinales', Icons.health_and_safety_outlined),
  evolution('Évolution', Icons.flag_outlined),
  tracabilite('Traçabilité', Icons.receipt_long_outlined),
  animal('Statut de l\'animal', Icons.pets);

  final String label;
  final IconData icon;

  const FollowUpSection(this.label, this.icon);
}

/// Barre de navigation des sections du suivi (segmented control responsive).
///
/// Sur grand écran : segments côte à côte. Sur petit écran : chips défilants
/// horizontalement. Les alertes critiques peuvent être signalées par un point.
class FollowUpNavBar extends StatelessWidget {
  final FollowUpSection current;
  final ValueChanged<FollowUpSection> onChanged;
  final Map<FollowUpSection, int>? badgeCounts;

  const FollowUpNavBar({
    super.key,
    required this.current,
    required this.onChanged,
    this.badgeCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: EpidemiologyTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 720;
          if (narrow) return _scrollable();
          return _segments();
        },
      ),
    );
  }

  Widget _segments() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.warm100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final s in FollowUpSection.values) ...[
            if (s != FollowUpSection.values.first) const SizedBox(width: 4),
            Expanded(child: _segment(s)),
          ],
        ],
      ),
    );
  }

  Widget _segment(FollowUpSection s) {
    final active = s == current;
    return GestureDetector(
      onTap: () => onChanged(s),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: active ? EpidemiologyTheme.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active ? EpidemiologyTheme.shadowSm : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              s.icon,
              size: 17,
              color: active ? EpidemiologyTheme.redPrimary : EpidemiologyTheme.slate400,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                s.label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: active ? EpidemiologyTheme.slate900 : EpidemiologyTheme.slate500,
                ),
              ),
            ),
            if (_badge(s) > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.danger,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_badge(s)}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _scrollable() {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: FollowUpSection.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final s = FollowUpSection.values[index];
          final active = s == current;
          return GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? EpidemiologyTheme.redPrimary : EpidemiologyTheme.warm100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    s.icon,
                    size: 16,
                    color: active ? Colors.white : EpidemiologyTheme.slate500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : EpidemiologyTheme.slate600,
                    ),
                  ),
                  if (_badge(s) > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: active ? Colors.white : EpidemiologyTheme.danger,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_badge(s)}',
                        style: GoogleFonts.inter(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: active ? EpidemiologyTheme.redPrimary : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _badge(FollowUpSection s) => badgeCounts?[s] ?? 0;
}
