class GeneratedExerciseModel {
  final String name;
  final String muscleGroup;
  final String sets;
  final String reps;
  final String rest;
  final String note;

  const GeneratedExerciseModel({
    required this.name,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'note': note,
    };
  }

  factory GeneratedExerciseModel.fromMap(Map<String, dynamic> map) {
    return GeneratedExerciseModel(
      name: map['name'] ?? 'Exercise',
      muscleGroup: map['muscleGroup'] ?? 'Full Body',
      sets: map['sets'] ?? '3',
      reps: map['reps'] ?? '12',
      rest: map['rest'] ?? '60 sec',
      note: map['note'] ?? '',
    );
  }
}
