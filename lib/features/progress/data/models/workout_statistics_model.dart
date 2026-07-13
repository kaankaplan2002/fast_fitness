class WorkoutStatisticsModel {
  final int weeklyWorkouts;
  final int monthlyWorkouts;
  final int totalWorkouts;
  final int totalMinutes;
  final int averageWorkoutMinutes;
  final int totalCalories;
  final String favoriteMuscleGroup;
  final String lastWorkoutText;

  const WorkoutStatisticsModel({
    required this.weeklyWorkouts,
    required this.monthlyWorkouts,
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.averageWorkoutMinutes,
    required this.totalCalories,
    required this.favoriteMuscleGroup,
    required this.lastWorkoutText,
  });
}
