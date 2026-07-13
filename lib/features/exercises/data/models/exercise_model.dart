class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String difficulty;
  final int sets;
  final String reps;
  final int restSeconds;
  final String description;
  final String gifUrl;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.description,
    required this.gifUrl,
  });

  factory ExerciseModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return ExerciseModel(
      id: id,
      name: map['name'] ?? '',
      muscleGroup: map['muscleGroup'] ?? '',
      equipment: map['equipment'] ?? '',
      difficulty: map['difficulty'] ?? '',
      sets: map['sets'] ?? 3,
      reps: map['reps'] ?? '12',
      restSeconds: map['restSeconds'] ?? 60,
      description: map['description'] ?? '',
      gifUrl: map['gifUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'difficulty': difficulty,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'description': description,
      'gifUrl': gifUrl,
    };
  }
}