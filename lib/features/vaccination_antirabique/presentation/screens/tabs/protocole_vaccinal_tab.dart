import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/evaluation_initiale_model.dart';
import '../../../data/models/patient_antirabique_model.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import '../../../domain/repositories/evaluation_initiale_repository.dart';
import '../../../domain/repositories/protocole_repository.dart';
import '../../../../../injection_container.dart' as di;
import '../../widgets/protocole_timeline_card.dart';
import '../evaluation_initiale_screen.dart';
import '../rabies_vaccination_book_screen.dart';
import 'validation_dose_screen.dart';
import 'certificat_screen.dart';
import 'stock_dashboard.dart';

class ProtocoleVaccinalTab extends StatefulWidget {
  final String patientId;

  const ProtocoleVaccinalTab({super.key, required this.patientId});

  @override
  State<ProtocoleVaccinalTab> createState() => _ProtocoleVaccinalTabState();
}

class _ProtocoleVaccinalTabState extends State<ProtocoleVaccinalTab> {
  ProtocoleVaccinalModel? _protocole;
  InitialRabiesAssessment? _evaluation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      di.sl<ProtocoleRepository>().getProtocole(widget.patientId),
      di.sl<EvaluationInitialeRepository>().getEvaluation(widget.patientId),
    ]);
    setState(() {
      _protocole = results[0] as ProtocoleVaccinalModel?;
      _evaluation = results[1] as InitialRabiesAssessment?;
      _loading = false;
    });
  }

  IconData _protocoleIcon(ProtocoleType type) => switch (type) {
    ProtocoleType.essen || ProtocoleType.essenReduit => Icons.timeline,
    ProtocoleType.zagreb => Icons.schedule,
    ProtocoleType.ipc => Icons.speed,
  };

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_protocole == null) return const SizedBox();
    return _buildContent();
  }

  Widget _buildContent() {
    if (_evaluation == null) {
      return _buildEvaluationGate();
    }
    final protocole = _protocole!;
    final nextDose = protocole.prochaineDose;
    final nextDoseId = nextDose?.id;

    return ListView(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
      children: [
        // ── Résumé protocole ──
        _buildProtocoleHeader(protocole),
        const SizedBox(height: EpidemiologyTheme.spaceLg),

        // ── Carte RIG ──
        if (protocole.rigIndiquee)
          _buildRigCard(protocole),

        // ── Bannière retard ──
        if (protocole.aRetard) ...[
          const SizedBox(height: EpidemiologyTheme.spaceMd),
          _buildRetardBanner(protocole),
        ],

        // ── Dose aujourd'hui ──
        if (protocole.aDoseAujourdhui) ...[
          const SizedBox(height: EpidemiologyTheme.spaceMd),
          _buildTodayBanner(protocole),
        ],

        const SizedBox(height: EpidemiologyTheme.spaceLg),

        // ── Métriques ──
        _buildProtocoleMeta(protocole),
        const SizedBox(height: EpidemiologyTheme.spaceLg),

        // ── Ouverture du carnet vaccinal ──
        FilledButton.icon(
          onPressed: _openCarnet,
          icon: const Icon(Icons.menu_book_rounded, size: 18),
          label: const Text('Consulter le carnet vaccinal'),
          style: FilledButton.styleFrom(
            backgroundColor: EpidemiologyTheme.redPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
            textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: EpidemiologyTheme.spaceXxl),

        // ── Progression ──
        _buildProgressCard(protocole),
        const SizedBox(height: EpidemiologyTheme.spaceXxl),

        // ── Prochaine dose (mise en avant) ──
        if (nextDose != null && nextDose.statutDetaille == DoseStatutDetaille.aVenir) ...[
          Container(
            padding: const EdgeInsets.all(EpidemiologyTheme.spaceLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [EpidemiologyTheme.redSurface, EpidemiologyTheme.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
              border: Border.all(color: EpidemiologyTheme.redLight, width: 1),
              boxShadow: [
                BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: EpidemiologyTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                    boxShadow: [BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Prochaine dose', style: EpidemiologyTheme.caption(color: EpidemiologyTheme.redPrimary)),
                      Text(
                        '${nextDose.etiquetteDose} — ${nextDose.datePrevue}',
                        style: EpidemiologyTheme.subtitle(color: EpidemiologyTheme.slate900),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: _openValidationDose,
                  style: FilledButton.styleFrom(
                    backgroundColor: EpidemiologyTheme.redPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
                  ),
                  child: const Text('Valider'),
                ),
              ],
            ),
          ),
          const SizedBox(height: EpidemiologyTheme.spaceXxl),
        ],

        // ── Timeline des doses ──
        ...protocole.doses.asMap().entries.map((entry) {
          return ProtocoleTimelineCard(
            dose: entry.value,
            isLast: entry.key == protocole.doses.length - 1,
            isNextDose: entry.value.id == nextDoseId,
          );
        }),
        const SizedBox(height: EpidemiologyTheme.spaceXxl),

        // ── Actions ──
        if (_protocole!.dosesAdministrees > 0) ...[
          Center(
            child: OutlinedButton.icon(
              onPressed: _openCertificat,
              icon: const Icon(Icons.verified),
              label: const Text('Certificat de vaccination'),
              style: OutlinedButton.styleFrom(
                foregroundColor: EpidemiologyTheme.teal,
                side: const BorderSide(color: EpidemiologyTheme.tealLight),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
              ),
            ),
          ),
          const SizedBox(height: EpidemiologyTheme.spaceMd),
        ],
        Center(
          child: FilledButton.icon(
            onPressed: _openValidationDose,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Enregistrer une dose'),
            style: FilledButton.styleFrom(
              backgroundColor: EpidemiologyTheme.redPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
            ),
          ),
        ),
        const SizedBox(height: EpidemiologyTheme.spaceMd),
        Center(
          child: TextButton.icon(
            onPressed: _openStock,
            icon: Icon(Icons.inventory_2, size: 18, color: EpidemiologyTheme.slate400),
            label: Text('Gestion des stocks', style: EpidemiologyTheme.bodySm()),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProtocoleHeader(ProtocoleVaccinalModel protocole) {
    final globalStatus = protocole.estTermine
        ? 'Terminé'
        : protocole.aRetard
            ? 'En retard'
            : protocole.aDoseAujourdhui
                ? "Aujourd'hui"
                : protocole.estEnCours
                    ? 'En cours'
                    : 'Non commencé';

    final (Color statusColor, Color statusBg) = protocole.estTermine
        ? (EpidemiologyTheme.success, EpidemiologyTheme.successLight)
        : protocole.aRetard
            ? (EpidemiologyTheme.danger, EpidemiologyTheme.dangerLight)
            : protocole.aDoseAujourdhui
                ? (EpidemiologyTheme.warning, EpidemiologyTheme.warningLight)
                : (EpidemiologyTheme.info, EpidemiologyTheme.infoLight);

    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        boxShadow: EpidemiologyTheme.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: EpidemiologyTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
                  boxShadow: [BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Icon(_protocoleIcon(protocole.type), color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(protocole.type.label, style: EpidemiologyTheme.h3()),
                    Text(
                      '${protocole.type.duree} · ${protocole.totalDoses} doses',
                      style: EpidemiologyTheme.bodySm(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      protocole.estTermine ? Icons.check_circle
                          : protocole.aRetard ? Icons.warning
                          : protocole.aDoseAujourdhui ? Icons.notifications_active
                          : Icons.sync,
                      size: 14, color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      globalStatus,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (protocole.dateDebut.isNotEmpty) ...[
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: EpidemiologyTheme.slate400),
                const SizedBox(width: 6),
                Text(
                  'Début : ${protocole.dateDebut}',
                  style: EpidemiologyTheme.bodySm(),
                ),
                const Spacer(),
                if (protocole.doses.isNotEmpty)
                  Text(
                    'J + ${DateTime.now().difference(DateTime.parse(protocole.dateDebut)).inDays}',
                    style: EpidemiologyTheme.label(color: EpidemiologyTheme.slate500),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRigCard(ProtocoleVaccinalModel protocole) {
    final rigAdmin = protocole.rigAdministree;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EpidemiologyTheme.infoLight, EpidemiologyTheme.infoLight.withValues(alpha: 0.5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(color: EpidemiologyTheme.infoLight, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.info,
              borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusSm),
            ),
            child: const Icon(Icons.science, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Immunoglobulines antirabiques (RIG)', style: EpidemiologyTheme.label(color: EpidemiologyTheme.info)),
                const SizedBox(height: 2),
                Text(
                  rigAdmin
                      ? 'Administrées · Lot: ${protocole.rigNumeroLot ?? "N/R"}'
                      : 'Indiquées (Catégorie III) · Non encore administrées',
                  style: EpidemiologyTheme.bodySm(color: rigAdmin ? EpidemiologyTheme.info : EpidemiologyTheme.warning),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: rigAdmin ? EpidemiologyTheme.successLight : EpidemiologyTheme.warningLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: (rigAdmin ? EpidemiologyTheme.success : EpidemiologyTheme.warning).withValues(alpha: 0.15)),
            ),
            child: Text(
              rigAdmin ? 'Fait' : 'À faire',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: rigAdmin ? EpidemiologyTheme.success : EpidemiologyTheme.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetardBanner(ProtocoleVaccinalModel protocole) {
    final retards = protocole.dosesEnRetard;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EpidemiologyTheme.dangerLight, EpidemiologyTheme.warningLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(color: EpidemiologyTheme.dangerLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: EpidemiologyTheme.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${retards.length} dose(s) en retard · ${retards.map((d) => '${d.jourTheorique.isNotEmpty ? "${d.jourTheorique} " : ""}(${d.datePrevue})').join(", ")}',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayBanner(ProtocoleVaccinalModel protocole) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [EpidemiologyTheme.warningLight, EpidemiologyTheme.amberLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(color: EpidemiologyTheme.warningLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: EpidemiologyTheme.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "${protocole.dosesAujourdhui.length} dose(s) prévue(s) aujourd'hui · ${protocole.dosesAujourdhui.map((d) => d.etiquetteDose).join(", ")}",
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.warning),
            ),
          ),
          FilledButton(
            onPressed: _openValidationDose,
            style: FilledButton.styleFrom(
              backgroundColor: EpidemiologyTheme.warning,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusSm)),
              textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            child: const Text('Voir'),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocoleMeta(ProtocoleVaccinalModel protocole) {
    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceLg),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        boxShadow: EpidemiologyTheme.shadowMd,
      ),
      child: Row(
        children: [
          _metaItem(Icons.schedule, 'Durée', protocole.type.duree),
          _metaDivider(),
          _metaItem(Icons.medical_services, 'Visites', '${protocole.type.nombreVisites}'),
          _metaDivider(),
          _metaItem(Icons.vaccines, 'Nb doses', '${protocole.dosesAdministrees}/${protocole.totalDoses}'),
        ],
      ),
    );
  }

  Widget _metaItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: EpidemiologyTheme.redPrimary),
          const SizedBox(height: 4),
          Text(value, style: EpidemiologyTheme.label(color: EpidemiologyTheme.slate900)),
          Text(label, style: EpidemiologyTheme.caption()),
        ],
      ),
    );
  }

  Widget _metaDivider() {
    return Container(width: 1, height: 40, color: EpidemiologyTheme.slate100);
  }

  Widget _buildProgressCard(ProtocoleVaccinalModel protocole) {
    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceLg),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        boxShadow: EpidemiologyTheme.shadowMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Progression', style: EpidemiologyTheme.label()),
              const Spacer(),
              Text(
                '${protocole.dosesAdministrees}/${protocole.totalDoses} doses',
                style: EpidemiologyTheme.bodySm(color: EpidemiologyTheme.slate900),
              ),
              if (protocole.dosesRestantes > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '(${protocole.dosesRestantes} restante${protocole.dosesRestantes > 1 ? "s" : ""})',
                  style: EpidemiologyTheme.caption(),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          EpidemiologyTheme.doseProgress(current: protocole.dosesAdministrees, total: protocole.totalDoses),
        ],
      ),
    );
  }

  void _openCertificat() {
    if (_protocole == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CertificatScreen(
          patientId: _protocole!.patientId,
          patientNom: '',
        ),
      ),
    );
  }

  void _openStock() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const StockDashboard()),
    );
  }

  void _openCarnet() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RabiesVaccinationBookScreen(patientId: widget.patientId)),
    );
  }

  void _openValidationDose() {
    final nextDose = _protocole?.prochaineDose;
    if (nextDose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Toutes les doses ont été administrées'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ValidationDoseScreen(
          patientId: widget.patientId,
          dose: nextDose,
          onValidated: _load,
        ),
      ),
    );
  }

  Widget _buildEvaluationGate() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: EpidemiologyTheme.redSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: EpidemiologyTheme.redLight, width: 2),
                boxShadow: [BoxShadow(color: EpidemiologyTheme.redPrimary.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.checklist_rtl, size: 40, color: EpidemiologyTheme.redPrimary),
            ),
            const SizedBox(height: EpidemiologyTheme.spaceXl),
            Text(
              'Évaluation initiale requise',
              style: EpidemiologyTheme.h3(color: EpidemiologyTheme.slate900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Avant de consulter ou de démarrer le protocole vaccinal, '
              'veuillez réaliser l\'évaluation initiale J0.',
              style: EpidemiologyTheme.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _openEvaluationInitiale,
              icon: const Icon(Icons.checklist),
              label: const Text('Réaliser l\'évaluation J0'),
              style: FilledButton.styleFrom(
                backgroundColor: EpidemiologyTheme.redPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEvaluationInitiale() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EvaluationInitialeScreen(patientId: widget.patientId),
      ),
    );
    if (result == true) {
      _load();
    }
  }
}
