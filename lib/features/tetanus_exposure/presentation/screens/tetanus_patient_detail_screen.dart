import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../../data/models/tetanus_models.dart';
import '../widgets/tetanus_status_badge.dart';

class TetanusPatientDetailScreen extends StatelessWidget {
  final String patientId;
  const TetanusPatientDetailScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    final patient =
        GetIt.instance<TetanusRepository>().getPatientById(patientId);
    if (patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient')),
        body: const Center(child: Text('Patient introuvable')),
      );
    }
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: EpidemiologyTheme.warm700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          patient.nomComplet,
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: EpidemiologyTheme.warm800),
        ),
        centerTitle: false,
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
            bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _buildPatientHeader(patient),
          const SizedBox(height: 16),
          if (patient.estUrgent) ...[
            _buildAlertBanner(patient),
            const SizedBox(height: 12),
          ],
          _buildWoundCard(patient),
          const SizedBox(height: 12),
          _buildVaccinCard(patient),
          const SizedBox(height: 12),
          _buildDecisionBanner(patient),
          const SizedBox(height: 12),
          _buildTimeline(patient),
          const SizedBox(height: 16),
          _buildActions(patient),
        ],
      ),
    );
  }

  // ── Patient Header ──

  Widget _buildPatientHeader(TetanusPatientModel p) {
    final isUrgent = p.estUrgent;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUrgent
              ? [EpidemiologyTheme.danger, EpidemiologyTheme.orange]
              : [EpidemiologyTheme.amber, EpidemiologyTheme.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: (isUrgent ? EpidemiologyTheme.danger : EpidemiologyTheme.amber)
                .withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: (isUrgent ? EpidemiologyTheme.danger : EpidemiologyTheme.amber)
                .withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    p.nomComplet
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join(''),
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nomComplet,
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.age} ans \u2022 ${p.sexe} \u2022 ${p.id}',
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              if (isUrgent)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        'URGENT',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              TetanusStatusBadge(statut: p.statutDossier, fontSize: 11),
              const SizedBox(width: 10),
              TetanusVaccinStatusBadge(status: p.statutVaccinal, fontSize: 11),
              const Spacer(),
              Text(
                'Blessure : ${p.dateBlessure}',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.75)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Alert Banner ──

  Widget _buildAlertBanner(TetanusPatientModel p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            EpidemiologyTheme.danger.withValues(alpha: 0.08),
            EpidemiologyTheme.orange.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: EpidemiologyTheme.danger.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.warning_amber_rounded,
                color: EpidemiologyTheme.danger, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prise en charge urgente requise',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: EpidemiologyTheme.danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'VAT + Immunoglobulines à administrer sans délai',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: EpidemiologyTheme.warm600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Wound Card ──

  Widget _buildWoundCard(TetanusPatientModel p) {
    return _sectionCard(
      'Plaie',
      Icons.healing_outlined,
      EpidemiologyTheme.teal,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Type', p.typePlaie.label),
          _infoRow('Localisation', p.localisation),
          const Divider(height: 20, color: EpidemiologyTheme.warm100),
          _infoRow('Profonde', p.plaieProfonde ? 'Oui' : 'Non'),
          _infoRow('Souillée', p.plaieSouillee ? 'Oui' : 'Non'),
          _infoRow('Corps étranger', p.corpsEtranger ? 'Oui' : 'Non'),
          _infoRow('Soins locaux', p.soinsLocauxRealises ? 'Faits' : 'Non faits'),
          _infoRow('Délai consultation', p.delaiConsultation),
        ],
      ),
    );
  }

  // ── Vaccin Card ──

  Widget _buildVaccinCard(TetanusPatientModel p) {
    return _sectionCard(
      'Statut vaccinal',
      Icons.vaccines_outlined,
      EpidemiologyTheme.info,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Statut', p.statutVaccinal.label),
          if (p.derniereDoseDate != null)
            _infoRow('Dernière dose', p.derniereDoseDate!),
          if (p.nombreDosesConnues != null)
            _infoRow('Doses connues', '${p.nombreDosesConnues}'),
        ],
      ),
    );
  }

  // ── Section Card ──

  Widget _sectionCard(String title, IconData icon, Color accent, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          ...EpidemiologyTheme.shadowSm,
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
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.12), accent.withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: accent),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: EpidemiologyTheme.warm800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: EpidemiologyTheme.warm500,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.warm800,
            ),
          ),
        ],
      ),
    );
  }

  // ── Decision Banner ──

  Widget _buildDecisionBanner(TetanusPatientModel p) {
    final (Color fg, Color bg, IconData icon) = switch (p.decision) {
      TetanusDecision.simpleSurveillance => (
        EpidemiologyTheme.success,
        EpidemiologyTheme.successLight,
        Icons.check_circle_rounded,
      ),
      TetanusDecision.rappelIndique => (
        EpidemiologyTheme.warning,
        EpidemiologyTheme.warningLight,
        Icons.vaccines_rounded,
      ),
      TetanusDecision.vaccinationComplete => (
        EpidemiologyTheme.info,
        EpidemiologyTheme.infoLight,
        Icons.medication_rounded,
      ),
      TetanusDecision.vaccinationEtIg => (
        EpidemiologyTheme.danger,
        EpidemiologyTheme.dangerLight,
        Icons.warning_amber_rounded,
      ),
      TetanusDecision.avisSpecialise => (
        EpidemiologyTheme.orange,
        EpidemiologyTheme.orangeLight,
        Icons.local_hospital_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg, bg.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: fg.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: fg, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Décision médicale',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: fg.withValues(alpha: 0.8),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.decision.label,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
              _decisionBadge(p.decision, fg),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: fg.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: fg.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: fg),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    p.decision.resume,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: EpidemiologyTheme.warm700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (p.immunoglobulines) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bloodtype, size: 16, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    'Immunoglobulines antitétaniques requises',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _decisionBadge(TetanusDecision decision, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            decision.label.split(' ').first,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Timeline ──

  Widget _buildTimeline(TetanusPatientModel p) {
    final reversed = p.historique.reversed.toList();
    return _sectionCard(
      'Chronologie des actes',
      Icons.history_rounded,
      EpidemiologyTheme.amber,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reversed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: EpidemiologyTheme.warm300),
                  const SizedBox(width: 8),
                  Text(
                    'Aucun acte enregistré',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: EpidemiologyTheme.warm400,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(reversed.length, (i) {
              return _timelineItem(reversed[i], i == reversed.length - 1);
            }),
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
                    color: EpidemiologyTheme.amber,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: EpidemiologyTheme.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: EpidemiologyTheme.amber.withValues(alpha: 0.3),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        acte.typeActe,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.warm800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: EpidemiologyTheme.warm50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: EpidemiologyTheme.warm100),
                        ),
                        child: Text(
                          acte.dateActe,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: EpidemiologyTheme.warm500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (acte.administrateur != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 12, color: EpidemiologyTheme.warm400),
                          const SizedBox(width: 4),
                          Text(
                            acte.administrateur!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: EpidemiologyTheme.warm500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (acte.numeroLot != null)
                    Row(
                      children: [
                        Icon(Icons.qr_code,
                            size: 12, color: EpidemiologyTheme.warm400),
                        const SizedBox(width: 4),
                        Text(
                          'Lot: ${acte.numeroLot}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: EpidemiologyTheme.warm400,
                          ),
                        ),
                      ],
                    ),
                  if (acte.observations != null &&
                      acte.observations!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: EpidemiologyTheme.warm50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        acte.observations!,
                        style: GoogleFonts.inter(
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

  // ── Actions ──

  Widget _buildActions(TetanusPatientModel p) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(
              'Modifier la décision',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: EpidemiologyTheme.amber,
              side: BorderSide(color: EpidemiologyTheme.amber.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: Text(
              'Enregistrer un acte',
              style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: EpidemiologyTheme.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
