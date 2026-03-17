import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';

class EmergencyOverlay extends StatefulWidget {
  final String title;
  final String message;
  const EmergencyOverlay({super.key, required this.title, required this.message});

  @override
  State<EmergencyOverlay> createState() => _EmergencyOverlayState();
}

class _EmergencyOverlayState extends State<EmergencyOverlay> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playAlarm();
  }

  void _playAlarm() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/emergency_alarm.mp3'));
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.withValues(alpha: 0.95),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 120)
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 500.ms)
                .tint(color: Colors.yellow),
            const SizedBox(height: 40),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: const Text("KAPAT / CLOSE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
