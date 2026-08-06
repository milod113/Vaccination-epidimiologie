import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/epidemiology_theme.dart';
import '../../data/models/travel_models.dart';
import '../../domain/repositories/travel_repository.dart';
import '../widgets/travel_patient_card.dart';

class TravelVaccinationHomeScreen extends StatelessWidget {
  const TravelVaccinationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = GetIt.instance<TravelRepository>();
    final patients = repo.getProchainsDeparts();
    final destinations = repo.getDestinations();
    final now = DateTime.now();

    final vaccinsPlanifies = patients.fold<int>(0, (sum, p) => sum + p.vaccinsPlanifies);
    final vaccinsAdministres = patients.fold<int>(0, (sum, p) => sum + p.vaccinsAdministres);

    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        title: const Text('Vaccination du voyageur'),
        backgroundColor: EpidemiologyTheme.white,
        surfaceTintColor: EpidemiologyTheme.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: Border(bottom: BorderSide(color: EpidemiologyTheme.warm100, width: 1)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: EpidemiologyTheme.infoChip(Icons.calendar_today,
              '${now.day}/${now.month}/${now.year}', EpidemiologyTheme.teal),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          _buildHeroHeader(repo.totalPatients, vaccinsPlanifies, vaccinsAdministres, repo.alertCount),
          const SizedBox(height: 24),
          _buildKpiBar(repo.totalPatients, vaccinsPlanifies, vaccinsAdministres, repo.alertCount),
          const SizedBox(height: 28),
          EpidemiologyTheme.sectionHeader('Prochains départs',
            icon: Icons.flight_takeoff, iconColor: EpidemiologyTheme.teal,
            trailing: EpidemiologyTheme.infoChip(Icons.people, '${patients.length}', EpidemiologyTheme.teal)),
          const SizedBox(height: 14),
          _buildPatientList(context, patients),
          const SizedBox(height: 28),
          EpidemiologyTheme.sectionHeader('Recommandations par zone',
            icon: Icons.public, iconColor: EpidemiologyTheme.teal),
          const SizedBox(height: 14),
          _buildDestinationsGrid(destinations),
          const SizedBox(height: 28),
          _buildTravelAdvisoryCard(),
          const SizedBox(height: 24),
          _buildCtaBar(context),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(int total, int planifies, int administres, int alerts) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EpidemiologyTheme.teal, EpidemiologyTheme.emerald],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: EpidemiologyTheme.heroShadow(EpidemiologyTheme.teal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.flight, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Centre de vaccination internationale',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
                    const SizedBox(height: 4),
                    Text('Consultation pré-voyage et conseils aux voyageurs',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85), height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _heroStat('$total', 'Patients', Icons.people),
              _heroDivider(),
              _heroStat('$planifies', 'À planifier', Icons.schedule),
              _heroDivider(),
              _heroStat('$administres', 'Administrés', Icons.check_circle),
            ],
          ),
          if (alerts > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(width: 8),
                  Text('$alerts patient${alerts > 1 ? 's' : ''} avec des vaccins en retard',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, height: 1.0)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.75))),
        ],
      ),
    );
  }

  Widget _heroDivider() {
    return Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.15));
  }

  Widget _buildKpiBar(int total, int planifies, int administres, int alerts) {
    return Row(
      children: [
        _kpiPill(Icons.people_outline, '$total', 'Patients', EpidemiologyTheme.teal),
        const SizedBox(width: 8),
        _kpiPill(Icons.event_note, '$planifies', 'À planifier', EpidemiologyTheme.info),
        const SizedBox(width: 8),
        _kpiPill(Icons.check_circle_outline, '$administres', 'Administrés', EpidemiologyTheme.success),
        const SizedBox(width: 8),
        _kpiPill(Icons.warning_amber_rounded, '$alerts', 'Alertes', alerts > 0 ? EpidemiologyTheme.danger : EpidemiologyTheme.warm300),
      ],
    );
  }

  Widget _kpiPill(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: EpidemiologyTheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.10), width: 1),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3)),
            ...EpidemiologyTheme.shadowSm,
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.80), color],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(value, style: EpidemiologyTheme.metric(color: color)),
            const SizedBox(height: 1),
            Text(label, style: EpidemiologyTheme.overline(color: EpidemiologyTheme.warm400)),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList(BuildContext context, List<TravelPatient> patients) {
    if (patients.isEmpty) {
      return EpidemiologyTheme.emptyState(Icons.flight_takeoff, 'Aucun départ prévu', subtitle: 'Les patients programmés apparaîtront ici');
    }

    return Column(
      children: patients.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TravelPatientCard(patient: p),
      )).toList(),
    );
  }

  Widget _buildDestinationsGrid(List<DestinationInfo> destinations) {
    return Column(
      children: destinations.map((d) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildDestinationCard(d),
      )).toList(),
    );
  }

  Widget _buildDestinationCard(DestinationInfo dest) {
    Color alertColor;
    IconData alertIcon;
    switch (dest.niveauAlerte) {
      case TravelAlertLevel.urgent:
        alertColor = EpidemiologyTheme.danger;
        alertIcon = Icons.warning;
        break;
      case TravelAlertLevel.warning:
        alertColor = EpidemiologyTheme.warning;
        alertIcon = Icons.info_outline;
        break;
      case TravelAlertLevel.info:
        alertColor = EpidemiologyTheme.info;
        alertIcon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
        border: Border.all(color: alertColor.withValues(alpha: 0.10), width: 1),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: alertColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.public, size: 18, color: alertColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dest.pays, style: EpidemiologyTheme.subtitle(color: EpidemiologyTheme.warm800)),
                    Text(dest.region, style: EpidemiologyTheme.caption(color: EpidemiologyTheme.warm400)),
                  ],
                ),
              ),
              EpidemiologyTheme.statutBadge(dest.niveauAlerte.label, alertColor),
            ],
          ),
          const SizedBox(height: 12),
          if (dest.vaccinsObligatoires.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.assignment, size: 13, color: EpidemiologyTheme.danger),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Obligatoires : ${dest.vaccinsObligatoires.join(', ')}',
                    style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: EpidemiologyTheme.danger, height: 1.4)),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.vaccines_outlined, size: 13, color: EpidemiologyTheme.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(dest.vaccinsRecommandes.join(' · '),
                  style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, color: EpidemiologyTheme.warm600, height: 1.4)),
              ),
            ],
          ),
          if (dest.messageAlerte != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: alertColor.withValues(alpha: 0.10), width: 1),
              ),
              child: Row(
                children: [
                  Icon(alertIcon, size: 12, color: alertColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(dest.messageAlerte!,
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: alertColor, height: 1.3)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTravelAdvisoryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [EpidemiologyTheme.infoLight, EpidemiologyTheme.white],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg),
        border: Border.all(color: EpidemiologyTheme.info.withValues(alpha: 0.08), width: 1),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: EpidemiologyTheme.info.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline, size: 17, color: EpidemiologyTheme.info),
              ),
              const SizedBox(width: 12),
              Text('Conseils aux voyageurs', style: EpidemiologyTheme.subtitle(color: EpidemiologyTheme.warm800)),
            ],
          ),
          const SizedBox(height: 14),
          _advisoryItem(Icons.shield_outlined, 'Vérifier les obligations vaccinales de la destination'),
          _advisoryItem(Icons.medication_outlined, 'Prescrire prophylaxie antipaludéenne si nécessaire'),
          _advisoryItem(Icons.healing_outlined, 'Constituer une trousse médicale de voyage'),
          _advisoryItem(Icons.description_outlined, 'Délivrer le certificat international de vaccination'),
          _advisoryItem(Icons.refresh_outlined, 'Programmer les rappels si schéma vaccinal en plusieurs doses'),
        ],
      ),
    );
  }

  Widget _advisoryItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              color: EpidemiologyTheme.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 13, color: EpidemiologyTheme.info),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: EpidemiologyTheme.warm700, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildCtaBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        border: Border.all(color: EpidemiologyTheme.warm100, width: 1),
        boxShadow: EpidemiologyTheme.shadowMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Nouveau patient'),
                  style: FilledButton.styleFrom(
                    backgroundColor: EpidemiologyTheme.teal,
                    foregroundColor: EpidemiologyTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: const Text('Planning'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EpidemiologyTheme.teal,
                    side: const BorderSide(color: EpidemiologyTheme.teal),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.public, size: 18),
            label: const Text('Fiches pays — Recommandations par destination'),
            style: OutlinedButton.styleFrom(
              foregroundColor: EpidemiologyTheme.warm600,
              side: BorderSide(color: EpidemiologyTheme.warm200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
