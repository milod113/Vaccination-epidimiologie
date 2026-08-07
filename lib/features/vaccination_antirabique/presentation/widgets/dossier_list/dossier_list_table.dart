import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../rabies_dossier_widgets.dart';
import 'dossier_list_models.dart';

/// Tableau responsive premium de la liste des dossiers (desktop).
///
/// Colonnes : patient, commune, catégorie, protocole (avec progression),
/// prochaine dose / statut, action « Consulter ». Lignes cliquables.
class DossierListTable extends StatelessWidget {
  final List<RabiesCaseRecord> dossiers;
  final ValueChanged<String> onOpenDossier;

  const DossierListTable({
    super.key,
    required this.dossiers,
    required this.onOpenDossier,
  });

  static const _columns = <_Column, double>{
    _Column.dossier: 300,
    _Column.commune: 150,
    _Column.categorie: 120,
    _Column.protocole: 220,
    _Column.statut: 240,
    _Column.action: 130,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm150),
        boxShadow: EpidemiologyTheme.shadowCard(EpidemiologyTheme.redPrimary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: _columns.values.fold(0.0, (a, b) => a + b) + 28,
            child: Column(
              children: [
                _headerRow(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: EpidemiologyTheme.warm150,
                ),
                for (final d in dossiers) _row(d),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      children: [
        const SizedBox(width: 14),
        ..._columns.entries.map(
          (e) => SizedBox(
            width: e.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Text(
                e.key.label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: EpidemiologyTheme.warm400,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(RabiesCaseRecord d) {
    final statut = statutProtocole(d);
    final statutColor = couleurProtocole(statut);
    final urgent = d.estUrgent;

    return InkWell(
      onTap: () => onOpenDossier(d.id),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EpidemiologyTheme.warm50)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _cell(_Column.dossier, _dossierCell(d, urgent)),
              _cell(_Column.commune, _communeCell(d)),
              _cell(
                _Column.categorie,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: DossierChip(
                    label: d.categorie.label,
                    icon: Icons.category,
                    color: urgent
                        ? EpidemiologyTheme.danger
                        : EpidemiologyTheme.warning,
                  ),
                ),
              ),
              _cell(_Column.protocole, _protocoleCell(d)),
              _cell(_Column.statut, _statutCell(d, statut, statutColor)),
              _cell(_Column.action, _actionCell(d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(_Column column, Widget child) {
    return SizedBox(
      width: _columns[column],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _dossierCell(RabiesCaseRecord d, bool urgent) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                EpidemiologyTheme.redPrimary,
                EpidemiologyTheme.redMedium,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            d.identity.sexe == PatientGender.feminin
                ? Icons.person_2
                : Icons.person,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      d.patientNomComplet,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: EpidemiologyTheme.slate900,
                      ),
                    ),
                  ),
                  if (urgent) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.priority_high,
                      size: 14,
                      color: EpidemiologyTheme.danger,
                    ),
                  ],
                ],
              ),
              Text(
                d.numeroDossier,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: EpidemiologyTheme.warm400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _communeCell(RabiesCaseRecord d) {
    final commune = d.identity.residence.commune;
    return Text(
      commune.isEmpty ? '—' : commune,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: EpidemiologyTheme.warm600,
      ),
    );
  }

  Widget _protocoleCell(RabiesCaseRecord d) {
    final proto = d.vaccination.protocole;
    final label = proto.doses.isEmpty ? 'Aucun protocole' : proto.type.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: EpidemiologyTheme.slate800,
          ),
        ),
        if (proto.totalDoses > 0) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: 170,
            child: EpidemiologyTheme.doseProgress(
              current: proto.dosesRealisees,
              total: proto.totalDoses,
              height: 6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statutCell(
    RabiesCaseRecord d,
    DossierProtocoleStatut statut,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              dossierEnRetard(d) ? Icons.schedule : Icons.event_available,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                libelleProchaineDose(d),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          statut.label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: EpidemiologyTheme.warm400,
          ),
        ),
      ],
    );
  }

  Widget _actionCell(RabiesCaseRecord d) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: OutlinedButton(
        onPressed: () => onOpenDossier(d.id),
        style: OutlinedButton.styleFrom(
          foregroundColor: EpidemiologyTheme.redPrimary,
          side: BorderSide(
            color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.35),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          minimumSize: const Size(0, 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: const Text('Consulter'),
      ),
    );
  }
}

enum _Column {
  dossier('Dossier'),
  commune('Commune'),
  categorie('Catégorie'),
  protocole('Protocole'),
  statut('Prochaine dose'),
  action('');

  const _Column(this.label);
  final String label;
}
