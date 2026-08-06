import '../../data/models/evaluation_initiale_model.dart';

abstract class EvaluationInitialeRepository {
  Future<InitialRabiesAssessment?> getEvaluation(String patientId);
  Future<void> saveEvaluation(InitialRabiesAssessment evaluation);
}
