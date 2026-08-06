import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Carte premium de présentation d'un module de vaccination.
///
/// Tuile d'icône en dégradé, statut (Actif / À venir), compteurs
/// patients / retards / alertes et barre d'activité. Un survol et un
/// tap révèlent un feedback visuel.
class ModuleOverviewCard extends StatefulWidget {
  final String title;
  final String sousTitre;
  final String description;
  final IconData icon;
  final Color color;
  final int patientsEnSuivi;
  final int patientsEnRetard;
  final int alertes;
  final bool actif;
  final bool enPreparation;
  final VoidCallback? onTap;

  const ModuleOverviewCard({
    super.key,
    required this.title,
    required this.sousTitre,
    required this.description,
    required this.icon,
    required this.color,
    this.patientsEnSuivi = 0,
    this.patientsEnRetard = 0,
    this.alertes = 0,
    this.actif = false,
    this.enPreparation = false,
    this.onTap,
  });

  @override
  State<ModuleOverviewCard> createState() => _ModuleOverviewCardState();
}

class _ModuleOverviewCardState extends State<ModuleOverviewCard> {
  bool _hovered = false;

  bool get _tildeactive => !widget.enPreparation && !widget.actif;

  @override
  Widget build(BuildContext context) {
    final color = widget.enPreparation
        ? EpidemiologyTheme.warm300
        : widget.color;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enPreparation ? null : widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: (_hovered && !widget.enPreparation)
              ? (Matrix4.identity()..translateByDouble(0, -4, 0, 1))
              : Matrix4.identity(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _hovered
                  ? color.withValues(alpha: 0.35)
                  : color.withValues(alpha: widget.enPreparation ? 0.06 : 0.12),
            ),
            boxShadow: [
              if (_hovered && !widget.enPreparation)
                BoxShadow(
                  color: color.withValues(alpha: 0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                )
              else
                BoxShadow(
                  color: EpidemiologyTheme.blackWith(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.22),
                          color.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withValues(alpha: 0.30)),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 26,
                      color: widget.enPreparation
                          ? EpidemiologyTheme.warm300
                          : color,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: widget.enPreparation
                                ? EpidemiologyTheme.warm400
                                : EpidemiologyTheme.warm900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.sousTitre,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: widget.enPreparation
                                ? EpidemiologyTheme.warm300
                                : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.enPreparation)
                    _badge('À venir', EpidemiologyTheme.warm400)
                  else if (_tildeactive)
                    _badge('Inactif', EpidemiologyTheme.warm300)
                  else if (widget.actif)
                    _badge(
                      'Actif',
                      EpidemiologyTheme.success,
                      icon: Icons.check_circle,
                    ),
                  if (!widget.enPreparation) ...[
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: _hovered
                            ? color.withValues(alpha: 0.16)
                            : color.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _hovered
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_forward,
                        size: 15,
                        color: color,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Text(
                widget.description,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                  color: widget.enPreparation
                      ? EpidemiologyTheme.warm300
                      : EpidemiologyTheme.warm500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _stat(
                    Icons.people,
                    '${widget.patientsEnSuivi}',
                    'Suivis',
                    EpidemiologyTheme.info,
                  ),
                  _stat(
                    Icons.schedule,
                    '${widget.patientsEnRetard}',
                    'Retards',
                    widget.patientsEnRetard > 0
                        ? EpidemiologyTheme.orange
                        : EpidemiologyTheme.warm300,
                  ),
                  _stat(
                    Icons.warning_amber_rounded,
                    '${widget.alertes}',
                    'Alertes',
                    widget.alertes > 0
                        ? EpidemiologyTheme.danger
                        : EpidemiologyTheme.warm300,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.warm800,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: EpidemiologyTheme.warm400,
          ),
        ),
      ],
    );
  }
}