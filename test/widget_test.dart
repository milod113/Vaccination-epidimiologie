import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:epidemiology_antirabic/main.dart';
import 'package:epidemiology_antirabic/injection_container.dart' as di;
import 'package:epidemiology_antirabic/features/tetanus_exposure/presentation/layout/tetanus_dashboard_layout.dart';
import 'package:epidemiology_antirabic/features/tetanus_exposure/presentation/screens/tetanus_act_form_screen.dart';
import 'package:epidemiology_antirabic/features/tetanus_exposure/presentation/screens/tetanus_historique_screen.dart';
import 'package:epidemiology_antirabic/features/tetanus_exposure/presentation/screens/tetanus_evaluation_screen.dart';
import 'package:epidemiology_antirabic/features/tetanus_exposure/presentation/screens/tetanus_patient_list_screen.dart';
import 'package:epidemiology_antirabic/features/tetanus_exposure/presentation/screens/tetanus_patient_detail_screen.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/presentation/layout/antirabique_dashboard_layout.dart';

void main() {
  testWidgets('Plateforme Vaccination welcome dashboard renders', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1280, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Hero header.
    expect(find.text('Plateforme Vaccination'), findsOneWidget);
    expect(find.text("Service d'Épidémiologie"), findsOneWidget);

    // KPI labels.
    expect(find.text('Patients en suivi'), findsOneWidget);
    expect(find.text('Alertes actives'), findsOneWidget);
    expect(find.text('Modules opérationnels'), findsOneWidget);

    // Quick actions.
    expect(find.text('Nouveau patient'), findsOneWidget);
    expect(find.text('Scanner un lot'), findsOneWidget);

    // Modules overview.
    expect(find.text('Vaccination antirabique'), findsOneWidget);
    expect(find.text('Tétanos post-exposition'), findsOneWidget);
    expect(find.text('Hépatite B post-exposition'), findsOneWidget);
    expect(find.text('Campagnes & riposte'), findsOneWidget);

    // Activity panel.
    expect(find.text('Alertes & activité'), findsOneWidget);
  });

  testWidgets('Welcome dashboard renders on a narrow phone viewport', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Plateforme Vaccination'), findsOneWidget);
    expect(find.text('Patients en suivi'), findsOneWidget);

    // Modules remain reachable by scrolling.
    await tester.scrollUntilVisible(find.text('Vaccination antirabique'), 300);
    expect(find.text('Vaccination antirabique'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Alertes & activité'), 300);
    expect(find.text('Alertes & activité'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos dashboard layout renders with premium sidebar', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TetanusDashboardLayout()));
    await tester.pumpAndSettle();

    // Sidebar identity + navigation.
    expect(find.text('Tétanos\npost-exposition'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Patients'), findsWidgets);
    expect(find.text('Évaluation'), findsOneWidget);

    // Embedded dashboard body.
    expect(find.text('Prophylaxie antitétanique'), findsOneWidget);
    expect(find.text('Patients\nen suivi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Antirabique dashboard layout uses shared premium sidebar', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1440, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AntirabiqueDashboardLayout()),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Vaccination\nAntirabique'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Centre Antirabique'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos evaluation screen renders wide (desktop layout)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TetanusEvaluationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Évaluation tétanique'), findsOneWidget);
    expect(find.text('Plaie & exposition'), findsOneWidget);
    expect(find.text('Valider l\'évaluation'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final contentList = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Niveau de risque'),
      300,
      scrollable: contentList,
    );
    expect(find.text('Niveau de risque'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Décision clinique'),
      400,
      scrollable: contentList,
    );
    expect(find.text('Décision clinique'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Synthèse clinique'),
      800,
      scrollable: contentList,
    );
    expect(find.text('Synthèse clinique'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos evaluation screen renders narrow (mobile)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TetanusEvaluationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Évaluation tétanique'), findsOneWidget);
    expect(find.text('Plaie & exposition'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Contexte clinique'), 300);
    expect(find.text('Contexte clinique'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos case list renders wide layout', (tester) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TetanusPatientListScreen()),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Cas tétanos'), findsOneWidget);
    expect(find.text('Nouvelle évaluation'), findsOneWidget);
    expect(find.text('Total'), findsWidgets);
    expect(find.text('Consulter le dossier'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos case list renders narrow with filters', (tester) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TetanusPatientListScreen()),
    );
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Cas tétanos'), findsOneWidget);
    expect(find.text('Filtres'), findsOneWidget);
    expect(find.text('Ig requises'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos case detail renders wide (clinical synthesis)', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TetanusPatientDetailScreen(patientId: 'TET-004')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toumi Rabeh'), findsOneWidget);
    expect(find.text('URGENT'), findsOneWidget);
    expect(find.text('Niveau de risque'), findsOneWidget);
    expect(find.text('Décision clinique'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tétanos case detail renders narrow (sections scrollable)', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TetanusPatientDetailScreen(patientId: 'TET-002')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Messaoud Sofiane'), findsOneWidget);
    expect(find.text('Décision clinique'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Chronologie des actes'), 500);
    expect(find.text('Chronologie des actes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Enregistrer un acte form renders wide (desktop layout)', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TetanusActFormScreen(patientId: 'TET-004')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enregistrer un acte'), findsWidgets);
    expect(find.text('Toumi Rabeh'), findsOneWidget);
    expect(find.text('Type d\'acte'), findsOneWidget);
    expect(find.text('Vaccination'), findsWidgets);
    expect(find.text('Sérum / Ig'), findsOneWidget);
    expect(find.text('Enregistrer l\'acte'), findsOneWidget);
    final mainScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Traçabilité'),
      400,
      scrollable: mainScroll,
    );
    expect(find.text('Traçabilité'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Enregistrer un acte form renders narrow (mobile)', (
    tester,
  ) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(home: TetanusActFormScreen(patientId: 'TET-002')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enregistrer un acte'), findsWidgets);
    expect(find.text('Messaoud Sofiane'), findsOneWidget);
    expect(find.text('Type d\'acte'), findsOneWidget);
    final mainScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Traçabilité'),
      400,
      scrollable: mainScroll,
    );
    expect(find.text('Traçabilité'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Historique des actes lists grouped histories', (tester) async {
    await di.sl.reset();
    await di.initDependencies();
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: TetanusHistoriqueScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Historique des actes'), findsOneWidget);
    expect(find.text('Kadi Amel'), findsOneWidget);
    expect(find.text('Enregistrer un acte'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
