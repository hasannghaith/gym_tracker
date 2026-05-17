import 'workout_set.dart';

class Exercise {
  final int? id;
  final int? sessionId;
  String name;
  List<WorkoutSet> sets;

  Exercise({this.id, this.sessionId, required this.name, List<WorkoutSet>? sets})
      : sets = sets ?? [];

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    sessionId: json['session_id'],
    name: json['name'],
    sets: json['sets'] != null
        ? (json['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'session_id': sessionId,
    'name': name,
  };
}
