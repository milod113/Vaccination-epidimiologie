import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/models/dossier/rabies_case_record.dart';
import '../../domain/repositories/rabies_dossier_repository.dart';
import '../../domain/services/rabies_traceability_service.dart';
import '../widgets/rabies_dossier_widgets.dart';
import '../widgets/traceability/dossier_history_timeline.dart';
import '../widgets/traceability/registry_card.dart';
import '../widgets/traceability/traceability_summary_card.dart';
import '../widgets/traceability/traceability_ui.dart';

/// Écran dédié « Traçabilité réglementaire » d'un dossier antirabique.
///
/// Vue complète : en-tête patient, synthèse, volets administratifs
/// (carte/registre) et historique chronologique des actions avec validateur.
class RabiesTraceabilityScreen extends StatefulWidget {
  final String dossierId;

  const RabiesTraceabilityScreen({super.key, required this.dossierId});

  @override
  State<RabiesTraceabilityScreen> createState() =>
      _RabiesTraceabilityScreenState();
}

class _RabiesTraceabilityScreenState extends State<RabiesTraceabilityScreen> {
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
    if (!mounted) return;
    setState(() {
      _dossier = dossier;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        backgroundColor: EpidemiologyTheme.warm50,
        elevation: 0,
        title: Text(
          'Traçabilité réglementaire',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.slate900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: EpidemiologyTheme.slate900,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(_dossier),
    );
  }

  Widget _buildBody(RabiesCaseRecord? dossier) {
    if (dossier == null) {
      return EpidemiologyTheme.emptyState(
        Icons.folder_off,
        'Dossier introuvable',
        subtitle: 'Il a peut-être été supprimé',
      );
    }
    final summary = RabiesTraceabilityService.resume(dossier);
    final entries = RabiesTraceabilityService.lister(dossier);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _patientHeader(dossier),
          const SizedBox(height: 14),
          TraceabilitySummaryCard(summary: summary),
          const SizedBox(height: 14),
          RegistryCard(summary: summary),
          const SizedBox(height: 14),
          DossierHistoryTimeline(entries: entries),
          const SizedBox(height: 12),
          _footerNote(),
        ],
      ),
    );
  }

  Widget _patientHeader(RabiesCaseRecord d) {
    final color = TraceabilityUi.traceabilityColor(
      RabiesTraceabilityService.resume(d).statut,
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.primaryGradientWarm,
        borderRadius: BorderRadius.circular(22),
        boxShadow: EpidemiologyTheme.shadowHero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.patientNomComplet,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${d.numeroDossier} · ${d.patientAge} ans · ${d.identity.sexe.label}',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 5),
                    Text(
                      d.categorie.label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dossier créé le ${ddMMyyyy(d.dateCreation)} · ${d.evolution.resultat.label}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: EpidemiologyTheme.slate400),
          const SizedBox(width: 6),
          Text(
            'Conformité dossier antirabique algérien — sections O & P',
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
