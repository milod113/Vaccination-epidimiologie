import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_history.dart';
import 'history_entry_tile.dart';

/// Timeline verticale premium de l'historique réglementaire du dossier.
///
/// Affiche les événements du plus récent au plus ancien avec un rail visuel
/// (points colorés par type d'action) et des cartes individuelles.
class DossierHistoryTimeline extends StatelessWidget {
  final List<RabiesDossierHistoryEntry> entries;

  const DossierHistoryTimeline({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.indigo.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: EpidemiologyTheme.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historique des modifications',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                    Text(
                      'Chaque action est signée et horodatée',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              _countBadge(),
            ],
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            _empty()
          else
            for (var i = 0; i < entries.length; i++)
              HistoryEntryTile(
                entry: entries[i],
                isLast: i == entries.length - 1,
              ),
        ],
      ),
    );
  }

  Widget _countBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.indigo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${entries.length} év.',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 30, color: EpidemiologyTheme.warm300),
          const SizedBox(height: 8),
          Text(
            'Aucun événement enregistré',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
