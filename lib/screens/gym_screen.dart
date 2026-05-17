import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../data/api_service.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  bool _sessionStarted = false;
  bool _isLoading = false;
  List<Exercise> _exercises = [];
  Session? _currentSession;
  Session? _lastSession;

  final ApiService _apiService = ApiService();

  final TextEditingController _exerciseNameController =
      TextEditingController();
  List<TextEditingController> _repsControllers = [];
  List<TextEditingController> _weightControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchLastSession();
  }

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

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _fetchLastSession() async {
    try {
      final sessions = await _apiService.getSessions();
      final withExercises = sessions.where((s) => s.exerciseCount > 0).toList();
      if (withExercises.isNotEmpty && mounted) {
        final detailed = await _apiService.getSession(withExercises.first.id!);
        setState(() {
          _lastSession = detailed;
        });
      }
    } catch (e) {
      // Silently fail — not critical
    }
  }

  Future<void> _continueLastSession() async {
    if (_lastSession == null || _lastSession!.id == null) return;

    _setLoading(true);
    try {
      // Reopen the session (clear ended_at if it was ended)
      final session = _lastSession!;

      setState(() {
        _currentSession = session;
        _sessionStarted = true;
        _exercises = session.exercises;
        _repsControllers = List.generate(
            session.exercises.length, (_) => TextEditingController());
        _weightControllers = List.generate(
            session.exercises.length, (_) => TextEditingController());
      });
    } catch (e) {
      _showError('Failed to continue session.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _startSession() async {
    _setLoading(true);
    try {
      final session = await _apiService.createSession();
      setState(() {
        _currentSession = session;
        _sessionStarted = true;
      });
    } catch (e) {
      _showError('Failed to start session. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _resetSession() async {
    _setLoading(true);
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
      _isLoading = false;
    });

    // Refresh last session after ending
    _fetchLastSession();
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

    _setLoading(true);
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
    } finally {
      _setLoading(false);
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

    _setLoading(true);
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
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _removeExercise(int index) async {
    final exercise = _exercises[index];

    if (exercise.id != null) {
      _setLoading(true);
      try {
        await _apiService.deleteExercise(exercise.id!);
      } catch (e) {
        _showError('Failed to remove exercise from server.');
      } finally {
        _setLoading(false);
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

  Widget _buildLastSessionCard() {
    if (_lastSession == null) return const SizedBox.shrink();

    final date = _formatDate(_lastSession!.startedAt);
    final exerciseNames = _lastSession!.exercises
        .map((e) => e.name)
        .take(3)
        .join(', ');
    final extra = _lastSession!.exercises.length > 3
        ? ' +${_lastSession!.exercises.length - 3} more'
        : '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LAST SESSION',
            style: TextStyle(
              color: Color(0xFF00E676),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${_lastSession!.exercises.length} exercise(s): $exerciseNames$extra',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _continueLastSession,
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Continue Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute';
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
                onPressed: _isLoading ? null : _resetSession,
                icon: const Icon(Icons.refresh, color: Color(0xFF00E676)),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SessionCard(
                  sessionStarted: _sessionStarted,
                  exercises: _exercises,
                  onStart: _isLoading ? () {} : _startSession,
                  onReset: _isLoading ? () {} : _resetSession,
                ),
                const SizedBox(height: 14),

                if (_sessionStarted) ...[
                  AddExerciseRow(
                    controller: _exerciseNameController,
                    onAdd: _isLoading ? () {} : _addExercise,
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
                        ? const EmptyHint()
                        : ListView.builder(
                            itemCount: _exercises.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ExerciseCard(
                                index: index,
                                exercise: _exercises[index],
                                repsController: _repsControllers[index],
                                weightController: _weightControllers[index],
                                onAddSet: _isLoading ? (i) {} : _addSet,
                                onRemove: _isLoading ? (i) {} : _removeExercise,
                              );
                            },
                          ),
                  ),
                ],

                if (!_sessionStarted) ...[
                  _buildLastSessionCard(),
                  const Expanded(child: Welcome()),
                ],
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00E676),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
