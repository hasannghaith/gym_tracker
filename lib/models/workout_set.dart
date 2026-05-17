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
