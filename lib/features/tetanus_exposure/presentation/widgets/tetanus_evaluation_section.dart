import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

/// Carte de section premium de l'évaluation tétanos.
class TetanusEvaluationSection extends StatelessWidget {
  const TetanusEvaluationSection({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    this.subtitle,
    this.trailing,
    this.required = false,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String? subtitle;
  final Widget? trailing;
  final bool required;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowCard(accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.12),
                      accent.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: EpidemiologyTheme.warm900,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        if (required) ...[
                          const SizedBox(width: 6),
                          Text(
                            '*',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: EpidemiologyTheme.danger,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          color: EpidemiologyTheme.warm400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing case final Widget trailingWidget) trailingWidget,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}