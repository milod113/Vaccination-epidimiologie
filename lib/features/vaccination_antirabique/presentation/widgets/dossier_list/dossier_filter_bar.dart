import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import 'dossier_list_models.dart';

/// Zone de filtres premium de la liste des dossiers : statut principal
/// (choice chips), filtres rapides (catégorie / protocole / ERIG / dose du
/// jour), filtre commune, tri et bouton « Réinitialiser ».
class DossierFilterBar extends StatelessWidget {
  final DossierStatusFilter status;
  final DossierQuickFilter? quick;
  final DossierSortOption sort;
  final List<String> communes;
  final String? selectedCommune;
  final int resultCount;
  final ValueChanged<DossierStatusFilter> onStatusChanged;
  final ValueChanged<DossierQuickFilter?> onQuickChanged;
  final ValueChanged<DossierSortOption> onSortChanged;
  final ValueChanged<String?> onCommuneChanged;
  final VoidCallback onReset;

  const DossierFilterBar({
    super.key,
    required this.status,
    required this.quick,
    required this.sort,
    required this.communes,
    required this.selectedCommune,
    required this.resultCount,
    required this.onStatusChanged,
    required this.onQuickChanged,
    required this.onSortChanged,
    required this.onCommuneChanged,
    required this.onReset,
  });

  bool get _hasActive =>
      status != DossierStatusFilter.all ||
      quick != null ||
      selectedCommune != null;

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
              const Icon(
                Icons.tune,
                size: 15,
                color: EpidemiologyTheme.warm400,
              ),
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
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: EpidemiologyTheme.warm50,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: EpidemiologyTheme.warm150),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh,
                          size: 13,
                          color: EpidemiologyTheme.warm500,
                        ),
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
              const Icon(
                Icons.folder_outlined,
                size: 15,
                color: EpidemiologyTheme.redPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$resultCount dossier${resultCount > 1 ? 's' : ''} affiché${resultCount > 1 ? 's' : ''}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.slate700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _communeDropdown(),
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
      children: DossierStatusFilter.values.map((f) {
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
        children: DossierQuickFilter.values.map((f) {
          final selected = quick == f;
          final color = couleurQuickFilter(f);
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
              avatar: Icon(
                f.icon,
                size: 14,
                color: selected ? Colors.white : color,
              ),
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
    return PopupMenuButton<DossierSortOption>(
      tooltip: 'Trier la liste',
      initialValue: sort,
      onSelected: onSortChanged,
      color: EpidemiologyTheme.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => DossierSortOption.values
          .map(
            (o) => PopupMenuItem(
              value: o,
              child: Row(
                children: [
                  Icon(
                    sortOptionIcon(o),
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
                      fontWeight: o == sort ? FontWeight.w700 : FontWeight.w500,
                      color: o == sort
                          ? EpidemiologyTheme.redPrimary
                          : EpidemiologyTheme.slate700,
                    ),
                  ),
                ],
              ),
            ),
          )
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
            const Icon(
              Icons.swap_vert,
              size: 14,
              color: EpidemiologyTheme.warm500,
            ),
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

  Widget _communeDropdown() {
    if (communes.isEmpty) return const SizedBox.shrink();
    final selected = selectedCommune ?? 'Toutes les communes';
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected,
        borderRadius: BorderRadius.circular(14),
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: EpidemiologyTheme.warm600,
        ),
        icon: const Icon(
          Icons.location_on_outlined,
          size: 14,
          color: EpidemiologyTheme.warm400,
        ),
        items: [
          DropdownMenuItem(
            value: 'Toutes les communes',
            child: Text(
              'Toutes les communes',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: EpidemiologyTheme.warm600,
              ),
            ),
          ),
          ...communes.map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(
                c,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: EpidemiologyTheme.slate700,
                ),
              ),
            ),
          ),
        ],
        onChanged: (value) {
          onCommuneChanged(
            value == null || value == 'Toutes les communes' ? null : value,
          );
        },
      ),
    );
  }
}
