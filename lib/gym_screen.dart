import 'dart:developer';

import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  bool _sessionStarted = false;
  List<Exercise> _exercises = [];

  final TextEditingController _exerciseNameController =
      TextEditingController();
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];

  @override
  void dispose() {
    super.dispose();
  }

  void _startSession() {
    setState(() {
      _sessionStarted = true;
    });
  }

  void _resetSession() {
    for (TextEditingController c in _repsControllers) {
      c.dispose();
    }
    for (TextEditingController c in _weightControllers) {
      c.dispose();
    }

    setState(() {
      _sessionStarted = false;
      _exercises = [];
      _repsControllers = [];
      _weightControllers = [];
      _exerciseNameController.clear();
    });
  }

  void _addExercise() {
    String name = _exerciseNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _exercises.add(Exercise(name: name));
      _repsControllers.add(TextEditingController());
      _weightControllers.add(TextEditingController());
      _exerciseNameController.clear();
    });
  }

  void _addSet(int exerciseIndex) {
    String reps = _repsControllers[exerciseIndex].text.trim();
    String weight = _weightControllers[exerciseIndex].text.trim();
    if (reps.isEmpty || weight.isEmpty) return;

    setState(() {
      _exercises[exerciseIndex].sets.add(
        WorkoutSet(reps: reps, weight: weight),
      );
      _repsControllers[exerciseIndex].clear();
      _weightControllers[exerciseIndex].clear();
    });
  }

  void _removeExercise(int index) {
    _repsControllers[index].dispose();
    _weightControllers[index].dispose();

    setState(() {
      _exercises.removeAt(index);
      _repsControllers.removeAt(index);
      _weightControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: const [
            Icon(Icons.fitness_center, color: Color(0xFF00E676), size: 26),
            SizedBox(width: 10),
            Text(
              'Gym Tracker',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          if (_sessionStarted)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _resetSession,
                icon: const Icon(Icons.refresh, color: Color(0xFF00E676)),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSessionCard(
              sessionStarted: _sessionStarted,
              exercises: _exercises,
              onStart: _startSession,
              onReset: _resetSession,
            ),
            const SizedBox(height: 14),

            if (_sessionStarted) ...[
              buildAddExerciseRow(
                controller: _exerciseNameController,
                onAdd: _addExercise,
              ),
              const SizedBox(height: 14),
              const Text(
                'EXERCISES',
                style: TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: _exercises.isEmpty
                    ? buildEmptyHint()
                    : ListView.builder(
                        itemCount: _exercises.length,
                        itemBuilder: (BuildContext context, int index) {
                          return buildExerciseCard(
                            index: index,
                            exercise: _exercises[index],
                            repsController: _repsControllers[index],
                            weightController: _weightControllers[index],
                            onAddSet: _addSet,
                            onRemove: _removeExercise,
                          );
                        },
                      ),
              ),
            ],

            if (!_sessionStarted) Expanded(child: buildWelcome()),
          ],
        ),
      ),
    );
  }
}
