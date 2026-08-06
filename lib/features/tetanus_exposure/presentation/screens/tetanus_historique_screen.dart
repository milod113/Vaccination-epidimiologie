import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../domain/repositories/tetanus_repository.dart';
import '../../data/models/tetanus_models.dart';

class TetanusHistoriqueScreen extends StatelessWidget {
  const TetanusHistoriqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patients = GetIt.instance<TetanusRepository>().getPatients();
    final allActes = <TetanusActeModel>[];
    for (final p in patients) {
      for (final a in p.historique) {
        allActes.add(a);
      }
    }
    allActes.sort((a, b) => b.dateActe.compareTo(a.dateActe));

    final patientMap = {for (final p in patients) p.id: p.nomComplet};

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_rounded, color: EpidemiologyTheme.warm700),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Historique des actes'),
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(
            bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1)),
      ),
      body: allActes.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: allActes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final acte = allActes[i];
                final nom = patientMap[acte.patientId] ?? 'Inconnu';
                return _buildActeCard(acte, nom);
              },
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
            child: Icon(Icons.history_rounded,
                size: 48, color: EpidemiologyTheme.warm300),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun acte enregistré',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: EpidemiologyTheme.warm500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Les actes de vaccination et de soins\napparaîtront ici',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: EpidemiologyTheme.warm400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActeCard(TetanusActeModel acte, String nomPatient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: EpidemiologyTheme.warm100),
        boxShadow: [
          BoxShadow(
            color: EpidemiologyTheme.amber.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          ...EpidemiologyTheme.shadowSm,
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  EpidemiologyTheme.amber.withValues(alpha: 0.12),
                  EpidemiologyTheme.orange.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.vaccines_rounded,
                color: EpidemiologyTheme.amber, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        acte.typeActe,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: EpidemiologyTheme.warm800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: EpidemiologyTheme.warm50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: EpidemiologyTheme.warm100),
                      ),
                      child: Text(
                        acte.dateActe,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: EpidemiologyTheme.warm500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13, color: EpidemiologyTheme.warm400),
                    const SizedBox(width: 5),
                    Text(
                      nomPatient,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: EpidemiologyTheme.warm500,
                      ),
                    ),
                  ],
                ),
                if (acte.vaccin != null ||
                    acte.numeroLot != null ||
                    acte.administrateur != null) ...[
                  const SizedBox(height: 10),
                  const Divider(
                      height: 1, color: EpidemiologyTheme.warm100),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (acte.vaccin != null)
                        _tag(acte.vaccin!,
                            Icons.medication_outlined),
                      if (acte.numeroLot != null)
                        _tag('Lot: ${acte.numeroLot}',
                            Icons.qr_code),
                      if (acte.administrateur != null)
                        _tag(acte.administrateur!,
                            Icons.person_outline),
                    ],
                  ),
                ],
                if (acte.observations != null &&
                    acte.observations!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: EpidemiologyTheme.warm50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 14,
                            color: EpidemiologyTheme.warm400),
                        const SizedBox(width: 8),
                        Expanded(
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
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.warm50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EpidemiologyTheme.warm100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: EpidemiologyTheme.warm500),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: EpidemiologyTheme.warm500,
            ),
          ),
        ],
      ),
    );
  }
}
