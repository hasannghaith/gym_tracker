class WorkoutSet {
  final int? id;
  final int? exerciseId;
  int reps;
  double weight;

  WorkoutSet({this.id, this.exerciseId, required this.reps, required this.weight});

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    id: json['id'],
    exerciseId: json['exercise_id'],
    reps: json['reps'],
    weight: (json['weight'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_id': exerciseId,
    'reps': reps,
    'weight': weight,
  };
}

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

class Session {
  final int? id;
  final DateTime startedAt;
  final DateTime? endedAt;
  List<Exercise> exercises;

  Session({this.id, required this.startedAt, this.endedAt, List<Exercise>? exercises})
      : exercises = exercises ?? [];

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'],
    startedAt: DateTime.parse(json['started_at']),
    endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
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
