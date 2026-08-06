import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import 'patient_list_models.dart';

/// Zone de filtres cliniques premium : statut principal (choice chips),
/// filtres rapides (catégorie / protocole / RIG / dose du jour) et tri.
class PatientFilterBar extends StatelessWidget {
  final PatientStatusFilter status;
  final PatientQuickFilter? quick;
  final PatientSortOption sort;
  final int resultCount;
  final ValueChanged<PatientStatusFilter> onStatusChanged;
  final ValueChanged<PatientQuickFilter?> onQuickChanged;
  final ValueChanged<PatientSortOption> onSortChanged;
  final VoidCallback onReset;

  const PatientFilterBar({
    super.key,
    required this.status,
    required this.quick,
    required this.sort,
    required this.resultCount,
    required this.onStatusChanged,
    required this.onQuickChanged,
    required this.onSortChanged,
    required this.onReset,
  });

  bool get _hasActive =>
      status != PatientStatusFilter.all || quick != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 15, color: EpidemiologyTheme.warm400),
              const SizedBox(width: 6),
              Text(
                'Filtres',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm500,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              _sortMenu(),
              if (_hasActive) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onReset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: EpidemiologyTheme.warm50,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: EpidemiologyTheme.warm150),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh,
                            size: 13, color: EpidemiologyTheme.warm500),
                        const SizedBox(width: 4),
                        Text(
                          'Réinitialiser',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.warm600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _statusChips(),
          const SizedBox(height: 10),
          _quickChips(),
          const SizedBox(height: 10),
          Divider(height: 1, color: EpidemiologyTheme.warm100),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 15, color: EpidemiologyTheme.redPrimary),
              const SizedBox(width: 6),
              Text(
                '$resultCount patient(s) affiché(s)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.slate700,
                ),
              ),
              const Spacer(),
              Text(
                'Tri : ${sort.label}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.warm400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChips() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: PatientStatusFilter.values.map((f) {
        final selected = status == f;
        return ChoiceChip(
          label: Text(
            f.label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? Colors.white : EpidemiologyTheme.warm600,
            ),
          ),
          selected: selected,
          showCheckmark: false,
          selectedColor: EpidemiologyTheme.redPrimary,
          backgroundColor: EpidemiologyTheme.warm50,
          side: BorderSide(
            color: selected
                ? EpidemiologyTheme.redPrimary
                : EpidemiologyTheme.warm150,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          visualDensity: VisualDensity.compact,
          onSelected: (_) => onStatusChanged(f),
        );
      }).toList(),
    );
  }

  Widget _quickChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: PatientQuickFilter.values.map((f) {
          final selected = quick == f;
          final color = switch (f) {
            PatientQuickFilter.categorieIII ||
            PatientQuickFilter.rig =>
              EpidemiologyTheme.danger,
            PatientQuickFilter.categorieI => EpidemiologyTheme.success,
            PatientQuickFilter.categorieII => EpidemiologyTheme.warning,
            PatientQuickFilter.doseAujourdhui => EpidemiologyTheme.orange,
            _ => EpidemiologyTheme.info,
          };
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: FilterChip(
              label: Text(
                f.label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : color,
                ),
              ),
              avatar: Icon(f.icon, size: 14, color: selected ? Colors.white : color),
              selected: selected,
              showCheckmark: false,
              selectedColor: color,
              backgroundColor: color.withValues(alpha: 0.07),
              side: BorderSide(color: color.withValues(alpha: 0.35)),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onSelected: (_) => onQuickChanged(selected ? null : f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sortMenu() {
    return PopupMenuButton<PatientSortOption>(
      tooltip: 'Trier la liste',
      initialValue: sort,
      onSelected: onSortChanged,
      color: EpidemiologyTheme.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => PatientSortOption.values
          .map((o) => PopupMenuItem(
                value: o,
                child: Row(
                  children: [
                    Icon(
                      _sortIcon(o),
                      size: 16,
                      color: o == sort
                          ? EpidemiologyTheme.redPrimary
                          : EpidemiologyTheme.warm400,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      o.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight:
                            o == sort ? FontWeight.w700 : FontWeight.w500,
                        color: o == sort
                            ? EpidemiologyTheme.redPrimary
                            : EpidemiologyTheme.slate700,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.warm50,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: EpidemiologyTheme.warm150),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert,
                size: 14, color: EpidemiologyTheme.warm500),
            const SizedBox(width: 4),
            Text(
              'Trier',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.warm600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _sortIcon(PatientSortOption o) => switch (o) {
        PatientSortOption.urgent => Icons.local_fire_department_outlined,
        PatientSortOption.retard => Icons.hourglass_bottom,
        PatientSortOption.doseDuJour => Icons.notifications_active_outlined,
        PatientSortOption.nom => Icons.sort_by_alpha,
        PatientSortOption.recent => Icons.access_time_filled,
      };
}
