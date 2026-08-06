import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/dossier_enums.dart';
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/models/dossier/rabies_clinical_alert.dart';
import '../../domain/models/dossier/rabies_decision_summary.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../../domain/services/rabies_decision_engine.dart';
import '../../domain/services/rabies_alert_service.dart';
import '../../domain/services/rabies_follow_up_service.dart';
import 'rabies_follow_up_screen.dart';
import 'rabies_j0_form_screen.dart';
import 'rabies_traceability_screen.dart';
import '../widgets/rabies_dossier_widgets.dart';
import '../widgets/traceability/traceability_section.dart';

class RabiesDossierDetailScreen extends StatefulWidget {
  final String dossierId;
  final VoidCallback? onBack;

  const RabiesDossierDetailScreen({super.key, required this.dossierId, this.onBack});

  @override
  State<RabiesDossierDetailScreen> createState() => _RabiesDossierDetailScreenState();
}

class _RabiesDossierDetailScreenState extends State<RabiesDossierDetailScreen> {
  RabiesCaseRecord? _dossier;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = di.sl<RabiesDossierRepository>();
    final dossier = await repo.getDossierById(widget.dossierId);
    setState(() {
      _dossier = dossier;
      _loading = false;
    });
  }

  Future<void> _openJ0Editor() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RabiesJ0FormScreen(dossierId: widget.dossierId),
      ),
    );
    if (result == true) {
      _load();
    }
  }

  Future<void> _openFollowUp() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RabiesFollowUpScreen(dossierId: widget.dossierId),
      ),
    );
    _load();
  }

  Future<void> _openTraceability() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RabiesTraceabilityScreen(dossierId: widget.dossierId),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final dossier = _dossier;
    if (dossier == null) {
      return EpidemiologyTheme.emptyState(
        Icons.folder_off,
        'Dossier introuvable',
        subtitle: 'Il a peut-être été supprimé',
      );
    }
    return Container(
      decoration: BoxDecoration(gradient: EpidemiologyTheme.surfaceGradient),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(dossier),
            Expanded(child: _buildBody(dossier)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RabiesCaseRecord d) {
    final urgent = d.estUrgent;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 14),
      color: EpidemiologyTheme.white,
      child: Column(
        children: [
          Row(
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: EpidemiologyTheme.slate900,
                  onPressed: widget.onBack,
                ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: EpidemiologyTheme.primaryGradientWarm,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.folder_copy_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.patientNomComplet,
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: EpidemiologyTheme.slate900),
                    ),
                    Text(
                      '${d.numeroDossier} · ${d.patientAge} ans · ${d.identity.sexe.label}',
                      style: GoogleFonts.inter(fontSize: 12.5, color: EpidemiologyTheme.warm500, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              DossierChip(
                label: d.categorie.label,
                icon: Icons.category,
                color: urgent ? EpidemiologyTheme.danger : EpidemiologyTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    DossierChip(
                      label: 'Créé : ${ddMMyyyy(d.dateCreation)}',
                      icon: Icons.event,
                      color: EpidemiologyTheme.slate400,
                      subtle: true,
                    ),
                    if (d.aErigAdministree)
                      DossierChip(label: 'ERIG', icon: Icons.science, color: EpidemiologyTheme.teal, subtle: true),
                    DossierChip(label: d.evolution.resultat.label, icon: Icons.flag, color: EpidemiologyTheme.slate500, subtle: true),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _openJ0Editor,
                icon: const Icon(Icons.edit_note, size: 16),
                label: const Text('Modifier J0'),
                style: FilledButton.styleFrom(
                  backgroundColor: EpidemiologyTheme.redPrimary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (d.aRetard) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [EpidemiologyTheme.dangerLight, EpidemiologyTheme.warningLight],
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: EpidemiologyTheme.warning),
                  const SizedBox(width: 6),
                  Text(
                    'Protocole en retard — doses en attente',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: EpidemiologyTheme.danger),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(RabiesCaseRecord d) {
    final alerts = RabiesAlertService.evaluer(d);
    final summary = RabiesDecisionEngine.resumer(d);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (alerts.isNotEmpty) _buildAlerts(alerts),
          Text(_decisionResume(summary),
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.slate700)),
          const SizedBox(height: 14),
          _buildFollowUpCta(d),
          const SizedBox(height: 14),
          _buildIdentitySection(d),
          _buildAdmissionSection(d),
          _buildExposureSection(d),
          _buildAnimalSection(d),
          _buildCareSection(d),
          _buildVaccinationSection(d),
          _buildFollowUpSection(d),
          const SizedBox(height: 4),
          TraceabilitySection(record: d, onOpenHistory: _openTraceability),
        ],
      ),
    );
  }

  Widget _buildAlerts(List<RabiesClinicalAlert> alerts) {
    final critical = alerts.where((a) => a.severity == RabiesAlertSeverity.critical).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: critical.isNotEmpty ? EpidemiologyTheme.dangerLight : EpidemiologyTheme.warningLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (critical.isNotEmpty ? EpidemiologyTheme.danger : EpidemiologyTheme.warning).withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report_problem, size: 18,
                  color: critical.isNotEmpty ? EpidemiologyTheme.danger : EpidemiologyTheme.warning),
              const SizedBox(width: 8),
              Text('Points d\'attention',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700,
                      color: critical.isNotEmpty ? EpidemiologyTheme.danger : EpidemiologyTheme.warning)),
            ],
          ),
          const SizedBox(height: 8),
          for (final a in alerts) _alertLine(a),
        ],
      ),
    );
  }

  Widget _alertLine(RabiesClinicalAlert a) {
    final color = switch (a.severity) {
      RabiesAlertSeverity.critical => EpidemiologyTheme.danger,
      RabiesAlertSeverity.warning => EpidemiologyTheme.warning,
      RabiesAlertSeverity.info => EpidemiologyTheme.slate600,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(a.icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text('${a.titre} ${a.message}',
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCta(RabiesCaseRecord d) {
    final fu = RabiesFollowUpService.summary(d);
    final pct = fu.progressionPercent;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openFollowUp,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [EpidemiologyTheme.redDeep, EpidemiologyTheme.redPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: EpidemiologyTheme.redDeep.withValues(alpha: 0.30),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.timeline, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Suivi du dossier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fu.protocoleStatut.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${fu.dosesRealisees}/${fu.totalDoses} doses · '
                          '${fu.prochaineDose?.jourTheorique ?? '—'} en prochain',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _fuBadge(pct),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withValues(alpha: 0.25)),
                      FractionallySizedBox(
                        widthFactor: pct / 100,
                        child: Container(
                          color: pct >= 100 ? const Color(0xFF4ADE80) : Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fuBadge(int pct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$pct%',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }

  String _decisionResume(RabiesDecisionSummary s) {
    final parts = <String>[
      'Catégorie ${s.categorie.categorie.label}',
      s.ppe.indiquee ? 'PPE indiquée' : 'Pas de PPE',
    ];
    if (s.erig.indiquee) {
      parts.add(s.erig.administree ? 'ERIG administrée' : 'ERIG à administrer');
    }
    final p = s.protocole;
    if (p != null) parts.add('Protocole ${p.type.label}');
    if (s.prochaineDose != null) parts.add('Prochaine dose ${s.prochaineDose!.jourTheorique}');
    return parts.join(' • ');
  }

  Widget _buildIdentitySection(RabiesCaseRecord d) {
    final id = d.identity;
    final r = id.residence;
    return DossierSectionCard(
      title: 'A · Identité patient',
      icon: Icons.person,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        children: [
          DossierInfoRow(label: 'Nom / Prénom', value: id.nomComplet),
          DossierInfoRow(label: 'Date de naissance', value: ddMMyyyy(id.dateNaissance)),
          DossierInfoRow(label: 'Âge', value: id.ageCalcule?.toString()),
          DossierInfoRow(label: 'Sexe', value: id.sexe.label),
          DossierInfoRow(label: 'Poids', value: id.poidsKg != null ? '${id.poidsKg} kg' : null),
          DossierInfoRow(label: 'Téléphone', value: id.telephone),
          DossierInfoRow(label: 'Profession', value: id.profession),
          DossierInfoRow(label: 'Niveau d\'instruction', value: id.niveauInstruction.label),
          DossierInfoRow(label: 'Terrain particulier', value: id.terrainParticulier),
          if (id.medecinTraitant != null) DossierInfoRow(label: 'Médecin traitant', value: id.medecinTraitant),
          if (id.infirmier != null) DossierInfoRow(label: 'Infirmier', value: id.infirmier),
          Divider(color: EpidemiologyTheme.warm100, height: 20),
          Text('B · Adresse', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm400)),
          DossierInfoRow(label: 'Adresse', value: r.adresse),
          DossierInfoRow(label: 'Commune', value: r.commune),
          DossierInfoRow(label: 'Daira', value: r.daira),
          DossierInfoRow(label: 'Wilaya', value: r.wilaya),
          DossierInfoRow(label: 'Résidence', value: r.residence),
        ],
      ),
    );
  }

  Widget _buildAdmissionSection(RabiesCaseRecord d) {
    final a = d.admission;
    return DossierSectionCard(
      title: 'C · Admission à l\'UAR',
      icon: Icons.local_hospital,
      accent: EpidemiologyTheme.teal,
      child: Column(
        children: [
          DossierInfoRow(label: 'Date d\'arrivée', value: ddMMyyyy(a.dateArriveeUar)),
          DossierInfoRow(label: 'Heure d\'arrivée', value: a.heureArrivee),
          DossierInfoRow(label: 'Mode d\'arrivée', value: a.modeArrivee.label),
          DossierInfoRow(label: 'Structure d\'orientation', value: a.structureOrientation),
        ],
      ),
    );
  }

  Widget _buildExposureSection(RabiesCaseRecord d) {
    final e = d.exposition;
    final c = d.classification;
    return DossierSectionCard(
      title: 'D · Exposition & E · Classification',
      icon: Icons.medical_information,
      accent: EpidemiologyTheme.warning,
      child: Column(
        children: [
          DossierInfoRow(label: 'Date d\'exposition', value: ddMMyyyy(e.dateExposition)),
          DossierInfoRow(label: 'Heure', value: e.heureExposition),
          DossierInfoRow(label: 'Lieu', value: e.lieu.label),
          DossierInfoRow(label: 'Nature', value: e.nature.label),
          DossierInfoRow(label: 'Saignement', value: e.saignement.label),
          DossierInfoRow(
            label: 'Nombre de lésions',
            value: e.nombreLesionsValeur?.toString() ?? e.nombreLesions.label,
          ),
          DossierInfoRow(
            label: 'Siège des lésions',
            value: e.siegeLesions.isEmpty ? null : e.siegeLesions.map((s) => s.label).join(', '),
          ),
          Divider(color: EpidemiologyTheme.warm100, height: 20),
          DossierInfoRow(label: 'Catégorie', value: c.categorie.label,
            valueColor: c.categorie == RabiesRiskCategory.categorieIII ? EpidemiologyTheme.danger : EpidemiologyTheme.warning),
          DossierInfoRow(label: 'Méthode', value: c.methode.label),
          DossierInfoRow(label: 'Justification', value: c.justification),
          if (c.mesuresFamiliales.isNotEmpty)
            DossierInfoRow(label: 'Mesures familiales', value: c.mesuresFamiliales.map((m) => m.label).join(', ')),
          if (c.precisionMesures != null) DossierInfoRow(label: 'Précision', value: c.precisionMesures),
        ],
      ),
    );
  }

  Widget _buildAnimalSection(RabiesCaseRecord d) {
    final a = d.animal;
    return DossierSectionCard(
      title: 'F · Animal en cause',
      icon: Icons.pets,
      accent: EpidemiologyTheme.slate500,
      child: Column(
        children: [
          DossierInfoRow(label: 'Espèce', value: a.espece.label),
          if (a.autreEspecePrecision != null) DossierInfoRow(label: 'Précision espèce', value: a.autreEspecePrecision),
          DossierInfoRow(label: 'Couleur du pelage', value: a.couleurPelage),
          DossierInfoRow(label: 'Statut', value: a.statut.label),
          DossierInfoRow(label: 'Propriétaire', value: a.proprietaireNom),
          DossierInfoRow(label: 'Comportement', value: a.comportement.label),
          DossierInfoRow(label: 'Vaccination', value: a.vaccination.label),
          DossierInfoRow(label: 'Date vaccination', value: ddMMyyyy(a.dateVaccination)),
          Divider(color: EpidemiologyTheme.warm100, height: 20),
          DossierInfoRow(label: 'Observation vétérinaire', value: a.observationVeterinaire.label),
          DossierInfoRow(label: 'Début observation', value: ddMMyyyy(a.debutObservation)),
          DossierInfoRow(label: 'Fin observation', value: ddMMyyyy(a.finObservation)),
          DossierInfoRow(label: 'Résultat observation', value: a.resultatObservation.label),
          DossierInfoRow(label: 'Sort', value: a.sort.label),
          Divider(color: EpidemiologyTheme.warm100, height: 20),
          DossierInfoRow(label: 'Envoi tête au labo', value: a.envoiTeteLabo.label),
          DossierInfoRow(label: 'Type d\'analyse', value: a.typeAnalyse?.label),
          DossierInfoRow(label: 'Date analyse', value: ddMMyyyy(a.dateAnalyse)),
          DossierInfoRow(label: 'Résultat labo', value: a.resultatLabo.label,
            valueColor: a.animalEnrageConfirme ? EpidemiologyTheme.danger : null),
        ],
      ),
    );
  }

  Widget _buildCareSection(RabiesCaseRecord d) {
    final s = d.soinsLocaux;
    final er = d.erig;
    final ch = d.chirurgie;
    return Column(
      children: [
        DossierSectionCard(
          title: 'G · Soins locaux',
          icon: Icons.cleaning_services,
          accent: EpidemiologyTheme.teal,
          child: Column(
            children: [
              DossierInfoRow(label: 'Soins réalisés', value: s.realise.label),
              if (s.methodes.isNotEmpty)
                DossierInfoRow(label: 'Méthodes', value: s.methodes.map((m) => m.label).join(', ')),
              if (s.produitsAppliques != null) DossierInfoRow(label: 'Produits appliqués', value: s.produitsAppliques),
              if (s.notes != null) DossierInfoRow(label: 'Notes', value: s.notes),
            ],
          ),
        ),
        DossierSectionCard(
          title: 'H · ERIG / Immunoglobulines',
          icon: Icons.science,
          accent: d.classification.erigIndiquee ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: Column(
            children: [
              DossierInfoRow(label: 'Indiquée', value: er.indiquee ? 'Oui' : 'Non'),
              DossierInfoRow(label: 'Administrée', value: er.administree ? 'Oui' : 'Non'),
              if (er.administree) ...[
                DossierInfoRow(label: 'Date', value: ddMMyyyy(er.date)),
                DossierInfoRow(label: 'Heure', value: er.heure),
                DossierInfoRow(label: 'N° de lot', value: er.numeroLot),
                DossierInfoRow(label: 'Titre (UI/ml)', value: er.titreIUMl?.toString()),
                DossierInfoRow(label: 'Poids patient', value: er.poidsPatientKg != null ? '${er.poidsPatientKg} kg' : null),
                DossierInfoRow(label: 'Dose théorique (IU)', value: er.doseTotaleTheoriqueIU?.toString()),
                DossierInfoRow(label: 'Méthode Besredka', value: er.methodeBesredka ? 'Oui' : 'Non'),
                DossierInfoRow(label: 'Dilution réalisée', value: er.dilutionRealisee ? 'Oui' : 'Non'),
                if (er.quantiteSerumPhysiologiqueMl != null)
                  DossierInfoRow(label: 'Sérum physiologique', value: '${er.quantiteSerumPhysiologiqueMl} ml'),
                if (er.voies.isNotEmpty)
                  DossierInfoRow(label: 'Voies', value: er.voies.map((v) => v.label).join(', ')),
                DossierInfoRow(label: 'Réaction post-ERIG', value: er.reactionPostErig ? 'Oui' : 'Non'),
                DossierInfoRow(label: 'Type de réaction', value: er.typeReaction?.label),
                if (er.mesuresReaction != null) DossierInfoRow(label: 'Mesures', value: er.mesuresReaction),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'I · Chirurgie / Suture',
          icon: Icons.healing,
          accent: EpidemiologyTheme.warning,
          child: Column(
            children: [
              DossierInfoRow(label: 'Chirurgie réalisée', value: ch.realise.label),
              if (ch.realise == SurgeryPerformed.oui) ...[
                DossierInfoRow(label: 'Date', value: ddMMyyyy(ch.date)),
                DossierInfoRow(label: 'Hôpital', value: ch.hopital),
                DossierInfoRow(label: 'Service', value: ch.service),
              ],
              DossierInfoRow(label: 'Suture', value: ch.suture.label),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccinationSection(RabiesCaseRecord d) {
    final v = d.vaccination;
    final p = v.protocole;
    return DossierSectionCard(
      title: 'J · Vaccination antirabique',
      icon: Icons.vaccines,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        children: [
          DossierInfoRow(label: 'Type de vaccin', value: v.typeVaccin.label),
          if (v.dci != null) DossierInfoRow(label: 'DCI', value: v.dci),
          if (v.numeroLot != null) DossierInfoRow(label: 'N° de lot', value: v.numeroLot),
          DossierInfoRow(label: 'Date de péremption', value: ddMMyyyy(v.datePeremption)),
          DossierInfoRow(label: 'Voie', value: v.voie.label),
          if (v.doseAdministree != null) DossierInfoRow(label: 'Dose administrée', value: '${v.doseAdministree} ml'),
          const Divider(color: EpidemiologyTheme.warm100, height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Protocole',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm400),
                ),
              ),
              DossierChip(
                label: '${p.type.label} · ${p.dosesRealisees}/${p.totalDoses}',
                icon: Icons.timeline,
                color: p.estTermine ? EpidemiologyTheme.teal : (p.aRetard ? EpidemiologyTheme.warning : EpidemiologyTheme.redPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...p.doses.map((dose) {
            final color = switch (dose.statut) {
              DoseStatus.realisee => EpidemiologyTheme.teal,
              DoseStatus.enRetard => EpidemiologyTheme.warning,
              DoseStatus.manquee => EpidemiologyTheme.danger,
              DoseStatus.prevue => EpidemiologyTheme.slate400,
            };
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: color),
                  const SizedBox(width: 8),
                  Text(
                    dose.etiquette,
                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: EpidemiologyTheme.slate700),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dose.statut.label,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
                    ),
                  ),
                  Text(
                    dose.dateReelle != null ? ddMMyyyy(dose.dateReelle) : ddMMyyyy(dose.datePrevue),
                    style: GoogleFonts.inter(fontSize: 11.5, color: EpidemiologyTheme.warm500),
                  ),
                ],
              ),
            );
          }),
          if (p.remarques != null) ...[
            const SizedBox(height: 6),
            DossierInfoRow(label: 'Remarques', value: p.remarques),
          ],
        ],
      ),
    );
  }

  Widget _buildFollowUpSection(RabiesCaseRecord d) {
    final mpvi = d.mpvi;
    final ab = d.antibiotiques;
    final tt = d.vaccinationTetanos;
    final autres = d.autresTraitements;
    final tr = d.tracabilite;
    final ev = d.evolution;
    return Column(
      children: [
        DossierSectionCard(
          title: 'K · Effets indésirables (MPVI)',
          icon: Icons.warning_amber_rounded,
          accent: mpvi.present ? EpidemiologyTheme.warning : EpidemiologyTheme.slate400,
          child: Column(
            children: [
              DossierInfoRow(label: 'MPVI présent', value: mpvi.present ? 'Oui' : 'Non'),
              if (mpvi.present) ...[
                DossierInfoRow(label: 'Date d\'apparition', value: ddMMyyyy(mpvi.dateApparition)),
                DossierInfoRow(label: 'Manifestations', value: mpvi.manifestations),
                DossierInfoRow(label: 'Gravité', value: mpvi.gravite.label),
                DossierInfoRow(label: 'Mesures prises', value: mpvi.mesuresPrises),
                DossierInfoRow(label: 'Déclaration pharmacovigilance',
                    value: mpvi.declarationPharmacovigilance ? 'Oui' : 'Non'),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'L · Antibiotiques',
          icon: Icons.medication,
          accent: ab.estPrescrit ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: Column(
            children: [
              DossierInfoRow(label: 'Prescription', value: ab.prescription.label),
              if (ab.estPrescrit) ...[
                DossierInfoRow(label: 'Molécule', value: ab.molecule),
                DossierInfoRow(label: 'Dose', value: ab.dose),
                DossierInfoRow(label: 'Durée', value: ab.duree),
                DossierInfoRow(label: 'Motif', value: ab.motif),
                if (ab.observations != null) DossierInfoRow(label: 'Observations', value: ab.observations),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'M · Vaccination tétanos',
          icon: Icons.shield,
          accent: tt.estRealisee ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: Column(
            children: [
              DossierInfoRow(label: 'Statut', value: tt.statut.label),
              DossierInfoRow(label: 'Type', value: tt.type.label),
              DossierInfoRow(label: 'Date d\'administration', value: ddMMyyyy(tt.dateAdministration)),
              if (tt.observations != null) DossierInfoRow(label: 'Observations', value: tt.observations),
            ],
          ),
        ),
        DossierSectionCard(
          title: 'N · Autres traitements',
          icon: Icons.medication_liquid,
          accent: autres.present ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: Column(
            children: [
              DossierInfoRow(label: 'Traitement', value: autres.present ? 'Oui' : 'Non'),
              if (autres.present) ...[
                DossierInfoRow(label: 'Description', value: autres.description),
                if (autres.observations != null) DossierInfoRow(label: 'Observations', value: autres.observations),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'O · Traçabilité',
          icon: Icons.receipt_long,
          accent: EpidemiologyTheme.slate500,
          child: Column(
            children: [
              DossierInfoRow(label: 'Carte de vaccination', value: tr.carteVaccination.label),
              if (tr.carteRemise && tr.numeroCarte != null) DossierInfoRow(label: 'N° de carte', value: tr.numeroCarte),
              if (tr.carteRemisePar != null) DossierInfoRow(label: 'Carte remise par', value: tr.carteRemisePar!.nomComplet),
              if (tr.dateCarteRemise != null) DossierInfoRow(label: 'Date de remise', value: ddMMyyyy(tr.dateCarteRemise)),
              DossierInfoRow(label: 'Registre', value: tr.registre.label),
              if (tr.patientRepertorie && tr.numeroRegistre != null) DossierInfoRow(label: 'N° de registre', value: tr.numeroRegistre),
              if (tr.registreRenseignePar != null) DossierInfoRow(label: 'Inscription par', value: tr.registreRenseignePar!.nomComplet),
              if (tr.dateInscriptionRegistre != null) DossierInfoRow(label: 'Date d\'inscription', value: ddMMyyyy(tr.dateInscriptionRegistre)),
              if (tr.remarques != null) DossierInfoRow(label: 'Remarques', value: tr.remarques),
            ],
          ),
        ),
        DossierSectionCard(
          title: 'P · Évolution du dossier',
          icon: Icons.flag,
          accent: ev.estClos ? EpidemiologyTheme.teal : EpidemiologyTheme.warning,
          child: Column(
            children: [
              DossierInfoRow(label: 'Résultat', value: ev.resultat.label),
              if (ev.dateCloture != null) DossierInfoRow(label: 'Date de clôture', value: ddMMyyyy(ev.dateCloture)),
              if (ev.observations != null) DossierInfoRow(label: 'Observations', value: ev.observations),
            ],
          ),
        ),
      ],
    );
  }
}
