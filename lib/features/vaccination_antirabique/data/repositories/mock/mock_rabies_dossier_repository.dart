import '../../../domain/models/dossier/admission.dart';
import '../../../domain/models/dossier/animal.dart';
import '../../../domain/models/dossier/clinical_care.dart';
import '../../../domain/models/dossier/dossier_enums.dart';
import '../../../domain/models/dossier/exposure.dart';
import '../../../domain/models/dossier/follow_up.dart';
import '../../../domain/models/dossier/patient_identity.dart';
import '../../../domain/models/dossier/rabies_case_record.dart';
import '../../../domain/models/dossier/traceability.dart';
import '../../../domain/models/dossier/vaccination.dart';
import '../../../domain/repositories/rabies_dossier_repository.dart';
import 'mock_rabies_history_factory.dart';

/// Mock data du dossier antirabique algérien.
///
/// Les dates sont calculées relativement à aujourd'hui pour rester cohérentes
/// avec les règles métier (temps réel de retard / prochaine dose).
class MockRabiesDossierRepository implements RabiesDossierRepository {
  final _now = DateTime.now();
  List<RabiesCaseRecord>? _cache;

  DateTime _j(int offset) => DateTime(_now.year, _now.month, _now.day)
      .add(Duration(days: offset));

  /// Construit un set de doses à partir d'une liste de jours théoriques.
  ///
  /// `realise` et `enRetard` désignent des indices de doses ; toute dose non
  /// réalisée ni en retard est prévue.
  List<VaccineDose> _doses(
    List<String> jours, {
    List<int> realise = const [],
    List<int> enRetard = const [],
  }) {
    return List.generate(jours.length, (i) {
      final realisee = realise.contains(i);
      return VaccineDose(
        numero: i + 1,
        jourTheorique: jours[i],
        datePrevue: _j(i == 0 ? 0 : _offsetJours(jours[i])),
        dateReelle: realisee ? _j(_offsetJours(jours[i])) : null,
        statut: realisee
            ? DoseStatus.realisee
            : enRetard.contains(i)
                ? DoseStatus.enRetard
                : DoseStatus.prevue,
        voie: AdministrationRoute.intramusculaire,
      );
    });
  }

  int _offsetJours(String jour) {
    final digits = jour.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  List<RabiesCaseRecord> get _seedRecords => [
        // ── Cas 1 : Catégorie I — simple contact, aucun protocole ──────────
        RabiesCaseRecord(
          id: 'RAB-001',
          numeroDossier: 'UAR-2026-0142',
          identity: const PatientIdentity(
            nom: 'Aouali',
            prenom: 'Yasmine',
            age: 24,
            sexe: PatientGender.feminin,
            poidsKg: 58,
            telephone: '0550 12 34 56',
            profession: 'Étudiante',
            niveauInstruction: InstructionLevel.superieur,
            residence: Residence(
              commune: 'Alger Centre',
              daira: 'Sidi M\'hamed',
              wilaya: 'Alger',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(0)),
          exposition: const ExposureDetails(
            heureExposition: '15:30',
            lieu: ExposurePlace.domicile,
            peauNue: true,
            nature: ExposureNature.contact,
            saignement: BleedingStatus.non,
            nombreLesions: LesionCountType.nonPrecise,
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieI,
            justification: 'Contact, peau intacte — aucune vaccination requise.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chat,
            statut: AnimalStatus.proprietaire,
            comportement: AnimalBehavior.normal,
            vaccination: AnimalVaccinationStatus.ouiDocumentee,
          ),
        ),

        // ── Cas 2 : Catégorie II — griffure sans saignement, Zagreb ────────
        RabiesCaseRecord(
          id: 'RAB-002',
          numeroDossier: 'UAR-2026-0145',
          identity: const PatientIdentity(
            nom: 'Bensalem',
            prenom: 'Karim',
            age: 38,
            sexe: PatientGender.masculin,
            poidsKg: 74,
            telephone: '0551 22 33 44',
            profession: 'Enseignant',
            niveauInstruction: InstructionLevel.superieur,
            residence: Residence(
              adresse: 'Cité des oiseaux, Bt 12',
              commune: 'Bab Ezzouar',
              daira: 'Dar El Beida',
              wilaya: 'Alger',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(-1)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '09:10',
            lieu: ExposurePlace.horsDomicile,
            nature: ExposureNature.griffure,
            saignement: BleedingStatus.non,
            nombreLesions: LesionCountType.multiples,
            siegeLesions: [LesionSite.membreSuperieur],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieII,
            justification: 'Griffures superficielles sans saignement.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chat,
            statut: AnimalStatus.semiErrant,
            comportement: AnimalBehavior.suspect,
            observationVeterinaire: ObservationStatus.oui,
            sort: AnimalOutcome.vivantSousSurveillance,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.zagreb,
              dateDebut: _j(0),
              // J0 réalisées (2 sites), J7 prévue.
              doses: _doses(
                ['J0', 'J0', 'J7', 'J21'],
                realise: [0, 1],
              ),
              complete: false,
            ),
          ),
        ),

        // ── Cas 3 : Catégorie III + ERIG + protocole Essen ─────────────────
        RabiesCaseRecord(
          id: 'RAB-003',
          numeroDossier: 'UAR-2026-0151',
          identity: const PatientIdentity(
            nom: 'Meziane',
            prenom: 'Sofiane',
            age: 41,
            sexe: PatientGender.masculin,
            poidsKg: 82,
            telephone: '0552 44 55 66',
            profession: 'Agriculteur',
            niveauInstruction: InstructionLevel.moyen,
            residence: Residence(
              commune: 'Boufarik',
              daira: 'Boufarik',
              wilaya: 'Blida',
            ),
          ),
          admission: ArrivalInfo(
            dateArriveeUar: _j(0),
            modeArrivee: ArrivalMode.orienteParStructure,
            structureOrientation: 'Polyclinique Boufarik',
          ),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '18:45',
            lieu: ExposurePlace.domicile,
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.multiples,
            siegeLesions: [LesionSite.membreInferieur, LesionSite.pied],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification:
                'Morsure transdermique avec saignement — erig + vaccin.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.errant,
            comportement: AnimalBehavior.suspect,
            vaccination: AnimalVaccinationStatus.non,
            sort: AnimalOutcome.enFuite,
          ),
          soinsLocaux: const LocalCareInfo(
            realise: LocalCarePerformed.oui,
            methodes: [LocalCareMethod.lavageEauSavon],
            produitsAppliques: 'Antiseptique iodé',
          ),
          erig: const ErigInfo(
            indiquee: true,
            administree: true,
            numeroLot: 'ERIG-2201',
            titreIUMl: 200,
            poidsPatientKg: 82,
            doseTotaleTheoriqueIU: 1640,
            doseTotaleTheoriqueMl: 8.2,
            voies: [
              ErigRoute.infiltrationLesionnelle,
              ErigRoute.injectionIntramusculaire,
            ],
            nombreLesionsInfiltrees: 3,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.essen,
              dateDebut: _j(0),
              // J0 réalisée, autres doses prévues.
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'], realise: [0]),
              complete: false,
            ),
          ),
        ),

        // ── Cas 4 : Catégorie III + ERIG + Zagreb + MPVI ───────────────────
        RabiesCaseRecord(
          id: 'RAB-004',
          numeroDossier: 'UAR-2026-0160',
          identity: const PatientIdentity(
            nom: 'Cherif',
            prenom: 'Amira',
            age: 29,
            sexe: PatientGender.feminin,
            poidsKg: 61,
            telephone: '0553 66 77 88',
            profession: 'Infirmière',
            niveauInstruction: InstructionLevel.superieur,
            residence: Residence(
              commune: 'El Harrach',
              daira: 'Hussein Dey',
              wilaya: 'Alger',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(0)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '07:20',
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.unique,
            siegeLesions: [LesionSite.main],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification: 'Morsure de la main avec saignement.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.semiErrant,
            comportement: AnimalBehavior.normal,
            vaccination: AnimalVaccinationStatus.ouiNonDocumentee,
            sort: AnimalOutcome.vivantSousSurveillance,
            observationVeterinaire: ObservationStatus.oui,
          ),
          erig: const ErigInfo(
            indiquee: true,
            administree: true,
            numeroLot: 'ERIG-2204',
            titreIUMl: 200,
            poidsPatientKg: 61,
            doseTotaleTheoriqueIU: 1220,
            doseTotaleTheoriqueMl: 6.1,
            voies: [ErigRoute.infiltrationLesionnelle],
            nombreLesionsInfiltrees: 2,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.zagreb,
              dateDebut: _j(0),
              // J0 (×2) réalisées, J7 réalisée, J21 prévue.
              doses: _doses(['J0', 'J0', 'J7', 'J21'], realise: [0, 1, 2]),
              complete: false,
            ),
          ),
          mpvi: const MpviInfo(
            present: true,
            dateApparition: null,
            manifestations: 'Érythème local + céphalées légères',
            gravite: MpviSeverity.benigne,
            mesuresPrises: 'Paracétamol, surveillance.',
            declarationPharmacovigilance: true,
          ),
        ),

        // ── Cas 5 : Catégorie II + vaccin tissulaire grade II + retard ────
        RabiesCaseRecord(
          id: 'RAB-005',
          numeroDossier: 'UAR-2026-0163',
          identity: const PatientIdentity(
            nom: 'Hadji',
            prenom: 'Nassim',
            age: 52,
            sexe: PatientGender.masculin,
            poidsKg: 78,
            telephone: '0554 77 88 99',
            profession: 'Artisan',
            niveauInstruction: InstructionLevel.primaire,
            residence: Residence(
              commune: 'Oued Smar',
              daira: 'Dar El Beida',
              wilaya: 'Alger',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(-1)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '11:00',
            nature: ExposureNature.lechagePeauLestee,
            saignement: BleedingStatus.non,
            nombreLesions: LesionCountType.unique,
            siegeLesions: [LesionSite.membreSuperieur],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieII,
            methode: RiskAssessmentMethod.manuelle,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.errant,
            comportement: AnimalBehavior.normal,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinTissulaire,
            dci: 'Vaccin antirabique, tissu nerveux',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.vaccinTissulaireGradeII,
              dateDebut: _j(0),
              // J0 réalisée ; J3 et J7 en retard.
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'],
                  realise: [0], enRetard: [1, 2]),
              complete: false,
            ),
          ),
          antibiotiques: const AntibioticInfo(
            prescription: AntibioticPrescription.oui,
            molecule: 'Amoxicilline',
            dose: '1 g / 12h',
            duree: '7 jours',
            motif: 'Prévention de l\'infection de plaie',
          ),
        ),

        // ── Cas 6 : Catégorie III + ERIG incluse, profil métier à risque ─
        RabiesCaseRecord(
          id: 'RAB-006',
          numeroDossier: 'UAR-2026-0171',
          identity: const PatientIdentity(
            nom: 'Zegrar',
            prenom: 'Lamine',
            age: 57,
            sexe: PatientGender.masculin,
            telephone: '0556 90 12 34',
            profession: 'Éleveur',
            residence: Residence(
              commune: 'Khemis Miliana',
              daira: 'Khemis Miliana',
              wilaya: 'Aïn Defla',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(-2)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '16:05',
            lieu: ExposurePlace.horsDomicile,
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.multiples,
            siegeLesions: [LesionSite.face, LesionSite.cou],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification:
                'Morsures de la face et du cou — ERIG obligatoire.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.proprietaire,
            comportement: AnimalBehavior.suspect,
            vaccination: AnimalVaccinationStatus.non,
            observationVeterinaire: ObservationStatus.oui,
            sort: AnimalOutcome.vivantSousSurveillance,
            resultatObservation: ObservationResult.nonEnrage,
          ),
          soinsLocaux: const LocalCareInfo(
            realise: LocalCarePerformed.oui,
            methodes: [LocalCareMethod.lavageEau, LocalCareMethod.lavageEauSavon],
          ),
          chirurgie: const SurgeryInfo(
            realise: SurgeryPerformed.oui,
            hopital: 'CHU Aïn Defla',
            service: 'Chirurgie Générale',
            suture: SutureTiming.avantInfiltrationErig,
          ),
          erig: const ErigInfo(
            indiquee: true,
            administree: true,
            numeroLot: 'ERIG-2207',
            titreIUMl: 200,
            poidsPatientKg: 88,
            doseTotaleTheoriqueIU: 1760,
            doseTotaleTheoriqueMl: 8.8,
            voies: [
              ErigRoute.infiltrationLesionnelle,
              ErigRoute.infiltrationPeriLesionnelle,
              ErigRoute.injectionIntramusculaire,
            ],
            nombreLesionsInfiltrees: 2,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.essen,
              dateDebut: _j(-2),
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'],
                  realise: [0, 1]),
              complete: false,
            ),
          ),
          vaccinationTetanos: const TetanusVaccination(
            statut: TetanusVaccinationStatus.oui,
            type: TetanusVaccineType.dtAdulte,
            observations: 'Rappel réalisé à J0.',
          ),
        ),

        // ── Cas 7 : Catégorie III + ERIG indiquée MAIS non administrée ──
        RabiesCaseRecord(
          id: 'RAB-007',
          numeroDossier: 'UAR-2026-0179',
          identity: const PatientIdentity(
            nom: 'Bouazza',
            prenom: 'Selma',
            age: 17,
            sexe: PatientGender.feminin,
            poidsKg: 55,
            telephone: '0557 33 44 55',
            profession: 'Lycéenne',
            niveauInstruction: InstructionLevel.secondaire,
            residence: Residence(
              commune: 'Rouiba',
              daira: 'Rouiba',
              wilaya: 'Alger',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(0)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '12:40',
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.multiples,
            siegeLesions: [LesionSite.membreInferieur],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification: 'Morsure transdermique avec saignement.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.errant,
            comportement: AnimalBehavior.suspect,
            vaccination: AnimalVaccinationStatus.non,
            sort: AnimalOutcome.enFuite,
          ),
          // ERIG indiquée mais NON administrée → alerte critique.
          erig: const ErigInfo(
            indiquee: true,
            administree: false,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.essen,
              dateDebut: _j(0),
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'], realise: [0]),
              complete: false,
            ),
          ),
        ),

        // ── Cas 8 : Rappel J0/J3 — patient déjà vacciné ─────────────────
        RabiesCaseRecord(
          id: 'RAB-008',
          numeroDossier: 'UAR-2026-0182',
          identity: const PatientIdentity(
            nom: 'Kadi',
            prenom: 'Sofiane',
            age: 45,
            sexe: PatientGender.masculin,
            poidsKg: 80,
            telephone: '0558 90 12 34',
            profession: 'Vétérinaire',
            niveauInstruction: InstructionLevel.superieur,
            residence: Residence(
              commune: 'Blida',
              daira: 'Blida',
              wilaya: 'Blida',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(0)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '10:15',
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.unique,
            siegeLesions: [LesionSite.main],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification:
                'Morsure de la main — rappel J0/J3 (déjà vacciné).',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.semiErrant,
            comportement: AnimalBehavior.suspect,
            vaccination: AnimalVaccinationStatus.ouiDocumentee,
            sort: AnimalOutcome.vivantSousSurveillance,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.rappelJ0J3,
              dateDebut: _j(0),
              doses: _doses(['J0', 'J3'], realise: [0]),
              complete: false,
            ),
          ),
        ),

        // ── Cas 9 : Protocole terminé + dossier clôturé + traçabilité OK ─
        RabiesCaseRecord(
          id: 'RAB-009',
          numeroDossier: 'UAR-2026-0190',
          identity: const PatientIdentity(
            nom: 'Berrahal',
            prenom: 'Nadia',
            age: 33,
            sexe: PatientGender.feminin,
            poidsKg: 63,
            telephone: '0559 12 34 56',
            profession: 'Commerçante',
            niveauInstruction: InstructionLevel.secondaire,
            residence: Residence(
              commune: 'Larba',
              daira: 'Larba',
              wilaya: 'Blida',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(-29)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '19:30',
            lieu: ExposurePlace.horsDomicile,
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.unique,
            siegeLesions: [LesionSite.membreInferieur],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification: 'Morsure transdermique avec saignement.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.semiErrant,
            comportement: AnimalBehavior.normal,
            vaccination: AnimalVaccinationStatus.ouiDocumentee,
            observationVeterinaire: ObservationStatus.oui,
            resultatObservation: ObservationResult.nonEnrage,
            sort: AnimalOutcome.vivantSousSurveillance,
          ),
          erig: const ErigInfo(
            indiquee: true,
            administree: true,
            numeroLot: 'ERIG-2211',
            titreIUMl: 200,
            poidsPatientKg: 63,
            doseTotaleTheoriqueIU: 1260,
            doseTotaleTheoriqueMl: 6.3,
            voies: [ErigRoute.infiltrationLesionnelle],
            nombreLesionsInfiltrees: 1,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.essen,
              dateDebut: _j(-28),
              // Protocole Essen entièrement réalisé.
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'],
                  realise: [0, 1, 2, 3, 4]),
              complete: true,
            ),
          ),
          tracabilite: const TraceabilityInfo(
            carteVaccination: TraceStatus.ouiAvecNumero,
            numeroCarte: 'UV-2026-0190',
            registre: TraceStatus.ouiAvecNumero,
            numeroRegistre: 'REG-2026-00421',
            remarques: 'Carte remise au patient en fin de protocole.',
          ),
          evolution: const FinalOutcome(
            resultat: FinalCaseOutcome.vaccinationComplete,
            dateCloture: null,
            observations: 'Protocole complet, dossier clôturé.',
          ),
        ),

        // ── Cas 10 : Labo négatif → animal non enragé, dossier abandonné ──
        RabiesCaseRecord(
          id: 'RAB-010',
          numeroDossier: 'UAR-2026-0194',
          identity: const PatientIdentity(
            nom: 'Djermane',
            prenom: 'Yacine',
            age: 47,
            sexe: PatientGender.masculin,
            poidsKg: 85,
            telephone: '0560 22 33 44',
            profession: 'Chauffeur',
            niveauInstruction: InstructionLevel.primaire,
            residence: Residence(
              commune: 'Meftah',
              daira: 'Meftah',
              wilaya: 'Blida',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(-12)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '08:50',
            lieu: ExposurePlace.horsDomicile,
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.multiples,
            siegeLesions: [LesionSite.main, LesionSite.membreSuperieur],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.proprietaire,
            comportement: AnimalBehavior.suspect,
            vaccination: AnimalVaccinationStatus.non,
            sort: AnimalOutcome.abattu,
            envoiTeteLabo: HeadLabSend.oui,
            typeAnalyse: LabAnalysisType.anticorpsFluorescents,
            dateAnalyse: null,
            resultatLabo: LabResultStatus.negatifAnimalNonEnrage,
          ),
          erig: const ErigInfo(
            indiquee: true,
            administree: true,
            numeroLot: 'ERIG-2214',
            titreIUMl: 200,
            poidsPatientKg: 85,
            doseTotaleTheoriqueIU: 1700,
            doseTotaleTheoriqueMl: 8.5,
            voies: [ErigRoute.injectionIntramusculaire],
            nombreLesionsInfiltrees: 0,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.essen,
              dateDebut: _j(-12),
              // J0 et J3 réalisées puis perdu de vue.
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'],
                  realise: [0, 1], enRetard: [2]),
              complete: false,
            ),
          ),
          evolution: const FinalOutcome(
            resultat: FinalCaseOutcome.abandonne,
            observations: 'Patient perdu de vue malgré relances.',
          ),
        ),

        // ── Cas 11 : Labo positif → animal enragé confirmé + MPVI sévère ──
        RabiesCaseRecord(
          id: 'RAB-011',
          numeroDossier: 'UAR-2026-0201',
          identity: const PatientIdentity(
            nom: 'Hamadache',
            prenom: 'Lina',
            age: 11,
            sexe: PatientGender.feminin,
            poidsKg: 36,
            telephone: '0561 44 55 66',
            profession: 'Collégienne',
            niveauInstruction: InstructionLevel.primaire,
            residence: Residence(
              commune: 'Bordj El Kiffan',
              daira: 'Dar El Beida',
              wilaya: 'Alger',
            ),
          ),
          admission: ArrivalInfo(dateArriveeUar: _j(-1)),
          exposition: const ExposureDetails(
            dateExposition: null,
            heureExposition: '17:10',
            lieu: ExposurePlace.domicile,
            nature: ExposureNature.morsure,
            saignement: BleedingStatus.oui,
            nombreLesions: LesionCountType.multiples,
            siegeLesions: [LesionSite.face],
          ),
          classification: const RiskClassification(
            categorie: RabiesRiskCategory.categorieIII,
            justification:
                'Morsure de la face chez l\'enfant — ERIG obligatoire.',
            methode: RiskAssessmentMethod.automatique,
          ),
          animal: const AnimalInfo(
            espece: AnimalSpecies.chien,
            statut: AnimalStatus.errant,
            comportement: AnimalBehavior.suspect,
            vaccination: AnimalVaccinationStatus.non,
            envoiTeteLabo: HeadLabSend.oui,
            typeAnalyse: LabAnalysisType.corpsNegri,
            dateAnalyse: null,
            resultatLabo: LabResultStatus.positifAnimalEnrage,
          ),
          erig: const ErigInfo(
            indiquee: true,
            administree: true,
            numeroLot: 'ERIG-2217',
            titreIUMl: 200,
            poidsPatientKg: 36,
            doseTotaleTheoriqueIU: 720,
            doseTotaleTheoriqueMl: 3.6,
            voies: [ErigRoute.infiltrationLesionnelle],
            nombreLesionsInfiltrees: 1,
          ),
          vaccination: RabiesVaccination(
            typeVaccin: RabiesVaccineType.vaccinCellulaire,
            dci: 'Vaccin antirabique, cellulaire concentré purifié',
            protocole: VaccinationProtocol(
              type: VaccinationProtocolType.essen,
              dateDebut: _j(0),
              doses: _doses(['J0', 'J3', 'J7', 'J14', 'J28'], realise: [0]),
              complete: false,
            ),
          ),
          mpvi: const MpviInfo(
            present: true,
            dateApparition: null,
            manifestations:
                'Œdème local important, urticaire, fièvre > 38,5 °C',
            gravite: MpviSeverity.severe,
            mesuresPrises: 'Antihistaminique, antipyrétique, surveillance accrue.',
            declarationPharmacovigilance: true,
          ),
        ),
      ];

  List<RabiesCaseRecord> get _records =>
      _cache ??= List<RabiesCaseRecord>.from(
        _seedRecords.map(MockRabiesHistoryFactory.enrichir),
      );

  @override
  Future<List<RabiesCaseRecord>> getDossiers() async {
    await Future.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_records);
  }

  @override
  Future<RabiesCaseRecord?> getDossierById(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (final r in _records) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  Future<RabiesCaseRecord> saveDossier(RabiesCaseRecord dossier) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final updated = dossier.copyWith(dateMaj: DateTime.now());
    final index = _records.indexWhere((element) => element.id == dossier.id);
    if (index >= 0) {
      _records[index] = updated;
    } else {
      _records.insert(0, updated);
    }
    return updated;
  }
}
