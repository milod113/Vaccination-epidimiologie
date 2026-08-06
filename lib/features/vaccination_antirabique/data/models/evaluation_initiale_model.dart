enum NiveauPriorite {
  urgent,
  semiUrgent,
  nonUrgent,
  nonDeterminee,
}

extension NiveauPrioriteX on NiveauPriorite {
  String get label {
    switch (this) {
      case NiveauPriorite.urgent:
        return 'Urgent';
      case NiveauPriorite.semiUrgent:
        return 'Semi-urgent';
      case NiveauPriorite.nonUrgent:
        return 'Non urgent';
      case NiveauPriorite.nonDeterminee:
        return 'Non déterminée';
    }
  }
}

enum DecisionSynthese {
  compatibleDemarrage,
  precautionsComplementaires,
  avisSpecialiseRequis,
}

extension DecisionSyntheseX on DecisionSynthese {
  String get label {
    switch (this) {
      case DecisionSynthese.compatibleDemarrage:
        return 'Démarrage du protocole';
      case DecisionSynthese.precautionsComplementaires:
        return 'Précautions complémentaires';
      case DecisionSynthese.avisSpecialiseRequis:
        return 'Avis spécialisé requis';
    }
  }
}

class ExpositionInfo {
  final bool morsure;
  final bool griffure;
  final bool contactSalivairePeauLestee;
  final bool contactSalivaireMuqueuse;
  final bool expositionRecenteConfirmee;
  final bool dateExpositionRenseignee;
  final bool animalConnu;
  final bool animalInconnu;
  final bool animalObservable;
  final bool animalNonObservable;
  final bool expositionJugeeSignificative;
  final String? dateExposition;
  final String? heureExposition;
  final String? especeAnimale;
  final String? localisation;
  final int? nombreLesions;
  final String? commentaire;

  const ExpositionInfo({
    this.morsure = false,
    this.griffure = false,
    this.contactSalivairePeauLestee = false,
    this.contactSalivaireMuqueuse = false,
    this.expositionRecenteConfirmee = false,
    this.dateExpositionRenseignee = false,
    this.animalConnu = false,
    this.animalInconnu = false,
    this.animalObservable = false,
    this.animalNonObservable = false,
    this.expositionJugeeSignificative = false,
    this.dateExposition,
    this.heureExposition,
    this.especeAnimale,
    this.localisation,
    this.nombreLesions,
    this.commentaire,
  });

  ExpositionInfo copyWith({
    bool? morsure,
    bool? griffure,
    bool? contactSalivairePeauLestee,
    bool? contactSalivaireMuqueuse,
    bool? expositionRecenteConfirmee,
    bool? dateExpositionRenseignee,
    bool? animalConnu,
    bool? animalInconnu,
    bool? animalObservable,
    bool? animalNonObservable,
    bool? expositionJugeeSignificative,
    String? dateExposition,
    String? heureExposition,
    String? especeAnimale,
    String? localisation,
    int? nombreLesions,
    String? commentaire,
  }) {
    return ExpositionInfo(
      morsure: morsure ?? this.morsure,
      griffure: griffure ?? this.griffure,
      contactSalivairePeauLestee: contactSalivairePeauLestee ?? this.contactSalivairePeauLestee,
      contactSalivaireMuqueuse: contactSalivaireMuqueuse ?? this.contactSalivaireMuqueuse,
      expositionRecenteConfirmee: expositionRecenteConfirmee ?? this.expositionRecenteConfirmee,
      dateExpositionRenseignee: dateExpositionRenseignee ?? this.dateExpositionRenseignee,
      animalConnu: animalConnu ?? this.animalConnu,
      animalInconnu: animalInconnu ?? this.animalInconnu,
      animalObservable: animalObservable ?? this.animalObservable,
      animalNonObservable: animalNonObservable ?? this.animalNonObservable,
      expositionJugeeSignificative: expositionJugeeSignificative ?? this.expositionJugeeSignificative,
      dateExposition: dateExposition ?? this.dateExposition,
      heureExposition: heureExposition ?? this.heureExposition,
      especeAnimale: especeAnimale ?? this.especeAnimale,
      localisation: localisation ?? this.localisation,
      nombreLesions: nombreLesions ?? this.nombreLesions,
      commentaire: commentaire ?? this.commentaire,
    );
  }
}

class PlaieInfo {
  final bool plaieLaveeImmediatement;
  final bool desinfectionRealisee;
  final bool plaieProfonde;
  final bool plaieMultiple;
  final bool atteinteTeteCou;
  final bool atteinteMainDoigts;
  final bool saignementImportant;
  final bool plaieNecessiteSoinsComplementaires;

  const PlaieInfo({
    this.plaieLaveeImmediatement = false,
    this.desinfectionRealisee = false,
    this.plaieProfonde = false,
    this.plaieMultiple = false,
    this.atteinteTeteCou = false,
    this.atteinteMainDoigts = false,
    this.saignementImportant = false,
    this.plaieNecessiteSoinsComplementaires = false,
  });

  PlaieInfo copyWith({
    bool? plaieLaveeImmediatement,
    bool? desinfectionRealisee,
    bool? plaieProfonde,
    bool? plaieMultiple,
    bool? atteinteTeteCou,
    bool? atteinteMainDoigts,
    bool? saignementImportant,
    bool? plaieNecessiteSoinsComplementaires,
  }) {
    return PlaieInfo(
      plaieLaveeImmediatement: plaieLaveeImmediatement ?? this.plaieLaveeImmediatement,
      desinfectionRealisee: desinfectionRealisee ?? this.desinfectionRealisee,
      plaieProfonde: plaieProfonde ?? this.plaieProfonde,
      plaieMultiple: plaieMultiple ?? this.plaieMultiple,
      atteinteTeteCou: atteinteTeteCou ?? this.atteinteTeteCou,
      atteinteMainDoigts: atteinteMainDoigts ?? this.atteinteMainDoigts,
      saignementImportant: saignementImportant ?? this.saignementImportant,
      plaieNecessiteSoinsComplementaires: plaieNecessiteSoinsComplementaires ?? this.plaieNecessiteSoinsComplementaires,
    );
  }

  bool get signesGravite => plaieProfonde || plaieMultiple || atteinteTeteCou || atteinteMainDoigts || saignementImportant;
}

class EtatClinique {
  final bool etatGeneralStable;
  final bool fievreActuelle;
  final bool infectionEnCours;
  final bool immunodepressionConnue;
  final bool traitementImmunosuppresseur;
  final bool grossesse;
  final bool allergieSevereConnue;
  final bool antecedentReactionGraveVaccin;

  const EtatClinique({
    this.etatGeneralStable = false,
    this.fievreActuelle = false,
    this.infectionEnCours = false,
    this.immunodepressionConnue = false,
    this.traitementImmunosuppresseur = false,
    this.grossesse = false,
    this.allergieSevereConnue = false,
    this.antecedentReactionGraveVaccin = false,
  });

  EtatClinique copyWith({
    bool? etatGeneralStable,
    bool? fievreActuelle,
    bool? infectionEnCours,
    bool? immunodepressionConnue,
    bool? traitementImmunosuppresseur,
    bool? grossesse,
    bool? allergieSevereConnue,
    bool? antecedentReactionGraveVaccin,
  }) {
    return EtatClinique(
      etatGeneralStable: etatGeneralStable ?? this.etatGeneralStable,
      fievreActuelle: fievreActuelle ?? this.fievreActuelle,
      infectionEnCours: infectionEnCours ?? this.infectionEnCours,
      immunodepressionConnue: immunodepressionConnue ?? this.immunodepressionConnue,
      traitementImmunosuppresseur: traitementImmunosuppresseur ?? this.traitementImmunosuppresseur,
      grossesse: grossesse ?? this.grossesse,
      allergieSevereConnue: allergieSevereConnue ?? this.allergieSevereConnue,
      antecedentReactionGraveVaccin: antecedentReactionGraveVaccin ?? this.antecedentReactionGraveVaccin,
    );
  }

  bool get contexteComplexe => immunodepressionConnue || traitementImmunosuppresseur || antecedentReactionGraveVaccin;
  bool get signesVigilance => fievreActuelle || infectionEnCours || allergieSevereConnue;
}

class AntecedentsAntirabiques {
  final bool vaccinationAnterieureConnue;
  final bool antecedentProtocoleComplet;
  final bool antecedentProtocoleIncomplet;
  final bool statutVaccinalInconnu;
  final bool carnetDisponible;
  final bool documentNonDisponible;

  const AntecedentsAntirabiques({
    this.vaccinationAnterieureConnue = false,
    this.antecedentProtocoleComplet = false,
    this.antecedentProtocoleIncomplet = false,
    this.statutVaccinalInconnu = false,
    this.carnetDisponible = false,
    this.documentNonDisponible = false,
  });

  AntecedentsAntirabiques copyWith({
    bool? vaccinationAnterieureConnue,
    bool? antecedentProtocoleComplet,
    bool? antecedentProtocoleIncomplet,
    bool? statutVaccinalInconnu,
    bool? carnetDisponible,
    bool? documentNonDisponible,
  }) {
    return AntecedentsAntirabiques(
      vaccinationAnterieureConnue: vaccinationAnterieureConnue ?? this.vaccinationAnterieureConnue,
      antecedentProtocoleComplet: antecedentProtocoleComplet ?? this.antecedentProtocoleComplet,
      antecedentProtocoleIncomplet: antecedentProtocoleIncomplet ?? this.antecedentProtocoleIncomplet,
      statutVaccinalInconnu: statutVaccinalInconnu ?? this.statutVaccinalInconnu,
      carnetDisponible: carnetDisponible ?? this.carnetDisponible,
      documentNonDisponible: documentNonDisponible ?? this.documentNonDisponible,
    );
  }
}

class ConduiteInitiale {
  final bool vaccinationIndiquee;
  final bool immunoglobulinesAEnvisager;
  final bool soinsLocauxAPoursuivre;
  final bool antibiotherapiePrescrite;
  final bool antibiotiqueSeulSansCI;
  final bool surveillanceCliniqueRenforcee;
  final bool avisSpecialiseNecessaire;

  const ConduiteInitiale({
    this.vaccinationIndiquee = false,
    this.immunoglobulinesAEnvisager = false,
    this.soinsLocauxAPoursuivre = false,
    this.antibiotherapiePrescrite = false,
    this.antibiotiqueSeulSansCI = false,
    this.surveillanceCliniqueRenforcee = false,
    this.avisSpecialiseNecessaire = false,
  });

  ConduiteInitiale copyWith({
    bool? vaccinationIndiquee,
    bool? immunoglobulinesAEnvisager,
    bool? soinsLocauxAPoursuivre,
    bool? antibiotherapiePrescrite,
    bool? antibiotiqueSeulSansCI,
    bool? surveillanceCliniqueRenforcee,
    bool? avisSpecialiseNecessaire,
  }) {
    return ConduiteInitiale(
      vaccinationIndiquee: vaccinationIndiquee ?? this.vaccinationIndiquee,
      immunoglobulinesAEnvisager: immunoglobulinesAEnvisager ?? this.immunoglobulinesAEnvisager,
      soinsLocauxAPoursuivre: soinsLocauxAPoursuivre ?? this.soinsLocauxAPoursuivre,
      antibiotherapiePrescrite: antibiotherapiePrescrite ?? this.antibiotherapiePrescrite,
      antibiotiqueSeulSansCI: antibiotiqueSeulSansCI ?? this.antibiotiqueSeulSansCI,
      surveillanceCliniqueRenforcee: surveillanceCliniqueRenforcee ?? this.surveillanceCliniqueRenforcee,
      avisSpecialiseNecessaire: avisSpecialiseNecessaire ?? this.avisSpecialiseNecessaire,
    );
  }
}

class DecisionMedicale {
  final bool demarrerEssen;
  final bool demarrerZagreb;
  final bool demarrerApresConfirmation;
  final bool reevaluationNecessaire;

  const DecisionMedicale({
    this.demarrerEssen = false,
    this.demarrerZagreb = false,
    this.demarrerApresConfirmation = false,
    this.reevaluationNecessaire = false,
  });

  DecisionMedicale copyWith({
    bool? demarrerEssen,
    bool? demarrerZagreb,
    bool? demarrerApresConfirmation,
    bool? reevaluationNecessaire,
  }) {
    return DecisionMedicale(
      demarrerEssen: demarrerEssen ?? this.demarrerEssen,
      demarrerZagreb: demarrerZagreb ?? this.demarrerZagreb,
      demarrerApresConfirmation: demarrerApresConfirmation ?? this.demarrerApresConfirmation,
      reevaluationNecessaire: reevaluationNecessaire ?? this.reevaluationNecessaire,
    );
  }
}

class InitialRabiesAssessment {
  final String patientId;
  final String dateEvaluation;
  final String? medecinEvaluateur;
  final String? centre;
  final NiveauPriorite niveauPriorite;
  final ExpositionInfo exposition;
  final PlaieInfo plaie;
  final EtatClinique etatClinique;
  final AntecedentsAntirabiques antecedents;
  final ConduiteInitiale conduite;
  final DecisionMedicale decision;

  // ── Admission (UAR) ──────────────────────────────────────────────
  final String? heureArrivee;
  final String? modeArrivee;
  final String? structureOrientation;

  // ── Adresse de résidence ─────────────────────────────────────────
  final String? adresseResidence;
  final String? commune;
  final String? daira;
  final String? wilaya;

  // ── Animal en cause ──────────────────────────────────────────────
  final String? animalEspece;
  final String? animalStatut;
  final String? animalComportement;
  final String? animalProprietaire;
  final String? animalObservationVet;
  final String? animalSort;
  final String? animalResultat;

  // ── Soins locaux / ERIG ──────────────────────────────────────────
  final bool lavageEau;
  final bool lavageEauSavon;
  final String? produitsAppliques;
  final bool erigIndiquee;
  final bool erigAdministree;
  final String? erigLot;
  final String? erigDoseTheorique;
  final String? erigDilution;
  final String? erigVoies;
  final String? erigReaction;

  // ── Vaccination / protocole ──────────────────────────────────────
  final String? vaccinType;
  final String? vaccinVoie;
  final String? vaccinLot;
  final String? vaccinDci;

  // ── Traçabilité ──────────────────────────────────────────────────
  final bool carteRemise;
  final String? numeroCarte;
  final bool inscritRegistre;
  final String? numeroRegistre;

  final String? observationsCliniques;
  final String? conclusionMedicale;

  const InitialRabiesAssessment({
    required this.patientId,
    required this.dateEvaluation,
    this.medecinEvaluateur,
    this.centre,
    this.niveauPriorite = NiveauPriorite.nonDeterminee,
    this.exposition = const ExpositionInfo(),
    this.plaie = const PlaieInfo(),
    this.etatClinique = const EtatClinique(),
    this.antecedents = const AntecedentsAntirabiques(),
    this.conduite = const ConduiteInitiale(),
    this.decision = const DecisionMedicale(),
    this.heureArrivee,
    this.modeArrivee,
    this.structureOrientation,
    this.adresseResidence,
    this.commune,
    this.daira,
    this.wilaya,
    this.animalEspece,
    this.animalStatut,
    this.animalComportement,
    this.animalProprietaire,
    this.animalObservationVet,
    this.animalSort,
    this.animalResultat,
    this.lavageEau = false,
    this.lavageEauSavon = false,
    this.produitsAppliques,
    this.erigIndiquee = false,
    this.erigAdministree = false,
    this.erigLot,
    this.erigDoseTheorique,
    this.erigDilution,
    this.erigVoies,
    this.erigReaction,
    this.vaccinType,
    this.vaccinVoie,
    this.vaccinLot,
    this.vaccinDci,
    this.carteRemise = false,
    this.numeroCarte,
    this.inscritRegistre = false,
    this.numeroRegistre,
    this.observationsCliniques,
    this.conclusionMedicale,
  });

  InitialRabiesAssessment copyWith({
    String? patientId,
    String? dateEvaluation,
    String? medecinEvaluateur,
    String? centre,
    NiveauPriorite? niveauPriorite,
    ExpositionInfo? exposition,
    PlaieInfo? plaie,
    EtatClinique? etatClinique,
    AntecedentsAntirabiques? antecedents,
    ConduiteInitiale? conduite,
    DecisionMedicale? decision,
    String? heureArrivee,
    String? modeArrivee,
    String? structureOrientation,
    String? adresseResidence,
    String? commune,
    String? daira,
    String? wilaya,
    String? animalEspece,
    String? animalStatut,
    String? animalComportement,
    String? animalProprietaire,
    String? animalObservationVet,
    String? animalSort,
    String? animalResultat,
    bool? lavageEau,
    bool? lavageEauSavon,
    String? produitsAppliques,
    bool? erigIndiquee,
    bool? erigAdministree,
    String? erigLot,
    String? erigDoseTheorique,
    String? erigDilution,
    String? erigVoies,
    String? erigReaction,
    String? vaccinType,
    String? vaccinVoie,
    String? vaccinLot,
    String? vaccinDci,
    bool? carteRemise,
    String? numeroCarte,
    bool? inscritRegistre,
    String? numeroRegistre,
    String? observationsCliniques,
    String? conclusionMedicale,
  }) {
    return InitialRabiesAssessment(
      patientId: patientId ?? this.patientId,
      dateEvaluation: dateEvaluation ?? this.dateEvaluation,
      medecinEvaluateur: medecinEvaluateur ?? this.medecinEvaluateur,
      centre: centre ?? this.centre,
      niveauPriorite: niveauPriorite ?? this.niveauPriorite,
      exposition: exposition ?? this.exposition,
      plaie: plaie ?? this.plaie,
      etatClinique: etatClinique ?? this.etatClinique,
      antecedents: antecedents ?? this.antecedents,
      conduite: conduite ?? this.conduite,
      decision: decision ?? this.decision,
      heureArrivee: heureArrivee ?? this.heureArrivee,
      modeArrivee: modeArrivee ?? this.modeArrivee,
      structureOrientation:
          structureOrientation ?? this.structureOrientation,
      adresseResidence:
          adresseResidence ?? this.adresseResidence,
      commune: commune ?? this.commune,
      daira: daira ?? this.daira,
      wilaya: wilaya ?? this.wilaya,
      animalEspece: animalEspece ?? this.animalEspece,
      animalStatut: animalStatut ?? this.animalStatut,
      animalComportement: animalComportement ?? this.animalComportement,
      animalProprietaire: animalProprietaire ?? this.animalProprietaire,
      animalObservationVet: animalObservationVet ?? this.animalObservationVet,
      animalSort: animalSort ?? this.animalSort,
      animalResultat: animalResultat ?? this.animalResultat,
      lavageEau: lavageEau ?? this.lavageEau,
      lavageEauSavon: lavageEauSavon ?? this.lavageEauSavon,
      produitsAppliques: produitsAppliques ?? this.produitsAppliques,
      erigIndiquee: erigIndiquee ?? this.erigIndiquee,
      erigAdministree: erigAdministree ?? this.erigAdministree,
      erigLot: erigLot ?? this.erigLot,
      erigDoseTheorique: erigDoseTheorique ?? this.erigDoseTheorique,
      erigDilution: erigDilution ?? this.erigDilution,
      erigVoies: erigVoies ?? this.erigVoies,
      erigReaction: erigReaction ?? this.erigReaction,
      vaccinType: vaccinType ?? this.vaccinType,
      vaccinVoie: vaccinVoie ?? this.vaccinVoie,
      vaccinLot: vaccinLot ?? this.vaccinLot,
      vaccinDci: vaccinDci ?? this.vaccinDci,
      carteRemise: carteRemise ?? this.carteRemise,
      numeroCarte: numeroCarte ?? this.numeroCarte,
      inscritRegistre: inscritRegistre ?? this.inscritRegistre,
      numeroRegistre: numeroRegistre ?? this.numeroRegistre,
      observationsCliniques: observationsCliniques ?? this.observationsCliniques,
      conclusionMedicale: conclusionMedicale ?? this.conclusionMedicale,
    );
  }

  bool get expositionSignificative => exposition.expositionJugeeSignificative;
  bool get signesGraviteLocale => plaie.signesGravite;
  bool get contexteComplexe => etatClinique.contexteComplexe;
  bool get signesVigilance => etatClinique.signesVigilance;

  DecisionSynthese get synthese {
    if (expositionSignificative && !signesGraviteLocale && !contexteComplexe && !signesVigilance) {
      return DecisionSynthese.compatibleDemarrage;
    }
    if (contexteComplexe || conduite.avisSpecialiseNecessaire) {
      return DecisionSynthese.avisSpecialiseRequis;
    }
    return DecisionSynthese.precautionsComplementaires;
  }

  String get messageSynthese {
    switch (synthese) {
      case DecisionSynthese.compatibleDemarrage:
        return 'Évaluation initiale compatible avec démarrage du protocole vaccinal. '
            'Aucune contre-indication immédiate identifiée. '
            'Procéder selon le schéma choisi.';
      case DecisionSynthese.precautionsComplementaires:
        return 'Précautions complémentaires à vérifier avant validation finale. '
            'Surveillance clinique renforcée recommandée. '
            'Vérifier la concordance avec les recommandations OMS en vigueur.';
      case DecisionSynthese.avisSpecialiseRequis:
        return 'Avis spécialisé recommandé avant validation finale du protocole. '
            'Contexte clinique complexe nécessitant une évaluation multidisciplinaire. '
            'Ne pas retarder la première dose en l\'absence de contre-indication formelle.';
    }
  }
}
