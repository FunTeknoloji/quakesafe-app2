import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double _direction = 0;
  bool _hasSensor = true;

  @override
  void initState() {
    super.initState();
    magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        if (mounted) {
          setState(() {
            _direction = math.atan2(event.y, event.x) * (180 / math.pi);
            _hasSensor = true;
          });
        }
      },
      onError: (error) {
        setState(() {
          _hasSensor = false;
        });
      },
      cancelOnError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          if (!_hasSensor)
            const Center(
              child: Text(
                "CİHAZINIZDA PUSULA DESTEĞİ BULUNAMADI.",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Pusula", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
                    Text("${_direction.toStringAsFixed(0)}°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Transform.rotate(
                    angle: ((_direction ?? 0) * (math.pi / 180) * -1),
                    child: const Icon(Icons.explore, size: 80, color: Colors.purple),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
