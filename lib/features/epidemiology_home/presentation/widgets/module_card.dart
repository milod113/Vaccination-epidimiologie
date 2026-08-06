import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final String sousTitre;
  final String description;
  final IconData icon;
  final Color color;
  final int patientsEnSuivi;
  final int alertes;
  final bool actif;
  final bool enPreparation;
  final VoidCallback? onTap;

  const ModuleCard({
    super.key,
    required this.title,
    required this.sousTitre,
    required this.description,
    required this.icon,
    required this.color,
    this.patientsEnSuivi = 0,
    this.alertes = 0,
    this.actif = false,
    this.enPreparation = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 480;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enPreparation ? null : onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 18 : 22),
          decoration: BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: enPreparation ? 0.06 : 0.10)),
            boxShadow: [
              BoxShadow(color: EpidemiologyTheme.blackWith(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              BoxShadow(color: color.withValues(alpha: 0.03), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: enPreparation ? EpidemiologyTheme.warm100 : color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 24,
                      color: enPreparation ? EpidemiologyTheme.warm300 : color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: EpidemiologyTheme.h3(color: enPreparation ? EpidemiologyTheme.warm400 : EpidemiologyTheme.warm900)),
                        const SizedBox(height: 2),
                        Text(sousTitre,
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
                            color: enPreparation ? EpidemiologyTheme.warm300 : color)),
                      ],
                    ),
                  ),
                  if (enPreparation)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: EpidemiologyTheme.warm100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('À venir', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warm400)),
                    )
                  else if (actif)
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: EpidemiologyTheme.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(description,
                style: EpidemiologyTheme.bodySm(color: enPreparation ? EpidemiologyTheme.warm300 : EpidemiologyTheme.warm500),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statItem(Icons.people, '$patientsEnSuivi', 'Patients'),
                  const SizedBox(width: 16),
                  _statItem(Icons.warning_amber, '$alertes', 'Alertes'),
                  const Spacer(),
                  if (!enPreparation)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Accéder', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: color),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: EpidemiologyTheme.warm400),
        const SizedBox(width: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800)),
        const SizedBox(width: 3),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: EpidemiologyTheme.warm400)),
      ],
    );
  }
}
