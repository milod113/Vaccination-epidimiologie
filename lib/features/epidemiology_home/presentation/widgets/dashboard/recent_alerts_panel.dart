import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Élément de ligne d'activité / alerte.
class RecentAlertItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? time;
  final VoidCallback? onTap;

  const RecentAlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.time,
    this.onTap,
  });
}

/// Paneau « Alertes & activité » agrégant les points de vigilance du jour.
class RecentAlertsPanel extends StatelessWidget {
  final List<RecentAlertItem> items;
  final String title;
  final String? subtitle;
  final Widget? footerAction;

  const RecentAlertsPanel({
    super.key,
    required this.items,
    this.title = 'Alertes & activité',
    this.subtitle,
    this.footerAction,
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
                  color: EpidemiologyTheme.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                  color: EpidemiologyTheme.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.warm900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: EpidemiologyTheme.warm400,
                        ),
                      ),
                  ],
                ),
              ),
              _countBadge(items.length),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => _AlertTile(item: item),
          ),
          if (footerAction != null) ...[
            const SizedBox(height: 12),
            footerAction!,
          ],
        ],
      ),
    );
  }

  Widget _countBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: EpidemiologyTheme.orange,
        ),
      ),
    );
  }
}

class _AlertTile extends StatefulWidget {
  final RecentAlertItem item;
  const _AlertTile({required this.item});

  @override
  State<_AlertTile> createState() => _AlertTileState();
}

class _AlertTileState extends State<_AlertTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? item.color.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: item.color.withValues(alpha: 0.18)),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: EpidemiologyTheme.warm900,
                      ),
                    ),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.time != null)
                Text(
                  item.time!,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: EpidemiologyTheme.warm300,
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: _hovered
                    ? EpidemiologyTheme.warm600
                    : EpidemiologyTheme.warm300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}