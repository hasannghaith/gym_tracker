import 'exercise.dart';

class Session {
  final int? id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int exerciseCount;
  List<Exercise> exercises;

  Session({this.id, required this.startedAt, this.endedAt, this.exerciseCount = 0, List<Exercise>? exercises})
      : exercises = exercises ?? [];

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'],
    startedAt: DateTime.parse(json['started_at']),
    endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
    exerciseCount: json['exercise_count'] ?? 0,
    exercises: json['exercises'] != null
        ? (json['exercises'] as List).map((e) => Exercise.fromJson(e)).toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
  };
}
