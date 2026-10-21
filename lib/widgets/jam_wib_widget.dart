import 'dart:async';
import 'package:flutter/material.dart';

class JamWibWidget extends StatelessWidget {
  const JamWibWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream:
          Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final jam = now.hour.toString().padLeft(2, '0');
        final menit = now.minute.toString().padLeft(2, '0');

        return Row(
          children: [
            Text(
              "$jam:$menit",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              "WIB",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
