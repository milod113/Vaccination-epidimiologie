import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/dossier_enums.dart';
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/models/dossier/rabies_decision_summary.dart';
import '../../domain/models/dossier/rabies_follow_up_summary.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../../domain/services/rabies_decision_engine.dart';
import '../../domain/services/rabies_alert_service.dart';
import '../../domain/services/rabies_follow_up_service.dart';
import 'rabies_follow_up_screen.dart';
import 'rabies_j0_form_screen.dart';
import 'rabies_traceability_screen.dart';
import '../widgets/dossier/alert_banner_card.dart';
import '../widgets/dossier/clinical_summary_card.dart';
import '../widgets/dossier/dose_timeline.dart';
import '../widgets/dossier/info_grid.dart';
import '../widgets/dossier/outcome_panel.dart';
import '../widgets/dossier/patient_dossier_hero.dart';
import '../widgets/dossier/protocol_progress_card.dart';
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

    final decision = RabiesDecisionEngine.resumer(dossier);
    final followUp = RabiesFollowUpService.summary(dossier);
    final alerts = RabiesAlertService.evaluer(dossier);

    return Container(
      decoration: BoxDecoration(gradient: EpidemiologyTheme.surfaceGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PatientDossierHeroHeader(
                dossier: dossier,
                decision: decision,
                followUp: followUp,
                onBack: widget.onBack,
                onEditJ0: _openJ0Editor,
                onFollowUp: _openFollowUp,
              ),
              AlertBannerCard(alerts: alerts, onCta: _openFollowUp),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 1000;
                  final clinical = _clinicalColumn(dossier, decision, followUp);
                  final admin = _adminColumn(dossier, decision, followUp);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: clinical),
                        const SizedBox(width: 16),
                        Expanded(child: admin),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      clinical,
                      const SizedBox(height: 16),
                      admin,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TraceabilitySection(record: dossier, onOpenHistory: _openTraceability),
            ],
          ),
        ),
      ),
    );
  }

  // ── Colonne clinique ──────────────────────────────────────────────

  Widget _clinicalColumn(
    RabiesCaseRecord d,
    RabiesDecisionSummary decision,
    RabiesFollowUpSummary followUp,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClinicalSummaryCard(
          decision: decision,
          followUp: followUp,
          ppeNonIndiquee: decision.ppeNonIndiquee,
        ),
        ProtocolProgressCard(
          followUp: followUp,
          protocol: d.vaccination.protocole,
          onOpenFollowUp: _openFollowUp,
        ),
        _buildExposureSection(d),
        _buildAnimalSection(d),
        _buildCareSection(d),
      ],
    );
  }

  // ── Colonne administrative ────────────────────────────────────────

  Widget _adminColumn(
    RabiesCaseRecord d,
    RabiesDecisionSummary decision,
    RabiesFollowUpSummary followUp,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildIdentitySection(d),
        _buildAdmissionSection(d),
        _buildVaccinationSection(d),
        _buildFollowUpSection(d),
        OutcomePanel(evolution: d.evolution, followUp: followUp),
      ],
    );
  }

  // ── Sections détaillées ───────────────────────────────────────────

  Widget _buildIdentitySection(RabiesCaseRecord d) {
    final id = d.identity;
    final r = id.residence;
    return DossierSectionCard(
      title: 'A · Identité patient',
      subtitle: 'Données civiles et coordonnées',
      icon: Icons.person,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        children: [
          InfoGrid(
            items: [
              InfoTile(label: 'Nom / Prénom', value: id.nomComplet, icon: Icons.badge_outlined),
              InfoTile(label: 'Date de naissance', value: ddMMyyyy(id.dateNaissance), icon: Icons.cake_outlined),
              InfoTile(label: 'Âge', value: id.ageCalcule?.toString(), icon: Icons.timeline),
              InfoTile(label: 'Sexe', value: id.sexe.label, icon: Icons.wc),
              InfoTile(label: 'Poids', value: id.poidsKg != null ? '${id.poidsKg} kg' : null, icon: Icons.monitor_weight_outlined),
              InfoTile(label: 'Téléphone', value: id.telephone, icon: Icons.phone_outlined),
              InfoTile(label: 'Profession', value: id.profession, icon: Icons.work_outline),
              InfoTile(label: 'Niveau d\'instruction', value: id.niveauInstruction.label, icon: Icons.school_outlined),
              InfoTile(label: 'Terrain particulier', value: id.terrainParticulier, icon: Icons.medical_services_outlined),
              InfoTile(label: 'Médecin traitant', value: id.medecinTraitant, icon: Icons.health_and_safety_outlined),
              InfoTile(label: 'Infirmier', value: id.infirmier, icon: Icons.person_outline),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.home_work_outlined, size: 15, color: EpidemiologyTheme.redPrimary),
              const SizedBox(width: 6),
              Text(
                'B · Adresse',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.redPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InfoGrid(
            items: [
              InfoTile(label: 'Adresse', value: r.adresse),
              InfoTile(label: 'Commune', value: r.commune),
              InfoTile(label: 'Daira', value: r.daira),
              InfoTile(label: 'Wilaya', value: r.wilaya),
              InfoTile(label: 'Résidence', value: r.residence),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionSection(RabiesCaseRecord d) {
    final a = d.admission;
    return DossierSectionCard(
      title: 'C · Admission à l\'UAR',
      subtitle: 'Conditions d\'arrivée du patient',
      icon: Icons.local_hospital,
      accent: EpidemiologyTheme.teal,
      child: InfoGrid(
        items: [
          InfoTile(label: 'Date d\'arrivée', value: ddMMyyyy(a.dateArriveeUar), icon: Icons.event),
          InfoTile(label: 'Heure d\'arrivée', value: a.heureArrivee, icon: Icons.schedule),
          InfoTile(label: 'Mode d\'arrivée', value: a.modeArrivee.label, icon: Icons.directions_walk),
          InfoTile(label: 'Structure d\'orientation', value: a.structureOrientation, icon: Icons.account_balance_outlined),
        ],
      ),
    );
  }

  Widget _buildExposureSection(RabiesCaseRecord d) {
    final e = d.exposition;
    final c = d.classification;
    return DossierSectionCard(
      title: 'D · Exposition & E · Classification',
      subtitle: 'Circonstances de l\'exposition au risque',
      icon: Icons.medical_information,
      accent: EpidemiologyTheme.warning,
      child: Column(
        children: [
          InfoGrid(
            items: [
              InfoTile(label: 'Date d\'exposition', value: ddMMyyyy(e.dateExposition), icon: Icons.event),
              InfoTile(label: 'Heure', value: e.heureExposition, icon: Icons.schedule),
              InfoTile(label: 'Lieu', value: e.lieu.label, icon: Icons.place_outlined),
              InfoTile(label: 'Nature', value: e.nature.label, icon: Icons.emergency_outlined),
              InfoTile(label: 'Saignement', value: e.saignement.label, icon: Icons.water_drop_outlined),
              InfoTile(
                label: 'Nombre de lésions',
                value: e.nombreLesionsValeur?.toString() ?? e.nombreLesions.label,
                icon: Icons.zoom_out_map,
              ),
              InfoTile(
                label: 'Siège des lésions',
                value: e.siegeLesions.isEmpty ? null : e.siegeLesions.map((s) => s.label).join(', '),
                icon: Icons.accessibility_new,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.category_outlined, size: 15, color: EpidemiologyTheme.warning),
              const SizedBox(width: 6),
              Text(
                'Classification du risque',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InfoGrid(
            items: [
              InfoTile(
                label: 'Catégorie',
                value: c.categorie.label,
                valueColor: c.categorie == RabiesRiskCategory.categorieIII
                    ? EpidemiologyTheme.danger
                    : EpidemiologyTheme.warning,
                icon: Icons.shield_outlined,
              ),
              InfoTile(label: 'Méthode', value: c.methode.label, icon: Icons.calculate_outlined),
              InfoTile(label: 'Justification', value: c.justification, icon: Icons.notes),
              InfoTile(
                label: 'Mesures familiales',
                value: c.mesuresFamiliales.isEmpty ? null : c.mesuresFamiliales.map((m) => m.label).join(', '),
                icon: Icons.family_restroom,
              ),
              InfoTile(label: 'Précision', value: c.precisionMesures, icon: Icons.notes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalSection(RabiesCaseRecord d) {
    final a = d.animal;
    return DossierSectionCard(
      title: 'F · Animal en cause',
      subtitle: 'Espèce, statut et suivi vétérinaire',
      icon: Icons.pets,
      accent: EpidemiologyTheme.slate500,
      child: Column(
        children: [
          InfoGrid(
            items: [
              InfoTile(label: 'Espèce', value: a.espece.label, icon: Icons.pets),
              InfoTile(label: 'Précision espèce', value: a.autreEspecePrecision, icon: Icons.edit_note),
              InfoTile(label: 'Couleur du pelage', value: a.couleurPelage, icon: Icons.palette_outlined),
              InfoTile(label: 'Statut', value: a.statut.label, icon: Icons.home_work_outlined),
              InfoTile(label: 'Propriétaire', value: a.proprietaireNom, icon: Icons.person_outline),
              InfoTile(label: 'Comportement', value: a.comportement.label, icon: Icons.psychology_outlined),
              InfoTile(label: 'Vaccination', value: a.vaccination.label, icon: Icons.vaccines_outlined),
              InfoTile(label: 'Date vaccination', value: ddMMyyyy(a.dateVaccination), icon: Icons.event),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.biotech_outlined, size: 15, color: EpidemiologyTheme.warning),
              const SizedBox(width: 6),
              Text(
                'Observation & laboratoire',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InfoGrid(
            items: [
              InfoTile(label: 'Observation vétérinaire', value: a.observationVeterinaire.label, icon: Icons.visibility_outlined),
              InfoTile(label: 'Début observation', value: ddMMyyyy(a.debutObservation), icon: Icons.event),
              InfoTile(label: 'Fin observation', value: ddMMyyyy(a.finObservation), icon: Icons.event_available),
              InfoTile(label: 'Résultat observation', value: a.resultatObservation.label, icon: Icons.task_alt),
              InfoTile(label: 'Sort', value: a.sort.label, icon: Icons.location_on_outlined),
              InfoTile(label: 'Envoi tête au labo', value: a.envoiTeteLabo.label, icon: Icons.science_outlined),
              InfoTile(label: 'Type d\'analyse', value: a.typeAnalyse?.label, icon: Icons.biotech_outlined),
              InfoTile(label: 'Date analyse', value: ddMMyyyy(a.dateAnalyse), icon: Icons.event),
              InfoTile(
                label: 'Résultat labo',
                value: a.resultatLabo.label,
                valueColor: a.animalEnrageConfirme ? EpidemiologyTheme.danger : null,
                icon: Icons.science,
              ),
            ],
          ),
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
          subtitle: 'Nettoyage et désinfection de la plaie',
          icon: Icons.cleaning_services,
          accent: EpidemiologyTheme.teal,
          child: InfoGrid(
            items: [
              InfoTile(label: 'Soins réalisés', value: s.realise.label, icon: Icons.done_all),
              InfoTile(
                label: 'Méthodes',
                value: s.methodes.isEmpty ? null : s.methodes.map((m) => m.label).join(', '),
                icon: Icons.water_drop_outlined,
              ),
              InfoTile(label: 'Produits appliqués', value: s.produitsAppliques, icon: Icons.medication_outlined),
              InfoTile(label: 'Notes', value: s.notes, icon: Icons.notes),
            ],
          ),
        ),
        DossierSectionCard(
          title: 'H · ERIG / Immunoglobulines',
          subtitle: d.classification.erigIndiquee ? 'Indiquée pour cette exposition' : 'Non indiquée',
          icon: Icons.science,
          accent: d.classification.erigIndiquee ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: InfoGrid(
            items: [
              InfoTile(label: 'Indiquée', value: er.indiquee ? 'Oui' : 'Non', icon: Icons.help_outline),
              InfoTile(label: 'Administrée', value: er.administree ? 'Oui' : 'Non', icon: Icons.check_circle_outline),
              if (er.administree) ...[
                InfoTile(label: 'Date', value: ddMMyyyy(er.date), icon: Icons.event),
                InfoTile(label: 'Heure', value: er.heure, icon: Icons.schedule),
                InfoTile(label: 'N° de lot', value: er.numeroLot, icon: Icons.inventory_2_outlined),
                InfoTile(label: 'Titre (UI/ml)', value: er.titreIUMl?.toString(), icon: Icons.speed_outlined),
                InfoTile(label: 'Poids patient', value: er.poidsPatientKg != null ? '${er.poidsPatientKg} kg' : null, icon: Icons.monitor_weight_outlined),
                InfoTile(label: 'Dose théorique (IU)', value: er.doseTotaleTheoriqueIU?.toString(), icon: Icons.functions_outlined),
                InfoTile(label: 'Méthode Besredka', value: er.methodeBesredka ? 'Oui' : 'Non', icon: Icons.science_outlined),
                InfoTile(label: 'Dilution réalisée', value: er.dilutionRealisee ? 'Oui' : 'Non', icon: Icons.opacity_outlined),
                if (er.quantiteSerumPhysiologiqueMl != null)
                  InfoTile(label: 'Sérum physiologique', value: '${er.quantiteSerumPhysiologiqueMl} ml', icon: Icons.water_drop_outlined),
                InfoTile(
                  label: 'Voies',
                  value: er.voies.isEmpty ? null : er.voies.map((v) => v.label).join(', '),
                  icon: Icons.gps_fixed,
                ),
                InfoTile(label: 'Réaction post-ERIG', value: er.reactionPostErig ? 'Oui' : 'Non', icon: Icons.warning_amber_rounded),
                InfoTile(label: 'Type de réaction', value: er.typeReaction?.label, icon: Icons.emergency_outlined),
                InfoTile(label: 'Mesures', value: er.mesuresReaction, icon: Icons.medication_outlined),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'I · Chirurgie / Suture',
          subtitle: 'Prise en charge chirurgicale des lésions',
          icon: Icons.healing,
          accent: EpidemiologyTheme.warning,
          child: InfoGrid(
            items: [
              InfoTile(label: 'Chirurgie réalisée', value: ch.realise.label, icon: Icons.healing_outlined),
              if (ch.realise == SurgeryPerformed.oui) ...[
                InfoTile(label: 'Date', value: ddMMyyyy(ch.date), icon: Icons.event),
                InfoTile(label: 'Hôpital', value: ch.hopital, icon: Icons.local_hospital_outlined),
                InfoTile(label: 'Service', value: ch.service, icon: Icons.account_tree_outlined),
              ],
              InfoTile(label: 'Suture', value: ch.suture.label, icon: Icons.construction_outlined),
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
      subtitle: 'Produit vaccinal utilisé',
      icon: Icons.vaccines,
      accent: EpidemiologyTheme.redPrimary,
      child: Column(
        children: [
          InfoGrid(
            items: [
              InfoTile(label: 'Type de vaccin', value: v.typeVaccin.label, icon: Icons.vaccines_outlined),
              InfoTile(label: 'DCI', value: v.dci, icon: Icons.biotech_outlined),
              InfoTile(label: 'N° de lot', value: v.numeroLot, icon: Icons.inventory_2_outlined),
              InfoTile(label: 'Date de péremption', value: ddMMyyyy(v.datePeremption), icon: Icons.update),
              InfoTile(label: 'Voie', value: v.voie.label, icon: Icons.gps_fixed),
              InfoTile(label: 'Dose administrée', value: v.doseAdministree != null ? '${v.doseAdministree} ml' : null, icon: Icons.speed_outlined),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.estTermine
                  ? EpidemiologyTheme.successLight
                  : p.aRetard
                      ? EpidemiologyTheme.warningLight
                      : EpidemiologyTheme.warm50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  p.estTermine ? Icons.check_circle_outline : p.aRetard ? Icons.schedule : Icons.timeline,
                  size: 16,
                  color: p.estTermine ? EpidemiologyTheme.success : p.aRetard ? EpidemiologyTheme.warning : EpidemiologyTheme.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${p.type.label} · ${p.dosesRealisees}/${p.totalDoses} doses réalisées'
                    '${p.aRetard ? ' — protocole en retard' : p.estTermine ? ' — protocole terminé' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: p.estTermine ? EpidemiologyTheme.successDark : p.aRetard ? EpidemiologyTheme.warningDark : EpidemiologyTheme.slate700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DoseTimeline(doses: p.doses),
          if (p.remarques != null) ...[
            const SizedBox(height: 8),
            InfoGrid(
              items: [InfoTile(label: 'Remarques', value: p.remarques, icon: Icons.notes)],
            ),
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
    return Column(
      children: [
        DossierSectionCard(
          title: 'K · Effets indésirables (MPVI)',
          subtitle: 'Manifestation post-vaccinale indésirable',
          icon: Icons.warning_amber_rounded,
          accent: mpvi.present ? EpidemiologyTheme.warning : EpidemiologyTheme.slate400,
          child: InfoGrid(
            items: [
              InfoTile(label: 'MPVI présent', value: mpvi.present ? 'Oui' : 'Non', icon: Icons.warning_amber_rounded),
              if (mpvi.present) ...[
                InfoTile(label: 'Date d\'apparition', value: ddMMyyyy(mpvi.dateApparition), icon: Icons.event),
                InfoTile(label: 'Manifestations', value: mpvi.manifestations, icon: Icons.notes),
                InfoTile(label: 'Gravité', value: mpvi.gravite.label, icon: Icons.trending_up),
                InfoTile(label: 'Mesures prises', value: mpvi.mesuresPrises, icon: Icons.medication_outlined),
                InfoTile(
                  label: 'Déclaration pharmacovigilance',
                  value: mpvi.declarationPharmacovigilance ? 'Oui' : 'Non',
                  icon: Icons.assignment_outlined,
                ),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'L · Antibiotiques',
          subtitle: 'Prescription d\'antibioprophylaxie',
          icon: Icons.medication,
          accent: ab.estPrescrit ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: InfoGrid(
            items: [
              InfoTile(label: 'Prescription', value: ab.prescription.label, icon: Icons.medication_outlined),
              if (ab.estPrescrit) ...[
                InfoTile(label: 'Molécule', value: ab.molecule, icon: Icons.science_outlined),
                InfoTile(label: 'Dose', value: ab.dose, icon: Icons.speed_outlined),
                InfoTile(label: 'Durée', value: ab.duree, icon: Icons.timeline),
                InfoTile(label: 'Motif', value: ab.motif, icon: Icons.notes),
                InfoTile(label: 'Observations', value: ab.observations, icon: Icons.notes),
              ],
            ],
          ),
        ),
        DossierSectionCard(
          title: 'M · Vaccination tétanos',
          subtitle: 'Rappel VAT selon le statut vaccinal',
          icon: Icons.shield,
          accent: tt.estRealisee ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: InfoGrid(
            items: [
              InfoTile(label: 'Statut', value: tt.statut.label, icon: Icons.shield_outlined),
              InfoTile(label: 'Type', value: tt.type.label, icon: Icons.vaccines_outlined),
              InfoTile(label: 'Date d\'administration', value: ddMMyyyy(tt.dateAdministration), icon: Icons.event),
              InfoTile(label: 'Observations', value: tt.observations, icon: Icons.notes),
            ],
          ),
        ),
        DossierSectionCard(
          title: 'N · Autres traitements',
          subtitle: 'Traitements complémentaires',
          icon: Icons.medication_liquid,
          accent: autres.present ? EpidemiologyTheme.teal : EpidemiologyTheme.slate400,
          child: InfoGrid(
            items: [
              InfoTile(label: 'Traitement', value: autres.present ? 'Oui' : 'Non', icon: Icons.medication_liquid_outlined),
              if (autres.present) ...[
                InfoTile(label: 'Description', value: autres.description, icon: Icons.notes),
                InfoTile(label: 'Observations', value: autres.observations, icon: Icons.notes),
              ],
            ],
          ),
        ),
      ],
    );
  }
}