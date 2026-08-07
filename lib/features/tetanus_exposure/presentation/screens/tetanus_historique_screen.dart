import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/tetanus_models.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../widgets/act/tetanus_act_history_timeline.dart';
import '../widgets/tetanus_evaluation_controls.dart';
import 'tetanus_act_form_screen.dart';

/// Historique consolidé des actes enregistrés (tous patients).
///
/// Aperçu premium : en-tête, bouton « Enregistrer un acte » (sélection du
/// patient), et regrouplement des actes par dossier via une frise premium.
class TetanusHistoriqueScreen extends StatefulWidget {
  const TetanusHistoriqueScreen({super.key});

  @override
  State<TetanusHistoriqueScreen> createState() =>
      _TetanusHistoriqueScreenState();
}

class _TetanusHistoriqueScreenState extends State<TetanusHistoriqueScreen> {
  @override
  Widget build(BuildContext context) {
    final repo = GetIt.instance<TetanusRepository>();
    final patients = repo.getPatients();
    final allActes = repo.getAllActes();

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: EpidemiologyTheme.warm700,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Historique des actes',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: EpidemiologyTheme.warm900,
          ),
        ),
        centerTitle: false,
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
          bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _pickPatient(patients),
        backgroundColor: EpidemiologyTheme.redPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline, size: 20),
        label: Text(
          'Enregistrer un acte',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
      body: patients.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: patients.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _buildPatientCard(patients[i], allActes),
            ),
    );
  }

  Widget _buildPatientCard(
    TetanusPatientModel patient,
    List<TetanusActeModel> allActes,
  ) {
    final acts = allActes.where((a) => a.patientId == patient.id).toList();
    final color = patient.estUrgent
        ? EpidemiologyTheme.danger
        : EpidemiologyTheme.redPrimary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.12),
                      color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nomComplet,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.warm800,
                      ),
                    ),
                    Text(
                      '${patient.id} · ${patient.age} ans · ${patient.sexe}',
                      style: GoogleFonts.cairo(
                        fontSize: 11.5,
                        color: EpidemiologyTheme.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              TetanusBadge(
                label: '${acts.length} acte${acts.length > 1 ? 's' : ''}',
                color: color,
                icon: Icons.fact_check_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: EpidemiologyTheme.warm100),
          const SizedBox(height: 6),
          TetanusActHistoryTimeline(
            acts: acts,
            emptyMessage: 'Aucun acte enregistré pour ce dossier.',
          ),
        ],
      ),
    );
  }

  void _pickPatient(List<TetanusPatientModel> patients) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPatientSheet(patients),
    );
  }

  Widget _buildPatientSheet(List<TetanusPatientModel> patients) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: EpidemiologyTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.warm200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Choisir un patient',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: EpidemiologyTheme.warm900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: EpidemiologyTheme.warm400,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: EpidemiologyTheme.warm100),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: patients.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _patientTile(patients[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _patientTile(TetanusPatientModel patient) {
    final color = patient.estUrgent
        ? EpidemiologyTheme.danger
        : EpidemiologyTheme.redPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          Navigator.of(context).pop();
          final ok = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => TetanusActFormScreen(patientId: patient.id),
            ),
          );
          if (ok == true && mounted) setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: EpidemiologyTheme.warm50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EpidemiologyTheme.warm150),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_outline, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.nomComplet,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: EpidemiologyTheme.warm800,
                      ),
                    ),
                    Text(
                      '${patient.id} · ${patient.age} ans · ${patient.sexe} · ${patient.statutDossier.label}',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: EpidemiologyTheme.warm400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: EpidemiologyTheme.warm300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.warm100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.history_rounded,
              size: 48,
              color: EpidemiologyTheme.warm300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun acte enregistré',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.warm500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Les actes de vaccination, de soins et de suivi\napparaîtront ici',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: EpidemiologyTheme.warm400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
