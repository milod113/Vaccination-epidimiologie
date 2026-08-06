import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/epidemiology_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/patient_antirabique_model.dart';
import '../../domain/repositories/patient_antirabique_repository.dart';
import '../widgets/j0_creation/j0_creation_fields.dart';
import '../widgets/j0_wizard/j0_section_title.dart';
import '../widgets/j0_wizard/j0_ui.dart';
import 'evaluation_initiale_screen.dart';

/// Admission d'un nouveau patient au Centre Antirabique.
///
/// Écran premium structuré en sections (Identité, Coordonnées, Adresse,
/// Contexte d'admission, Préparation J0). Deux actions finales :
/// « Créer le patient » seul, ou « Créer et continuer vers J0 » qui
/// enchaîne directement sur l'évaluation initiale pré-remplie.
class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  // ── Identité ─────────────────────────────────────────────────────
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _ageController = TextEditingController();
  final _poidsController = TextEditingController();
  String _sexe = 'Masculin';

  // ── Coordonnées ──────────────────────────────────────────────────
  final _telephoneController = TextEditingController();

  // ── Adresse ──────────────────────────────────────────────────────
  final _adresseController = TextEditingController();
  final _communeController = TextEditingController();
  final _dairaController = TextEditingController();
  final _wilayaController = TextEditingController();

  // ── Admission ────────────────────────────────────────────────────
  String _dateAdmission = DateTime.now().toIso8601String().split('T').first;
  String? _heureAdmission;
  String _modeArrivee = 'Venu directement';
  final _structureController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    _poidsController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _communeController.dispose();
    _dairaController.dispose();
    _wilayaController.dispose();
    _structureController.dispose();
    super.dispose();
  }

  String? _text(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  // ── Sauvegarde ───────────────────────────────────────────────────
  Future<void> _save({required bool continueVersJ0}) async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (nom.isEmpty) {
      _showError('Veuillez renseigner le nom du patient.');
      return;
    }
    if (age == null || age <= 0) {
      _showError("Veuillez renseigner un âge valide (années).");
      return;
    }

    final nomComplet = prenom.isEmpty ? nom : '$prenom $nom';
    final mode = _modeArrivee;
    final structure = mode == 'Orienté par structure'
        ? _text(_structureController)
        : null;

    final patient = PatientAntirabiqueModel(
      id: '',
      nomComplet: nomComplet,
      prenom: prenom.isEmpty ? null : prenom,
      age: age,
      sexe: _sexe,
      poids: double.tryParse(_poidsController.text.trim()),
      telephone: _text(_telephoneController),
      dateExposition: _dateAdmission,
      statut: StatutSuivi.enCours,
      adresse: _text(_adresseController),
      commune: _text(_communeController),
      daira: _text(_dairaController),
      wilaya: _text(_wilayaController),
      dateAdmission: _dateAdmission,
      heureAdmission: _heureAdmission,
      modeArrivee: mode,
      structureOrientation: structure,
      dateCreation: _dateAdmission,
    );

    setState(() => _saving = true);
    try {
      final repo = di.sl<PatientAntirabiqueRepository>();
      final created = await repo.createPatient(patient);
      if (!mounted) return;

      if (continueVersJ0) {
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => EvaluationInitialeScreen(patientId: created.id),
          ),
        );
        if (!mounted) return;
      }
      Navigator.of(context).pop(created);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError("Impossible d'enregistrer le patient. Réessayez.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: EpidemiologyTheme.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EpidemiologyTheme.warm50,
      appBar: AppBar(
        backgroundColor: EpidemiologyTheme.redPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Admission d\'un nouveau patient',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: EpidemiologyTheme.surfaceGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _section(
              icon: Icons.badge_outlined,
              title: 'Identité',
              children: [
                J0TextField(
                  label: 'Nom *',
                  hint: 'Ex. Benali',
                  controller: _nomController,
                  prefixIcon: Icons.person_outline,
                ),
                J0TextField(
                  label: 'Prénom',
                  hint: 'Ex. Ahmed',
                  controller: _prenomController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: J0TextField(
                        label: 'Âge (années) *',
                        hint: 'Ex. 34',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.cake_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: J0TextField(
                        label: 'Poids (kg)',
                        hint: 'Ex. 70',
                        controller: _poidsController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: Icons.monitor_weight_outlined,
                      ),
                    ),
                  ],
                ),
                J0SectionTitle('Sexe', icon: Icons.wc_outlined),
                J0ChoicePills<String>(
                  options: const [
                    J0ChoiceOption('Masculin', 'Masculin'),
                    J0ChoiceOption('Féminin', 'Féminin'),
                  ],
                  selected: _sexe,
                  onChanged: (v) => setState(() => _sexe = v),
                ),
              ],
            ),
            _section(
              icon: Icons.phone_outlined,
              title: 'Coordonnées',
              children: [
                J0TextField(
                  label: 'Téléphone',
                  hint: 'Ex. 0550 12 34 56',
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
              ],
            ),
            _section(
              icon: Icons.home_outlined,
              title: 'Adresse de résidence',
              children: [
                J0TextField(
                  label: 'Adresse',
                  hint: 'Ex. 12 rue des Frères',
                  controller: _adresseController,
                  prefixIcon: Icons.home_outlined,
                ),
                Row(
                  children: [
                    Expanded(
                      child: J0TextField(
                        label: 'Commune',
                        hint: 'Ex. Bab Ezzouar',
                        controller: _communeController,
                        prefixIcon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: J0TextField(
                        label: 'Daïra',
                        hint: 'Ex. Dar El Beida',
                        controller: _dairaController,
                      ),
                    ),
                  ],
                ),
                J0TextField(
                  label: 'Wilaya',
                  hint: 'Ex. Alger (16)',
                  controller: _wilayaController,
                  prefixIcon: Icons.map_outlined,
                ),
              ],
            ),
            _section(
              icon: Icons.login_outlined,
              title: "Contexte d'admission",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: J0DateField(
                        label: "Date d'admission",
                        value: _dateAdmission,
                        onPicked: (d) => setState(() {
                          _dateAdmission = d.toIso8601String().split('T').first;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: J0TimeField(
                        label: "Heure d'arrivée",
                        value: _heureAdmission,
                        onPicked: (t) => setState(() {
                          _heureAdmission =
                              '${t.hour.toString().padLeft(2, '0')}:'
                              '${t.minute.toString().padLeft(2, '0')}';
                        }),
                      ),
                    ),
                  ],
                ),
                J0SectionTitle('Mode d\'arrivée', icon: Icons.directions_bus_outlined),
                J0ChoicePills<String>(
                  options: const [
                    J0ChoiceOption('Venu directement', 'Venu directement'),
                    J0ChoiceOption('Orienté par structure', 'Orienté par structure'),
                  ],
                  selected: _modeArrivee,
                  onChanged: (v) => setState(() => _modeArrivee = v),
                ),
                if (_modeArrivee == 'Orienté par structure') ...[
                  const SizedBox(height: 8),
                  J0TextField(
                    label: 'Structure d\'orientation',
                    hint: 'Ex. Polyclinique Bouzareah',
                    controller: _structureController,
                    prefixIcon: Icons.local_hospital_outlined,
                  ),
                ],
              ],
            ),
            _section(
              icon: Icons.vaccines_outlined,
              title: 'Préparation J0',
              children: [
                J0Note(
                  icon: Icons.info_outline,
                  title: 'Évaluation initiale à réaliser',
                  message:
                      "Le patient sera en attente d'évaluation (catégorie non définie). "
                      "En choisissant « Créer et continuer vers J0 », les données "
                      "d'admission et d'adresse seront pré-remplies dans la fiche "
                      "d'évaluation initiale.",
                  color: EpidemiologyTheme.redPrimary,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: EpidemiologyTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          J0SectionTitle(title, icon: icon, padding: const EdgeInsets.only(bottom: 14)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: EpidemiologyTheme.white,
        boxShadow: [BoxShadow(color: EpidemiologyTheme.blackWith(0.06), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _saving ? null : () => _save(continueVersJ0: false),
              style: OutlinedButton.styleFrom(
                foregroundColor: EpidemiologyTheme.redPrimary,
                side: const BorderSide(color: EpidemiologyTheme.redPrimary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: J0Ui.text(size: 14, weight: FontWeight.w700),
              ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Créer le patient'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : () => _save(continueVersJ0: true),
                style: FilledButton.styleFrom(
                  backgroundColor: EpidemiologyTheme.redPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: J0Ui.text(size: 14, weight: FontWeight.w700),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Créer et continuer vers J0'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
