import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.sports_gymnastics, color: Colors.white10, size: 90),
          SizedBox(height: 18),
          Text(
            'Press Start to begin\nyour training session!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 18, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
