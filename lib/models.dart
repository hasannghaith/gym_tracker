class WorkoutSet {
  String reps;
  String weight;

  WorkoutSet({required this.reps, required this.weight});
}

class Exercise {
  String name;
  List<WorkoutSet> sets;

  Exercise({required this.name}) : sets = [];
}
