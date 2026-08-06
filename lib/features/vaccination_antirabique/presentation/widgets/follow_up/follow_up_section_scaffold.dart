import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Gabarit commun des sections du parcours de suivi.
///
/// Affiche un en-tête premium (icône, titre, sous-titre) puis le contenu de
/// la section, avec une mise en page responsive (simple colonne sur mobile,
/// colonnes multiples sur grand écran via [isWide]).
class FollowUpSectionScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color accent;
  final List<Widget> children;
  final Widget? trailing;

  const FollowUpSectionScaffold({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.accent,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent.withValues(alpha: 0.16), accent.withValues(alpha: 0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, size: 22, color: accent),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.slate900,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: EpidemiologyTheme.slate500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
