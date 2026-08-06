import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/epidemiology_theme.dart';
import '../../../data/models/suivi_clinique_model.dart';
import '../../../domain/repositories/suivi_clinique_repository.dart';
import '../../../../../injection_container.dart' as di;
import '../../widgets/follow_up_note_card.dart';

class SuiviCliniqueTab extends StatefulWidget {
  final String patientId;

  const SuiviCliniqueTab({super.key, required this.patientId});

  @override
  State<SuiviCliniqueTab> createState() => _SuiviCliniqueTabState();
}

class _SuiviCliniqueTabState extends State<SuiviCliniqueTab> {
  List<SuiviCliniqueModel>? _notes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final repo = di.sl<SuiviCliniqueRepository>();
    final notes = await repo.getSuiviClinique(widget.patientId);
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return _notes == null || _notes!.isEmpty ? _buildEmpty() : _buildList();
  }

  Widget _buildEmpty() {
    return EpidemiologyTheme.emptyState(
      Icons.note_alt_outlined,
      'Aucune note de suivi',
      subtitle: 'Ajoutez une note pour commencer le suivi clinique',
      action: FilledButton.icon(
        onPressed: _openAddNote,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une note'),
        style: FilledButton.styleFrom(
          backgroundColor: EpidemiologyTheme.redPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView(
      padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
      children: [
        EpidemiologyTheme.sectionHeader(
          'Suivi clinique (${_notes!.length})',
          icon: Icons.assignment,
          trailing: FilledButton.icon(
            onPressed: _openAddNote,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Ajouter'),
            style: FilledButton.styleFrom(
              backgroundColor: EpidemiologyTheme.redPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusMd)),
            ),
          ),
        ),
        const SizedBox(height: EpidemiologyTheme.spaceLg),
        ..._notes!.map((note) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FollowUpNoteCard(note: note),
        )),
        const SizedBox(height: 40),
      ],
    );
  }

  void _openAddNote() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddNoteSheet(
        patientId: widget.patientId,
        onAdded: () {
          _loadNotes();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _AddNoteSheet extends StatefulWidget {
  final String patientId;
  final VoidCallback onAdded;

  const _AddNoteSheet({required this.patientId, required this.onAdded});

  @override
  State<_AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<_AddNoteSheet> {
  final _noteController = TextEditingController();
  final _effetController = TextEditingController();
  EffetIndesirableType _effetType = EffetIndesirableType.aucun;
  bool _doseReportee = false;
  final _motifReportController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    _effetController.dispose();
    _motifReportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(EpidemiologyTheme.radiusXxl)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
            decoration: BoxDecoration(
              color: EpidemiologyTheme.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(EpidemiologyTheme.radiusXxl)),
              boxShadow: [BoxShadow(color: EpidemiologyTheme.blackWith(0.04), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: EpidemiologyTheme.slate200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nouvelle note de suivi',
                  style: EpidemiologyTheme.h3(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
              children: [
                Text('Note clinique', style: EpidemiologyTheme.label()),
                const SizedBox(height: EpidemiologyTheme.spaceSm),
                TextField(
                  controller: _noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: 'Observation, remarque...'),
                ),
                const SizedBox(height: EpidemiologyTheme.spaceXxl),
                Text('Effet indésirable', style: EpidemiologyTheme.label()),
                const SizedBox(height: EpidemiologyTheme.spaceSm),
                DropdownButtonFormField<EffetIndesirableType>(
                  initialValue: _effetType,
                  items: EffetIndesirableType.values.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.label, style: GoogleFonts.inter(fontSize: 14)),
                  )).toList(),
                  onChanged: (v) => setState(() => _effetType = v!),
                  decoration: const InputDecoration(
                    hintText: 'Sélectionner un type',
                  ),
                ),
                if (_effetType != EffetIndesirableType.aucun) ...[
                  const SizedBox(height: EpidemiologyTheme.spaceMd),
                  TextField(
                    controller: _effetController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: "Décrire l'effet..."),
                  ),
                ],
                const SizedBox(height: EpidemiologyTheme.spaceXxl),
                SwitchListTile(
                  title: Text('Dose reportée', style: EpidemiologyTheme.label()),
                  subtitle: _doseReportee ? Text('Motif à préciser', style: EpidemiologyTheme.bodySm()) : null,
                  value: _doseReportee,
                  activeThumbColor: EpidemiologyTheme.redPrimary,
                  onChanged: (v) => setState(() => _doseReportee = v),
                ),
                if (_doseReportee) ...[
                  const SizedBox(height: EpidemiologyTheme.spaceSm),
                  TextField(
                    controller: _motifReportController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Motif du report...'),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(EpidemiologyTheme.spaceXl),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: EpidemiologyTheme.redPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EpidemiologyTheme.radiusLg)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Enregistrer la note'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_noteController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final repo = di.sl<SuiviCliniqueRepository>();
    final note = SuiviCliniqueModel(
      id: 'SC-${DateTime.now().millisecondsSinceEpoch}',
      patientId: widget.patientId,
      date: DateTime.now().toIso8601String().split('T')[0],
      auteur: 'Dr. Utilisateur',
      note: _noteController.text.trim(),
      effetIndesirable: _effetType,
      descriptionEffet: _effetController.text.trim().isNotEmpty ? _effetController.text.trim() : null,
      doseReportee: _doseReportee,
      motifReport: _motifReportController.text.trim().isNotEmpty ? _motifReportController.text.trim() : null,
    );
    await repo.ajouterNote(note);
    widget.onAdded();
  }
}
