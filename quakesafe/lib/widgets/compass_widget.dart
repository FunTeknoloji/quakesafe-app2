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
    magnetometerEvents.listen(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Pusula", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (!_hasSensor)
              const Text("Cihazınızda manyetometre sensörü bulunamadı.", style: TextStyle(color: Colors.red))
            else
              Center(
                child: Transform.rotate(
                  angle: ((_direction ?? 0) * (math.pi / 180) * -1),
                  child: const Icon(Icons.explore, size: 150, color: Colors.purple),
                ),
              ),
            const SizedBox(height: 10),
            if (_hasSensor)
              Text("${_direction.toStringAsFixed(0)}°", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
