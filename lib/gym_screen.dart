import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';
import 'api_service.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  bool _sessionStarted = false;
  List<Exercise> _exercises = [];
  Session? _currentSession;

  final ApiService _apiService = ApiService();

  final TextEditingController _exerciseNameController =
      TextEditingController();
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];

  @override
  void dispose() {
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
      ),
    );
  }

  Future<void> _startSession() async {
    try {
      final session = await _apiService.createSession();
      setState(() {
        _currentSession = session;
        _sessionStarted = true;
      });
    } catch (e) {
      _showError('Failed to start session. Please try again.');
    }
  }

  Future<void> _resetSession() async {
    if (_currentSession?.id != null) {
      try {
        await _apiService.endSession(_currentSession!.id!, DateTime.now());
      } catch (e) {
        _showError('Failed to end session on server.');
      }
    }

    for (TextEditingController c in _repsControllers) {
      c.dispose();
    }
    for (TextEditingController c in _weightControllers) {
      c.dispose();
    }

    setState(() {
      _sessionStarted = false;
      _exercises = [];
      _currentSession = null;
      _repsControllers = [];
      _weightControllers = [];
      _exerciseNameController.clear();
    });
  }

  Future<void> _addExercise() async {
    String name = _exerciseNameController.text.trim();
    if (name.isEmpty) return;

    if (_currentSession?.id == null) {
      setState(() {
        _exercises.add(Exercise(name: name));
        _repsControllers.add(TextEditingController());
        _weightControllers.add(TextEditingController());
        _exerciseNameController.clear();
      });
      return;
    }

    try {
      final exercise =
          await _apiService.createExercise(_currentSession!.id!, name);
      setState(() {
        _exercises.add(exercise);
        _repsControllers.add(TextEditingController());
        _weightControllers.add(TextEditingController());
        _exerciseNameController.clear();
      });
    } catch (e) {
      _showError('Failed to add exercise. Please try again.');
    }
  }

  Future<void> _addSet(int exerciseIndex) async {
    String repsText = _repsControllers[exerciseIndex].text.trim();
    String weightText = _weightControllers[exerciseIndex].text.trim();
    if (repsText.isEmpty || weightText.isEmpty) return;

    int? reps = int.tryParse(repsText);
    double? weight = double.tryParse(weightText);
    if (reps == null || weight == null) return;

    final exercise = _exercises[exerciseIndex];

    if (exercise.id == null) {
      setState(() {
        _exercises[exerciseIndex].sets.add(
          WorkoutSet(reps: reps, weight: weight),
        );
        _repsControllers[exerciseIndex].clear();
        _weightControllers[exerciseIndex].clear();
      });
      return;
    }

    try {
      final workoutSet =
          await _apiService.createSet(exercise.id!, reps, weight);
      setState(() {
        _exercises[exerciseIndex].sets.add(workoutSet);
        _repsControllers[exerciseIndex].clear();
        _weightControllers[exerciseIndex].clear();
      });
    } catch (e) {
      _showError('Failed to add set. Please try again.');
    }
  }

  Future<void> _removeExercise(int index) async {
    final exercise = _exercises[index];

    if (exercise.id != null) {
      try {
        await _apiService.deleteExercise(exercise.id!);
      } catch (e) {
        _showError('Failed to remove exercise from server.');
      }
    }

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
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history, color: Color(0xFF00E676)),
          ),
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
