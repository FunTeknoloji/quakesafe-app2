import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class LastQuakeWidget extends StatelessWidget {
  const LastQuakeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.forum_outlined, color: Colors.white24, size: 20),
                  SizedBox(width: 12),
                  Text("SOHBETLER", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text("Tümü", style: TextStyle(color: Colors.purple, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.purple.withValues(alpha: 0.2),
                  child: const Text("E", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Erbay Ailesi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Row(
                        children: [
                          Icon(Icons.image_outlined, color: Colors.white24, size: 14),
                          SizedBox(width: 4),
                          Text("Fotoğraf", style: TextStyle(color: Colors.white24, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Text("18:07", style: TextStyle(color: Colors.white12, fontSize: 11)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.white12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
