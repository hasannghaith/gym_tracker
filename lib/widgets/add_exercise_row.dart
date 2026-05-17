import 'package:flutter/material.dart';

class AddExerciseRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const AddExerciseRow({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add exercise (e.g. Bench Press)',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
              prefixIcon: const Icon(Icons.add_circle_outline, color: Color(0xFF00E676), size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Icon(Icons.add, size: 26),
        ),
      ],
    );
  }
}
