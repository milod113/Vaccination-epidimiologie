import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Zone de contexte utilisateur / service en bas de la sidebar.
class SidebarFooter extends StatelessWidget {
  final bool collapsed;

  const SidebarFooter({super.key, this.collapsed = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      padding: EdgeInsets.all(collapsed ? 8 : 12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EpidemiologyTheme.warm150, width: 1),
      ),
      child: collapsed
          ? _buildAvatar()
          : Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Centre Antirabique',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.warm800,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Service d’Épidémiologie',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: EpidemiologyTheme.warm400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.medical_services_outlined, size: 16, color: EpidemiologyTheme.redPrimary),
                ),
              ],
            ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: collapsed ? 36 : 38,
      height: collapsed ? 36 : 38,
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.redDeep.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.local_hospital, color: Colors.white, size: 19),
      ),
    );
  }
}
