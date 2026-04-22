import 'package:flutter/material.dart';
import 'models.dart';

Widget buildSessionCard({
  required bool sessionStarted,
  required List<Exercise> exercises,
  required VoidCallback onStart,
  required VoidCallback onReset,
}) {
  int totalSets = 0;
  for (Exercise ex in exercises) {
    totalSets += ex.sets.length;
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: sessionStarted
          ? const Color(0xFF0D2B17)
          : const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: sessionStarted ? const Color(0xFF00E676) : Colors.white12,
        width: 1.2,
      ),
    ),
    child: Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              sessionStarted
                  ? Icons.play_circle_fill
                  : Icons.pause_circle_outline,
              color: sessionStarted
                  ? const Color(0xFF00E676)
                  : Colors.white30,
              size: 32,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sessionStarted ? 'Session Active' : 'Ready to Train?',
                  style: TextStyle(
                    color: sessionStarted
                        ? const Color(0xFF00E676)
                        : Colors.white60,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (sessionStarted)
                  Text(
                    '${exercises.length} exercise(s)  •  $totalSets set(s)',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        sessionStarted
            ? ElevatedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('End'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              )
            : ElevatedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text(
                  'Start',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
              ),
      ],
    ),
  );
}

Widget buildAddExerciseRow({
  required TextEditingController controller,
  required VoidCallback onAdd,
}) {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add exercise (e.g. Bench Press)',
            hintStyle:
                const TextStyle(color: Colors.white30, fontSize: 14),
            prefixIcon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF00E676), size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF00E676)),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: onAdd,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00E676),
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Icon(Icons.add, size: 26),
      ),
    ],
  );
}

Widget buildExerciseCard({
  required int index,
  required Exercise exercise,
  required TextEditingController repsController,
  required TextEditingController weightController,
  required Function(int) onAddSet,
  required Function(int) onRemove,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF222222),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.sports_gymnastics,
                  color: Color(0xFF00E676), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color:
                          const Color(0xFF00E676).withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${exercise.sets.length} sets',
                  style: const TextStyle(
                      color: Color(0xFF00E676), fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: (){onRemove(index);}, icon: Icon(Icons.close,size: 20,))

            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              if (exercise.sets.isNotEmpty)
                Column(
                  children: List.generate(exercise.sets.length, (setIndex) {
                    WorkoutSet set = exercise.sets[setIndex];
                    return buildSetRow(setIndex, set);
                  }),
                ),
              if (exercise.sets.isNotEmpty) const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Reps',
                        hintStyle: const TextStyle(
                            color: Colors.white30, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF00E676)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Weight (kg)',
                        hintStyle: const TextStyle(
                            color: Colors.white30, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: Color(0xFF00E676)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => onAddSet(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(46, 46),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildSetRow(int setIndex, WorkoutSet set) {
  return Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFF0F0F0F),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF00E676).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(
                color: Color(0xFF00E676),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.repeat, color: Colors.white38, size: 15),
        const SizedBox(width: 4),
        Text(
          '${set.reps} reps',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.monitor_weight_outlined,
            color: Colors.white38, size: 15),
        const SizedBox(width: 4),
        Text(
          '${set.weight} kg',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget buildEmptyHint() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.fitness_center, color: Colors.white12, size: 70),
        SizedBox(height: 14),
        Text(
          'No exercises yet.\nType a name above and tap + to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white30, fontSize: 15),
        ),
      ],
    ),
  );
}

Widget buildWelcome() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.sports_gymnastics, color: Colors.white10, size: 90),
        SizedBox(height: 18),
        Text(
          'Press Start to begin\nyour training session!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white24,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}
