import 'package:flutter/material.dart';
import '../models/models.dart';

class SessionCard extends StatelessWidget {
  final bool sessionStarted;
  final List<Exercise> exercises;
  final VoidCallback onStart;
  final VoidCallback onReset;

  const SessionCard({
    super.key,
    required this.sessionStarted,
    required this.exercises,
    required this.onStart,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    int totalSets = 0;
    for (Exercise ex in exercises) {
      totalSets += ex.sets.length;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: sessionStarted ? const Color(0xFF0D2B17) : const Color(0xFF1A1A1A),
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
                sessionStarted ? Icons.play_circle_fill : Icons.pause_circle_outline,
                color: sessionStarted ? const Color(0xFF00E676) : Colors.white30,
                size: 32,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sessionStarted ? 'Session Active' : 'Ready to Train?',
                    style: TextStyle(
                      color: sessionStarted ? const Color(0xFF00E676) : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (sessionStarted)
                    Text(
                      '${exercises.length} exercise(s)  •  $totalSets set(s)',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
        ],
      ),
    );
  }
}
