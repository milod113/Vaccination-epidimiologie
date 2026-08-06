import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/protocole_vaccinal_model.dart';
import '../../../data/models/tracabilite/lot_vaccin_model.dart';
import '../../../domain/repositories/protocole_repository.dart';
import '../../../../../injection_container.dart' as di;
import 'scanner_lot_screen.dart';

class ValidationDoseScreen extends StatefulWidget {
  final String patientId;
  final DoseModel dose;
  final VoidCallback? onValidated;

  const ValidationDoseScreen({
    super.key,
    required this.patientId,
    required this.dose,
    this.onValidated,
  });

  @override
  State<ValidationDoseScreen> createState() => _ValidationDoseScreenState();
}

class _ValidationDoseScreenState extends State<ValidationDoseScreen> {
  final _lotController = TextEditingController();
  final _expirationController = TextEditingController();
  final _administrateurController = TextEditingController(text: 'Dr. ');
  final _centreController = TextEditingController(text: 'Centre Antirabique');
  final _salleController = TextEditingController();
  final _observationsController = TextEditingController();
  final _effetsController = TextEditingController();

  String _dateReelle = DateTime.now().toIso8601String().split('T')[0];
  bool _saving = false;

  @override
  void dispose() {
    _lotController.dispose();
    _expirationController.dispose();
    _administrateurController.dispose();
    _centreController.dispose();
    _salleController.dispose();
    _observationsController.dispose();
    _effetsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.slate50,
      appBar: AppBar(
        title: Text(
          'Valider dose ${widget.dose.numeroDose}',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: EpidemiologyTheme.slate900,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
        children: [
          _buildDoseInfo(),
          const SizedBox(height: EpidemiologyTheme.spaceXxl),
          _buildSection("Date d'administration", [
            _buildDateField(),
          ]),
          const SizedBox(height: EpidemiologyTheme.spaceXxl),
          _buildSection('Informations du lot', [
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _lotController,
                    label: 'Numéro de lot *',
                    hint: 'Ex: RAB-24A-001',
                    icon: Icons.inventory_2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: IconButton(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    style: IconButton.styleFrom(
                      backgroundColor: EpidemiologyTheme.redLight,
                      foregroundColor: EpidemiologyTheme.redPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            _buildTextField(
              controller: _expirationController,
              label: "Date d'expiration du lot",
              hint: 'AAAA-MM-JJ',
              icon: Icons.date_range,
            ),
          ]),
          const SizedBox(height: EpidemiologyTheme.spaceXxl),
          _buildSection('Administration', [
            _buildTextField(
              controller: _administrateurController,
              label: 'Administrateur *',
              icon: Icons.person,
            ),
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            _buildTextField(
              controller: _centreController,
              label: 'Centre',
              icon: Icons.local_hospital,
            ),
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            _buildTextField(
              controller: _salleController,
              label: 'Salle',
              hint: 'Ex: Consultation 3',
              icon: Icons.meeting_room,
            ),
          ]),
          const SizedBox(height: EpidemiologyTheme.spaceXxl),
          _buildSection('Observations', [
            _buildTextField(
              controller: _observationsController,
              label: 'Observations',
              hint: 'Tolérance, réaction locale...',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: EpidemiologyTheme.spaceMd),
            _buildTextField(
              controller: _effetsController,
              label: 'Effet indésirable immédiat',
              hint: 'Si applicable',
              icon: Icons.warning_amber,
              maxLines: 2,
            ),
          ]),
          const SizedBox(height: EpidemiologyTheme.spaceXxxl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle),
              label: Text(_saving ? 'Enregistrement...' : "Confirmer l'administration"),
              style: FilledButton.styleFrom(
                backgroundColor: EpidemiologyTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: EpidemiologyTheme.spaceMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _saving ? null : _openReportDialog,
              icon: const Icon(Icons.access_time),
              label: const Text('Reporter cette dose'),
              style: OutlinedButton.styleFrom(
                foregroundColor: EpidemiologyTheme.warning,
                side: const BorderSide(color: EpidemiologyTheme.warningLight),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
                textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDoseInfo() {
    return Container(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
      decoration: BoxDecoration(
        gradient: EpidemiologyTheme.softGradient,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl),
        border: Border.all(color: EpidemiologyTheme.slate100),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [EpidemiologyTheme.redMedium, EpidemiologyTheme.redLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd),
              boxShadow: [BoxShadow(color: EpidemiologyTheme.redMedium.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Icon(Icons.vaccines, color: EpidemiologyTheme.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dose ${widget.dose.numeroDose}',
                  style: EpidemiologyTheme.h3(),
                ),
                Text(
                  'Prévue le : ${widget.dose.datePrevue}',
                  style: EpidemiologyTheme.bodySm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: EpidemiologyTheme.label()),
        const SizedBox(height: EpidemiologyTheme.spaceSm),
        ...children,
      ],
    );
  }

  Widget _buildDateField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg),
        border: Border.all(color: EpidemiologyTheme.slate150),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20, color: EpidemiologyTheme.slate400),
          const SizedBox(width: EpidemiologyTheme.spaceMd),
          Text(
            _dateReelle,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: EpidemiologyTheme.slate900),
          ),
          const Spacer(),
          TextButton(
            onPressed: _pickDate,
            child: Text('Modifier', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: EpidemiologyTheme.redPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        hintText: hint,
        labelText: label,
      ),
    );
  }

  Future<void> _openScanner() async {
    final lot = await Navigator.of(context).push<LotVaccinModel>(
      MaterialPageRoute(builder: (_) => const ScannerLotScreen()),
    );
    if (lot != null && mounted) {
      _lotController.text = lot.numeroLot;
      if (lot.dateExpiration.isNotEmpty) {
        _expirationController.text = lot.dateExpiration;
      }
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() {
        _dateReelle = date.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _save() async {
    if (_lotController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Le numéro de lot est obligatoire'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final repo = di.sl<ProtocoleRepository>();
    await repo.validerDose(
      widget.patientId,
      widget.dose.id,
      dateReelle: _dateReelle,
      numeroLot: _lotController.text.trim(),
      dateExpirationLot: _expirationController.text.trim().isNotEmpty ? _expirationController.text.trim() : null,
      administrateurNom: _administrateurController.text.trim(),
      centre: _centreController.text.trim(),
      salle: _salleController.text.trim().isNotEmpty ? _salleController.text.trim() : null,
      observations: _observationsController.text.trim().isNotEmpty ? _observationsController.text.trim() : null,
      effetsIndesirables: _effetsController.text.trim().isNotEmpty ? _effetsController.text.trim() : null,
    );
    widget.onValidated?.call();
    if (mounted) Navigator.of(context).pop();
  }

  void _openReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => _ReportDoseDialog(
        patientId: widget.patientId,
        dose: widget.dose,
        onReported: () {
          widget.onValidated?.call();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _ReportDoseDialog extends StatefulWidget {
  final String patientId;
  final DoseModel dose;
  final VoidCallback onReported;

  const _ReportDoseDialog({
    required this.patientId,
    required this.dose,
    required this.onReported,
  });

  @override
  State<_ReportDoseDialog> createState() => _ReportDoseDialogState();
}

class _ReportDoseDialogState extends State<_ReportDoseDialog> {
  final _motifController = TextEditingController();
  final _dateController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _motifController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusXl)),
      title: Text(
        'Reporter la dose ${widget.dose.numeroDose}',
        style: EpidemiologyTheme.h3(),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _motifController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motif du report *',
              hintText: 'Raison médicale, patient absent...',
            ),
          ),
          const SizedBox(height: EpidemiologyTheme.spaceLg),
          TextField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: 'Nouvelle date (optionnelle)',
              hintText: 'AAAA-MM-JJ',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    _dateController.text = date.toIso8601String().split('T')[0];
                  }
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: EpidemiologyTheme.warning,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
          ),
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Confirmer le report'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_motifController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final repo = di.sl<ProtocoleRepository>();
    await repo.reporterDose(
      widget.patientId,
      widget.dose.id,
      motifReport: _motifController.text.trim(),
      dateNouveauRdv: _dateController.text.trim().isNotEmpty ? _dateController.text.trim() : null,
    );
    widget.onReported();
  }
}
