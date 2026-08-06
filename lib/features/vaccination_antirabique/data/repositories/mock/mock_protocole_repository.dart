import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/protocole_vaccinal_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/patient_antirabique_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/protocole_repository.dart';

class MockProtocoleRepository implements ProtocoleRepository {
  final Map<String, ProtocoleVaccinalModel> _data = {};

  MockProtocoleRepository() {
    _initData();
  }

  void _initData() {
    // ── PAT-001 : Benali Ahmed — Essen 5 doses · J0=20/07 ──
    // J0(fait), J3(fait), J7(27/07=EN RETARD 3j), J14(03/08), J28(17/08)
    _data['PAT-001'] = ProtocoleVaccinalModel(
      patientId: 'PAT-001',
      type: ProtocoleType.essen,
      dateDebut: '2026-07-20',
      rigIndiquee: true,
      rigAdministree: true,
      rigNumeroLot: 'RIG-24A-001',
      rigDateAdministration: '2026-07-20',
      doses: [
        DoseModel(id: 'D-001-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-20', dateReelle: '2026-07-20', statut: DoseStatut.administree, numeroLot: 'RAB-24A-001', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-001-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-23', dateReelle: '2026-07-23', statut: DoseStatut.administree, numeroLot: 'RAB-24A-001', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-001-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-27', statut: DoseStatut.prevue),
        DoseModel(id: 'D-001-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-08-03', statut: DoseStatut.prevue),
        DoseModel(id: 'D-001-5', numeroDose: 5, jourTheorique: 'J28', datePrevue: '2026-08-17', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-002 : Mokhtari Fatima — Zagreb (2-1-1) · J0=15/07 ──
    // J0×2(fait), J7(22/07=fait), J21(05/08=à venir)
    _data['PAT-002'] = ProtocoleVaccinalModel(
      patientId: 'PAT-002',
      type: ProtocoleType.zagreb,
      dateDebut: '2026-07-15',
      rigIndiquee: false,
      doses: [
        DoseModel(id: 'D-002-1', numeroDose: 1, jourTheorique: 'J0', datePrevue: '2026-07-15', dateReelle: '2026-07-15', statut: DoseStatut.administree, numeroLot: 'RAB-24B-002', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique', injectionDouble: true),
        DoseModel(id: 'D-002-2', numeroDose: 2, jourTheorique: 'J0', datePrevue: '2026-07-15', dateReelle: '2026-07-15', statut: DoseStatut.administree, numeroLot: 'RAB-24B-002', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique', injectionDouble: true),
        DoseModel(id: 'D-002-3', numeroDose: 3, jourTheorique: 'J7', datePrevue: '2026-07-22', dateReelle: '2026-07-22', statut: DoseStatut.administree, numeroLot: 'RAB-24B-002', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-002-4', numeroDose: 4, jourTheorique: 'J21', datePrevue: '2026-08-05', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-003 : Ziani Mohamed — Essen 5 doses · J0=10/07 ──
    // J0(fait), J3(fait), J7(fait), J14(24/07=EN RETARD 6j), J28(07/08)
    _data['PAT-003'] = ProtocoleVaccinalModel(
      patientId: 'PAT-003',
      type: ProtocoleType.essen,
      dateDebut: '2026-07-10',
      rigIndiquee: true,
      rigAdministree: true,
      rigNumeroLot: 'RIG-24A-003',
      rigDateAdministration: '2026-07-10',
      doses: [
        DoseModel(id: 'D-003-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-10', dateReelle: '2026-07-10', statut: DoseStatut.administree, numeroLot: 'RAB-24A-003', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-003-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-13', dateReelle: '2026-07-13', statut: DoseStatut.administree, numeroLot: 'RAB-24A-003', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-003-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-17', dateReelle: '2026-07-17', statut: DoseStatut.administree, numeroLot: 'RAB-24A-003', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-003-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-07-24', statut: DoseStatut.prevue),
        DoseModel(id: 'D-003-5', numeroDose: 5, jourTheorique: 'J28', datePrevue: '2026-08-07', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-004 : Belaid Sarra — Essen réduit 4 doses · J0=22/07 ──
    // J0(fait), J3(fait), J7(29/07=EN RETARD 1j), J14(05/08)
    _data['PAT-004'] = ProtocoleVaccinalModel(
      patientId: 'PAT-004',
      type: ProtocoleType.essenReduit,
      dateDebut: '2026-07-22',
      rigIndiquee: false,
      doses: [
        DoseModel(id: 'D-004-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-22', dateReelle: '2026-07-22', statut: DoseStatut.administree, numeroLot: 'RAB-24A-004', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-004-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-25', dateReelle: '2026-07-25', statut: DoseStatut.administree, numeroLot: 'RAB-24A-004', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-004-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-29', statut: DoseStatut.prevue),
        DoseModel(id: 'D-004-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-08-05', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-005 : Hammouchi Rachid — Zagreb (2-1-1) · J0=05/07 ──
    // J0×2(fait), J7(fait), J21(26/07=EN RETARD 4j)
    _data['PAT-005'] = ProtocoleVaccinalModel(
      patientId: 'PAT-005',
      type: ProtocoleType.zagreb,
      dateDebut: '2026-07-05',
      rigIndiquee: true,
      rigAdministree: true,
      rigNumeroLot: 'RIG-24B-005',
      rigDateAdministration: '2026-07-05',
      doses: [
        DoseModel(id: 'D-005-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-05', dateReelle: '2026-07-05', statut: DoseStatut.administree, numeroLot: 'RAB-24B-005', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique', injectionDouble: true),
        DoseModel(id: 'D-005-2', numeroDose: 2, jourTheorique: 'J0',  datePrevue: '2026-07-05', dateReelle: '2026-07-05', statut: DoseStatut.administree, numeroLot: 'RAB-24B-005', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique', injectionDouble: true),
        DoseModel(id: 'D-005-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-12', dateReelle: '2026-07-12', statut: DoseStatut.administree, numeroLot: 'RAB-24B-005', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-005-4', numeroDose: 4, jourTheorique: 'J21', datePrevue: '2026-07-26', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-006 : Khelifi Amira — Essen réduit 4 doses (TERMINÉ) · J0=28/06 ──
    _data['PAT-006'] = ProtocoleVaccinalModel(
      patientId: 'PAT-006',
      type: ProtocoleType.essenReduit,
      dateDebut: '2026-06-28',
      rigIndiquee: false,
      doses: [
        DoseModel(id: 'D-006-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-06-28', dateReelle: '2026-06-28', statut: DoseStatut.administree, numeroLot: 'RAB-24A-006', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-006-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-01', dateReelle: '2026-07-01', statut: DoseStatut.administree, numeroLot: 'RAB-24A-006', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-006-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-05', dateReelle: '2026-07-05', statut: DoseStatut.administree, numeroLot: 'RAB-24A-006', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-006-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-07-12', dateReelle: '2026-07-12', statut: DoseStatut.administree, numeroLot: 'RAB-24A-006', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
      ],
    );

    // ── PAT-007 : Guedjati Youcef — Essen 5 doses (immunodéprimé) · J0=18/07 ──
    // J0(fait), J3(21/07=REPORTÉE), J7(25/07=EN RETARD 5j), J14(01/08), J28(15/08)
    _data['PAT-007'] = ProtocoleVaccinalModel(
      patientId: 'PAT-007',
      type: ProtocoleType.essen,
      dateDebut: '2026-07-18',
      rigIndiquee: true,
      rigAdministree: true,
      rigNumeroLot: 'RIG-24A-007',
      rigDateAdministration: '2026-07-18',
      doses: [
        DoseModel(id: 'D-007-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-18', dateReelle: '2026-07-18', statut: DoseStatut.administree, numeroLot: 'RAB-24A-007', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-007-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-21', statut: DoseStatut.reportee, motifReport: 'Patient sous AVK — INR à vérifier avant administration'),
        DoseModel(id: 'D-007-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-25', statut: DoseStatut.prevue),
        DoseModel(id: 'D-007-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-08-01', statut: DoseStatut.prevue),
        DoseModel(id: 'D-007-5', numeroDose: 5, jourTheorique: 'J28', datePrevue: '2026-08-15', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-008 : Bouzid Nadia — Zagreb (2-1-1) · J0=25/07 ──
    // J0×2(fait), J7(01/08=à venir), J21(15/08=à venir)
    _data['PAT-008'] = ProtocoleVaccinalModel(
      patientId: 'PAT-008',
      type: ProtocoleType.zagreb,
      dateDebut: '2026-07-25',
      rigIndiquee: false,
      doses: [
        DoseModel(id: 'D-008-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-25', dateReelle: '2026-07-25', statut: DoseStatut.administree, numeroLot: 'RAB-24B-008', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique', injectionDouble: true),
        DoseModel(id: 'D-008-2', numeroDose: 2, jourTheorique: 'J0',  datePrevue: '2026-07-25', dateReelle: '2026-07-25', statut: DoseStatut.administree, numeroLot: 'RAB-24B-008', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique', injectionDouble: true),
        DoseModel(id: 'D-008-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-08-01', statut: DoseStatut.prevue),
        DoseModel(id: 'D-008-4', numeroDose: 4, jourTheorique: 'J21', datePrevue: '2026-08-15', statut: DoseStatut.prevue),
      ],
    );

    // ── PAT-009 : Messaoudi Khaled — Essen 5 doses (perdu de vue) · J0=12/07 ──
    _data['PAT-009'] = ProtocoleVaccinalModel(
      patientId: 'PAT-009',
      type: ProtocoleType.essen,
      dateDebut: '2026-07-12',
      rigIndiquee: true,
      rigAdministree: true,
      rigNumeroLot: 'RIG-24A-009',
      rigDateAdministration: '2026-07-12',
      doses: [
        DoseModel(id: 'D-009-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-12', dateReelle: '2026-07-12', statut: DoseStatut.administree, numeroLot: 'RAB-24A-009', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-009-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-15', statut: DoseStatut.nonEffectuee, motifReport: 'Patient non présenté — alerte envoyée'),
        DoseModel(id: 'D-009-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-07-19', statut: DoseStatut.nonEffectuee, motifReport: 'Patient non présenté — 2e relance'),
        DoseModel(id: 'D-009-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-07-26', statut: DoseStatut.nonEffectuee),
        DoseModel(id: 'D-009-5', numeroDose: 5, jourTheorique: 'J28', datePrevue: '2026-08-09', statut: DoseStatut.nonEffectuee),
      ],
    );

    // ── PAT-010 : Cherifi Ines — IPC intradermique · J0=08/07 ──
    _data['PAT-010'] = ProtocoleVaccinalModel(
      patientId: 'PAT-010',
      type: ProtocoleType.ipc,
      dateDebut: '2026-07-08',
      rigIndiquee: false,
      doses: [
        DoseModel(id: 'D-010-1', numeroDose: 1, jourTheorique: 'J0', datePrevue: '2026-07-08', dateReelle: '2026-07-08', statut: DoseStatut.administree, numeroLot: 'RAB-24C-010', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique', voieAdministration: 'ID'),
        DoseModel(id: 'D-010-2', numeroDose: 2, jourTheorique: 'J0', datePrevue: '2026-07-08', dateReelle: '2026-07-08', statut: DoseStatut.administree, numeroLot: 'RAB-24C-010', administrateurNom: 'Dr. Bensaid', centre: 'Centre Antirabique', voieAdministration: 'ID'),
        DoseModel(id: 'D-010-3', numeroDose: 3, jourTheorique: 'J3', datePrevue: '2026-07-11', dateReelle: '2026-07-11', statut: DoseStatut.administree, numeroLot: 'RAB-24C-010', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique', voieAdministration: 'ID'),
        DoseModel(id: 'D-010-4', numeroDose: 4, jourTheorique: 'J3', datePrevue: '2026-07-11', dateReelle: '2026-07-11', statut: DoseStatut.administree, numeroLot: 'RAB-24C-010', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique', voieAdministration: 'ID'),
        DoseModel(id: 'D-010-5', numeroDose: 5, jourTheorique: 'J7', datePrevue: '2026-07-15', statut: DoseStatut.prevue, voieAdministration: 'ID'),
        DoseModel(id: 'D-010-6', numeroDose: 6, jourTheorique: 'J7', datePrevue: '2026-07-15', statut: DoseStatut.prevue, voieAdministration: 'ID'),
      ],
    );

    // ── PAT-011 : Kadi Amel — Essen réduit · J0=27/07 → J3 AUJOURD'HUI 30/07 ──
    // J0(fait 27/07), J3(AUJOURD'HUI 30/07), J7(03/08), J14(10/08)
    _data['PAT-011'] = ProtocoleVaccinalModel(
      patientId: 'PAT-011',
      type: ProtocoleType.essenReduit,
      dateDebut: '2026-07-27',
      rigIndiquee: true,
      rigAdministree: false,
      doses: [
        DoseModel(id: 'D-011-1', numeroDose: 1, jourTheorique: 'J0',  datePrevue: '2026-07-27', dateReelle: '2026-07-27', statut: DoseStatut.administree, numeroLot: 'RAB-24A-011', administrateurNom: 'Dr. Mansouri', centre: 'Centre Antirabique'),
        DoseModel(id: 'D-011-2', numeroDose: 2, jourTheorique: 'J3',  datePrevue: '2026-07-30', statut: DoseStatut.prevue),
        DoseModel(id: 'D-011-3', numeroDose: 3, jourTheorique: 'J7',  datePrevue: '2026-08-03', statut: DoseStatut.prevue),
        DoseModel(id: 'D-011-4', numeroDose: 4, jourTheorique: 'J14', datePrevue: '2026-08-10', statut: DoseStatut.prevue),
      ],
    );
  }

  @override
  Future<ProtocoleVaccinalModel> getProtocole(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _data[patientId] ?? _data.values.first;
  }

  @override
  Future<void> validerDose(String patientId, String doseId, {
    required String dateReelle,
    required String numeroLot,
    String? dateExpirationLot,
    String? administrateurNom,
    String? centre,
    String? salle,
    String? observations,
    String? effetsIndesirables,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final protocole = _data[patientId];
    if (protocole == null) return;
    final doses = protocole.doses.map((d) {
      if (d.id == doseId) {
        return d.copyWith(
          statut: DoseStatut.administree,
          dateReelle: dateReelle,
          numeroLot: numeroLot,
          dateExpirationLot: dateExpirationLot,
          administrateurNom: administrateurNom,
          centre: centre,
          salle: salle,
          observations: observations,
          effetsIndesirables: effetsIndesirables,
        );
      }
      return d;
    }).toList();
    _data[patientId] = ProtocoleVaccinalModel(
      patientId: patientId,
      type: protocole.type,
      dateDebut: protocole.dateDebut,
      doses: doses,
      rigIndiquee: protocole.rigIndiquee,
      rigAdministree: protocole.rigAdministree,
      rigNumeroLot: protocole.rigNumeroLot,
      rigDateAdministration: protocole.rigDateAdministration,
    );
  }

  @override
  Future<void> reporterDose(String patientId, String doseId, {
    required String motifReport,
    String? dateNouveauRdv,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final protocole = _data[patientId];
    if (protocole == null) return;
    final doses = protocole.doses.map((d) {
      if (d.id == doseId) {
        return d.copyWith(
          statut: DoseStatut.reportee,
          motifReport: motifReport,
          datePrevue: dateNouveauRdv ?? d.datePrevue,
        );
      }
      return d;
    }).toList();
    _data[patientId] = ProtocoleVaccinalModel(
      patientId: patientId,
      type: protocole.type,
      dateDebut: protocole.dateDebut,
      doses: doses,
      rigIndiquee: protocole.rigIndiquee,
      rigAdministree: protocole.rigAdministree,
      rigNumeroLot: protocole.rigNumeroLot,
      rigDateAdministration: protocole.rigDateAdministration,
    );
  }
}
