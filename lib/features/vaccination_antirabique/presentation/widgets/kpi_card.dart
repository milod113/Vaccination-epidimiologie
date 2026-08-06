import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final double? valueFontSize;
  final String? subtitle;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.valueFontSize,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = color ?? EpidemiologyTheme.redPrimary;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: EpidemiologyTheme.blackWith(0.04), blurRadius: 10, offset: const Offset(0, 2)),
          BoxShadow(color: accentColor.withValues(alpha: 0.03), blurRadius: 18, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const Spacer(),
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(value, style: GoogleFonts.inter(
            fontSize: valueFontSize ?? 28, fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.warm900, height: 1.0, letterSpacing: -0.5,
          )),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: EpidemiologyTheme.warm400, height: 1.2,
          )),
          if (subtitle != null) ...[
            const SizedBox(height: 1),
            Text(subtitle!, style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w400,
              color: EpidemiologyTheme.warm300, height: 1.2,
            )),
          ],
        ],
      ),
    );
  }
}
