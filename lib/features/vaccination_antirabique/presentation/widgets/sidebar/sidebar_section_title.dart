import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Titre de section de navigation (libellé en petites capitales avec
/// liseré d'accent).
class SidebarSectionTitle extends StatelessWidget {
  final String title;
  final bool collapsed;

  const SidebarSectionTitle({super.key, required this.title, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        height: 1,
        color: EpidemiologyTheme.warm150,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [EpidemiologyTheme.redDeep, EpidemiologyTheme.red400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.warm400,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
