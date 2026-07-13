class WorkoutAnalyticsModel {
  final int mondayMinutes;
  final int tuesdayMinutes;
  final int wednesdayMinutes;
  final int thursdayMinutes;
  final int fridayMinutes;
  final int saturdayMinutes;
  final int sundayMinutes;
  final int averageDuration;
  final int longestWorkout;
  final int averageCalories;
  final int workoutFrequency;

  const WorkoutAnalyticsModel({
    required this.mondayMinutes,
    required this.tuesdayMinutes,
    required this.wednesdayMinutes,
    required this.thursdayMinutes,
    required this.fridayMinutes,
    required this.saturdayMinutes,
    required this.sundayMinutes,
    required this.averageDuration,
    required this.longestWorkout,
    required this.averageCalories,
    required this.workoutFrequency,
  });

  List<int> get weeklyMinutes => [
    mondayMinutes,
    tuesdayMinutes,
    wednesdayMinutes,
    thursdayMinutes,
    fridayMinutes,
    saturdayMinutes,
    sundayMinutes,
  ];
}
