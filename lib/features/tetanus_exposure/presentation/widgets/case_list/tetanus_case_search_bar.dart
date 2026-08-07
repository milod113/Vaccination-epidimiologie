import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';

/// Barre de recherche premium de la liste des cas tétaniques.
///
/// Recherche sur le nom, l'identifiant, la localisation ou la décision
/// (le filtrage réel est appliqué par l'écran via [onChanged]).
class TetanusCaseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final bool hasQuery;

  const TetanusCaseSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onChanged,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isFocused = focusNode?.hasFocus ?? false;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasQuery || isFocused
                ? EpidemiologyTheme.redPrimary.withValues(alpha: 0.5)
                : EpidemiologyTheme.warm150,
          ),
          boxShadow: EpidemiologyTheme.shadowSm,
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: EpidemiologyTheme.slate900,
          ),
          cursorColor: EpidemiologyTheme.redPrimary,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Rechercher un patient, un ID, une localisation…',
            hintStyle: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.warm400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 6, right: 10),
              child: Icon(
                Icons.search,
                color: hasQuery
                    ? EpidemiologyTheme.redPrimary
                    : EpidemiologyTheme.warm400,
                size: 21,
              ),
            ),
            suffixIcon: hasQuery
                ? IconButton(
                    tooltip: 'Effacer',
                    icon: const Icon(
                      Icons.cancel,
                      color: EpidemiologyTheme.warm400,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                      focusNode?.unfocus();
                    },
                  )
                : const SizedBox(width: 46, height: 46),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}
