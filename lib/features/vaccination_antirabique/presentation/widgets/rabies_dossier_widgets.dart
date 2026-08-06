import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

/// Une ligne libellé / valeur dans les sections du dossier.
class DossierInfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? valueColor;

  const DossierInfoRow({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final v = value == null || value!.isEmpty ? '—' : value!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon!, size: 14, color: EpidemiologyTheme.warm400),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.warm500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? EpidemiologyTheme.slate900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de section (A, B, C…) dans le détail du dossier.
class DossierSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;
  final String? letter;
  final String? subtitle;
  final Widget? trailing;

  const DossierSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
    this.letter,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.blackWith(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: EpidemiologyTheme.warmShadow(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Padding(padding: const EdgeInsets.all(18), child: child),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.12), accent.withValues(alpha: 0.03)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.12))),
      ),
      child: Row(
        children: [
          if (letter != null) ...[
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                letter!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: EpidemiologyTheme.slate500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Pastille de statut colorée (urgent, catégorie, retard…).
class DossierChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool subtle;

  const DossierChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.subtle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: subtle ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formate une date en JJ/MM/AAAA.
String ddMMyyyy(DateTime? d) {
  if (d == null) return '—';
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd/$mm/${d.year}';
}