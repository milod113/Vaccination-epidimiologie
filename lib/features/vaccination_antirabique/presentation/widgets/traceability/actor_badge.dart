import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_actor.dart';
import 'traceability_ui.dart';

/// Badge d'acteur : avatar circulaire avec initiales + nom, rôle et service.
class ActorBadge extends StatelessWidget {
  final DossierActor actor;
  final bool compact;

  const ActorBadge({super.key, required this.actor, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final color = TraceabilityUi.roleColor(actor.role);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 30 : 36,
          height: compact ? 30 : 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.72)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            actor.initiales,
            style: GoogleFonts.inter(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actor.nomComplet,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: compact ? 12.5 : 13.5,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.slate900,
                ),
              ),
              if (!compact && actor.service != null) ...[
                const SizedBox(height: 1),
                Text(
                  '${actor.role.label} · ${actor.service}',
                  overflow: TextOverflow.ellipsis,
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
      ],
    );
  }
}
