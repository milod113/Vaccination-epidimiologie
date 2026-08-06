import 'package:epidemiology_antirabic/features/vaccination_antirabique/data/models/evaluation_initiale_model.dart';
import 'package:epidemiology_antirabic/features/vaccination_antirabique/domain/repositories/evaluation_initiale_repository.dart';

class MockEvaluationInitialeRepository implements EvaluationInitialeRepository {
  final Map<String, InitialRabiesAssessment> _evaluations = {};

  @override
  Future<InitialRabiesAssessment?> getEvaluation(String patientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _evaluations[patientId];
  }

  @override
  Future<void> saveEvaluation(InitialRabiesAssessment evaluation) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _evaluations[evaluation.patientId] = evaluation;
  }
}
