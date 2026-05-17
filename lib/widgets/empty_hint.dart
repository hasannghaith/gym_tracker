import 'package:flutter/material.dart';

class EmptyHint extends StatelessWidget {
  const EmptyHint({super.key});

  @override
  Widget build(BuildContext context) {
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
}
