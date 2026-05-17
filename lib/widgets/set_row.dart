import 'package:flutter/material.dart';
import '../models/models.dart';

class SetRow extends StatelessWidget {
  final int setIndex;
  final WorkoutSet workoutSet;

  const SetRow({
    super.key,
    required this.setIndex,
    required this.workoutSet,
  });

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.repeat, color: Colors.white38, size: 15),
          const SizedBox(width: 4),
          Text('${workoutSet.reps} reps', style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(width: 16),
          const Icon(Icons.monitor_weight_outlined, color: Colors.white38, size: 15),
          const SizedBox(width: 4),
          Text('${workoutSet.weight} kg', style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}
