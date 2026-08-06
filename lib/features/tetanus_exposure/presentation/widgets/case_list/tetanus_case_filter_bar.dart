import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import 'tetanus_case_list_models.dart';

/// Zone de filtres cliniques premium de la liste des cas tétaniques :
/// statut du dossier (choice chips), filtres rapides prophylactiques
/// et tri intelligent.
class TetanusCaseFilterBar extends StatelessWidget {
  final TetanusCaseStatusFilter status;
  final TetanusCaseQuickFilter? quick;
  final TetanusCaseSortOption sort;
  final int resultCount;
  final ValueChanged<TetanusCaseStatusFilter> onStatusChanged;
  final ValueChanged<TetanusCaseQuickFilter?> onQuickChanged;
  final ValueChanged<TetanusCaseSortOption> onSortChanged;
  final VoidCallback onReset;

  const TetanusCaseFilterBar({
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

  bool get _hasActive => status != TetanusCaseStatusFilter.tout || quick != null;

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
              const Icon(Icons.tune,
                  size: 15, color: EpidemiologyTheme.warm400),
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.people_outline,
                        size: 15, color: EpidemiologyTheme.redPrimary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$resultCount cas affiché(s)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.slate700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  'Tri : ${sort.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: EpidemiologyTheme.warm400,
                  ),
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
      children: TetanusCaseStatusFilter.values.map((f) {
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
        children: TetanusCaseQuickFilter.values.map((f) {
          final selected = quick == f;
          final color = switch (f) {
            TetanusCaseQuickFilter.tetanigene => EpidemiologyTheme.danger,
            TetanusCaseQuickFilter.ig => EpidemiologyTheme.indigo,
            TetanusCaseQuickFilter.rappel => EpidemiologyTheme.warning,
            TetanusCaseQuickFilter.vaccinRequis => EpidemiologyTheme.info,
            TetanusCaseQuickFilter.corpsEtranger => EpidemiologyTheme.orange,
            TetanusCaseQuickFilter.surveillance => EpidemiologyTheme.success,
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
              avatar: Icon(f.icon,
                  size: 14, color: selected ? Colors.white : color),
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
    return PopupMenuButton<TetanusCaseSortOption>(
      tooltip: 'Trier la liste',
      initialValue: sort,
      onSelected: onSortChanged,
      color: EpidemiologyTheme.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => TetanusCaseSortOption.values
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

  IconData _sortIcon(TetanusCaseSortOption o) => switch (o) {
        TetanusCaseSortOption.urgent => Icons.local_fire_department_outlined,
        TetanusCaseSortOption.recent => Icons.access_time_filled,
        TetanusCaseSortOption.decision => Icons.medical_information_outlined,
        TetanusCaseSortOption.nom => Icons.sort_by_alpha,
      };
}