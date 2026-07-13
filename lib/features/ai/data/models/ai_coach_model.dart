class AiCoachModel {
  final String title;
  final String message;
  final String recommendation;
  final int weeklyWorkouts;
  final int totalWorkouts;
  final int currentStreak;
  final int suggestedDuration;
  final int suggestedCalories;
  final String suggestedFocus;

  const AiCoachModel({
    required this.title,
    required this.message,
    required this.recommendation,
    required this.weeklyWorkouts,
    required this.totalWorkouts,
    required this.currentStreak,
    required this.suggestedDuration,
    required this.suggestedCalories,
    required this.suggestedFocus,
  });
}
