import '../models/dossier/dossier_actor.dart';
import '../models/dossier/dossier_enums.dart';

/// Contexte de l'acteur courant de la session.
///
/// En production, l'acteur proviendra de la session d'authentification. Dans
/// l'application actuelle (mock data), il expose un acteur par défaut
/// configurable ainsi qu'une liste d'acteurs prédéfinis cohérents avec l'UAR.
class ActorContext {
  const ActorContext._();

  static DossierActor _courant = acteurParDefaut;

  /// Acteur opérant sur les dossiers dans la session courante.
  static DossierActor get acteurCourant => _courant;

  /// Permet de changer l'acteur courant (utile pour simuler plusieurs rôles).
  static void changerActeur(DossierActor acteur) => _courant = acteur;

  /// Acteur par défaut (infirmier de l'UAR).
  static DossierActor get acteurParDefaut => const DossierActor(
    id: 'ACT-INF-001',
    nomComplet: 'IDE Salim Benali',
    role: ActorRole.infirmier,
    service: 'UAR Alger Centre',
    telephone: '0551 44 55 66',
  );

  // ── Acteurs prédéfinis ───────────────────────────────────────────────

  static const medecin = DossierActor(
    id: 'ACT-MED-001',
    nomComplet: 'Dr. Amina Benyahia',
    role: ActorRole.medecin,
    service: 'UAR Alger Centre',
    telephone: '0552 33 44 55',
  );

  static const infirmier = DossierActor(
    id: 'ACT-INF-001',
    nomComplet: 'IDE Salim Benali',
    role: ActorRole.infirmier,
    service: 'UAR Alger Centre',
    telephone: '0551 44 55 66',
  );

  static const agentVaccination = DossierActor(
    id: 'ACT-VAC-001',
    nomComplet: 'Yacine Khelifi',
    role: ActorRole.agentVaccination,
    service: 'UAR Alger Centre',
    telephone: '0553 22 33 44',
  );

  static const secretaire = DossierActor(
    id: 'ACT-SEC-001',
    nomComplet: 'Fatiha Zerrouki',
    role: ActorRole.secretaire,
    service: 'Secrétariat UAR Alger Centre',
    telephone: '0554 11 22 33',
  );

  static const veterinaire = DossierActor(
    id: 'ACT-VET-001',
    nomComplet: 'Dr. Omar Meziane',
    role: ActorRole.veterinaire,
    service: 'Direction de la Santé — Blida',
    telephone: '0555 66 77 88',
  );

  /// Acteur de la vaccination tétanos / autres traitements.
  static const agentAdministratif = DossierActor(
    id: 'ACT-ADM-001',
    nomComplet: 'Karim Boudraa',
    role: ActorRole.administrateur,
    service: 'UAR Alger Centre',
    telephone: '0556 88 99 00',
  );

  /// Liste des acteurs disponibles pour une future sélection.
  static List<DossierActor> get disponibles =>
      [medecin, infirmier, agentVaccination, secretaire, veterinaire, agentAdministratif];
}