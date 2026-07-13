import 'package:fast_fitness/features/progress/data/datasource/progress_remote_datasource.dart';
import 'package:fast_fitness/features/progress/data/models/weight_history_model.dart';

class ProgressRepository {
  final ProgressRemoteDatasource datasource = ProgressRemoteDatasource();

  Future<void> saveWeight(double weight) {
    return datasource.saveWeight(weight);
  }

  Stream<List<WeightHistoryModel>> getWeightHistory() {
    return datasource.getWeightHistory();
  }
}