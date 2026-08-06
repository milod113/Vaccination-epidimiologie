import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../../domain/services/tetanus_evaluation_service.dart';
import '../../data/models/tetanus_models.dart';
import '../widgets/tetanus_evaluation_section.dart';
import '../widgets/tetanus_evaluation_controls.dart';
import '../widgets/tetanus_risk_card.dart';
import '../widgets/tetanus_decision_card.dart';
import '../widgets/case_detail/tetanus_case_detail_hero.dart';

/// Détail d'un cas tétanique pris en charge.
///
/// Synthèse clinique premium : héros du cas, alerte éventuelle, niveau de
/// risque, décision médicale, profil patient, plaie/contexte, statut
/// vaccinal, suivi/chronologie des actes et traçabilité.
class TetanusPatientDetailScreen extends StatelessWidget {
  final String patientId;
  const TetanusPatientDetailScreen({super.key, required this.patientId});

  static const _service = TetanusEvaluationService();

  @override
  Widget build(BuildContext context) {
    final patient =
        GetIt.instance<TetanusRepository>().getPatientById(patientId);
    if (patient == null) {
      return Scaffold(
        backgroundColor: EpidemiologyTheme.warm50,
        body: const Center(child: Text('Patient introuvable')),
      );
    }

    final input = _service.inputForPatient(patient);
    final resolution = _service.resolve(input);

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: TetanusCaseDetailHero(
                  patient: patient,
                  risk: resolution.risk,
                  onBack: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildAlerts(patient)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: TetanusRiskCard(
                  input: input,
                  resolution: resolution,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: TetanusDecisionCard(
                  input: input,
                  resolution: resolution,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _buildPatientSection(patient),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _buildWoundSection(patient),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _buildVaccinSection(patient),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _buildSuiviSection(patient),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: _buildTracabiliteSection(patient),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: _buildActions(patient),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Alertes ──

  Widget _buildAlerts(TetanusPatientModel p) {
    final alerts = <Widget>[];
    if (p.estUrgent) {
      alerts.add(TetanusAlertItem(
        icon: Icons.warning_amber_rounded,
        title: 'Prise en charge urgente requise',
        message: 'VAT + immunoglobulines antitétaniques à administrer sans '
            'délai selon l\'évaluation du risque.',
        color: EpidemiologyTheme.danger,
      ));
    }
    if (p.necessiteIg) {
      alerts.add(TetanusAlertItem(
        icon: Icons.bloodtype_outlined,
        title: 'Immunoglobulines indiquées',
        message: 'Plaie tétanigène avec statut vaccinal non à jour : '
            'l\'administration d\'Ig antitétaniques est recommandée.',
        color: EpidemiologyTheme.indigo,
      ));
    }
    if (p.statutDossier == TetanusDossierStatut.perduDeVue) {
      alerts.add(TetanusAlertItem(
        icon: Icons.visibility_off_outlined,
        title: 'Patient perdu de vue',
        message: 'Le suivi du patient a été interrompu. Relancer le contact '
            'et reprendre la prise en charge.',
        color: EpidemiologyTheme.warm500,
      ));
    }
    if (alerts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Column(children: alerts),
    );
  }

  // ── Patient ──

  Widget _buildPatientSection(TetanusPatientModel p) {
    return TetanusEvaluationSection(
      title: 'Profil du patient',
      subtitle: 'Identité et données démographiques',
      icon: Icons.person_outline,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        children: [
          TetanusInfoRow(
              label: 'Dossier', value: p.id, icon: Icons.folder_outlined),
          TetanusInfoRow(
              label: 'Âge', value: '${p.age} ans', icon: Icons.cake_outlined),
          TetanusInfoRow(label: 'Sexe', value: p.sexe, icon: Icons.wc),
          TetanusInfoRow(
              label: 'Date de blessure',
              value: p.dateBlessure,
              icon: Icons.event_outlined),
          TetanusInfoRow(
              label: 'Date de création',
              value: p.dateCreation,
              icon: Icons.edit_calendar_outlined),
        ],
      ),
    );
  }

  // ── Plaie / contexte ──

  Widget _buildWoundSection(TetanusPatientModel p) {
    return TetanusEvaluationSection(
      title: 'Plaie & contexte d\'exposition',
      subtitle: p.typePlaie.description,
      icon: Icons.healing_outlined,
      accent: EpidemiologyTheme.teal,
      child: Column(
        children: [
          TetanusInfoRow(
              label: 'Type',
              value: p.typePlaie.label,
              icon: Icons.crisis_alert_outlined),
          TetanusInfoRow(
              label: 'Localisation',
              value: p.localisation,
              icon: Icons.my_location_outlined),
          TetanusInfoRow(
              label: 'Délai de consultation',
              value: p.delaiConsultation,
              icon: Icons.schedule),
          _boolsInfo([
            _boolCell('Profonde', p.plaieProfonde, Icons.arrow_downward,
                EpidemiologyTheme.info),
            _boolCell('Souillée', p.plaieSouillee, Icons.grass,
                EpidemiologyTheme.orange),
            _boolCell('Corps étranger', p.corpsEtranger,
                Icons.casino_outlined, EpidemiologyTheme.indigo),
            _boolCell('Soins locaux', p.soinsLocauxRealises,
                Icons.medical_services_outlined, EpidemiologyTheme.success),
          ]),
        ],
      ),
    );
  }

  Widget _boolsInfo(List<Widget> cells) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EpidemiologyTheme.warm100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques',
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.warm400,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cells,
          ),
        ],
      ),
    );
  }

  Widget _boolCell(String label, bool value, IconData icon, Color color) {
    final display = value ? color : EpidemiologyTheme.warm300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: value ? color.withValues(alpha: 0.10) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value
              ? color.withValues(alpha: 0.3)
              : EpidemiologyTheme.warm150,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: display),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: display,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            value ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: value ? color : EpidemiologyTheme.warm300,
          ),
        ],
      ),
    );
  }

  // ── Statut vaccinal ──

  Widget _buildVaccinSection(TetanusPatientModel p) {
    return TetanusEvaluationSection(
      title: 'Statut vaccinal tétanique',
      subtitle: 'Degré d\'immunisation et antécédents vaccinaux',
      icon: Icons.vaccines_outlined,
      accent: EpidemiologyTheme.info,
      child: Column(
        children: [
          TetanusInfoRow(
              label: 'Statut',
              value: p.statutVaccinal.label,
              icon: Icons.shield_outlined),
          if (p.nombreDosesConnues != null)
            TetanusInfoRow(
                label: 'Doses documentées',
                value: '${p.nombreDosesConnues}',
                icon: Icons.onetwothree_outlined),
          _boolCell(
            'Recherche de carnet',
            p.nombreDosesConnues == null,
            Icons.menu_book_outlined,
            EpidemiologyTheme.warning,
          ),
          TetanusInfoRow(
            label: 'Dernière dose',
            value: p.derniereDoseDate ?? 'Non renseignée',
            icon: Icons.event_outlined,
          ),
        ],
      ),
    );
  }

  // ── Suivi / chronologie ──

  Widget _buildSuiviSection(TetanusPatientModel p) {
    final reversed = p.historique.reversed.toList();
    return TetanusEvaluationSection(
      title: 'Chronologie des actes',
      subtitle: 'Vaccinations, rappels et Ig administrés',
      icon: Icons.history_rounded,
      accent: EpidemiologyTheme.warning,
      child: reversed.isEmpty
          ? _emptyTimeline()
          : Column(
              children: [
                for (var i = 0; i < reversed.length; i++)
                  _timelineItem(reversed[i], i == reversed.length - 1),
              ],
            ),
    );
  }

  Widget _emptyTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EpidemiologyTheme.warm100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: EpidemiologyTheme.warm300),
          const SizedBox(width: 8),
          Text(
            'Aucun acte prophylactique enregistré pour ce cas.',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: EpidemiologyTheme.warm500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(TetanusActeModel acte, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.warning,
                    shape: BoxShape.circle,
                    border: Border.all(color: EpidemiologyTheme.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: EpidemiologyTheme.warning.withValues(alpha: 0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: EpidemiologyTheme.warm100,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          acte.typeActe,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EpidemiologyTheme.warm800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: EpidemiologyTheme.warm50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: EpidemiologyTheme.warm100),
                        ),
                        child: Text(
                          acte.dateActe,
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: EpidemiologyTheme.warm500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (acte.vaccin != null) _metaRow(Icons.vaccines_outlined, acte.vaccin!),
                  if (acte.numeroLot != null)
                    _metaRow(Icons.qr_code_outlined, 'Lot: ${acte.numeroLot}'),
                  if (acte.administrateur != null)
                    _metaRow(Icons.person_outline, acte.administrateur!),
                  if (acte.centre != null)
                    _metaRow(Icons.location_on_outlined, acte.centre!),
                  if (acte.observations != null && acte.observations!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: EpidemiologyTheme.warm50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        acte.observations!,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: EpidemiologyTheme.warm500,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: EpidemiologyTheme.warm400),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: EpidemiologyTheme.warm500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Traçabilité ──

  Widget _buildTracabiliteSection(TetanusPatientModel p) {
    final hasIg = p.immunoglobulines || p.necessiteIg;
    return TetanusEvaluationSection(
      title: 'Remarques & traçabilité',
      subtitle: 'Observations cliniques du dossier',
      icon: Icons.fact_check_outlined,
      accent: EpidemiologyTheme.indigo,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: EpidemiologyTheme.warm100),
            ),
            child: Text(
              p.observations?.isNotEmpty == true
                  ? p.observations!
                  : 'Aucune remarque clinique.',
              style: GoogleFonts.cairo(
                fontSize: 12.5,
                height: 1.5,
                color: EpidemiologyTheme.warm700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(hasIg, Icons.bloodtype_outlined, 'Ig requises',
                  EpidemiologyTheme.indigo),
              _pill(p.historique.isNotEmpty, Icons.check_rounded,
                  'Vaccination documentée', EpidemiologyTheme.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(bool active, IconData icon, String label, Color color) {
    final use = active ? color : EpidemiologyTheme.warm300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.10) : EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? color.withValues(alpha: 0.25)
              : EpidemiologyTheme.warm150,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: use),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: use,
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──

  Widget _buildActions(TetanusPatientModel p) {
    final edit = OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: Text(
        'Modifier la décision',
        style:
            GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: EpidemiologyTheme.redPrimary,
        side: BorderSide(
            color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );

    final enregistrer = FilledButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_circle_outline, size: 18),
      label: Text(
        'Enregistrer un acte',
        style:
            GoogleFonts.cairo(fontSize: 12.5, fontWeight: FontWeight.w700),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: EpidemiologyTheme.redPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              SizedBox(
                  width: double.infinity, child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: enregistrer,
              )),
              SizedBox(width: double.infinity, child: edit),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: edit),
            const SizedBox(width: 12),
            Expanded(child: enregistrer),
          ],
        );
      },
    );
  }
}