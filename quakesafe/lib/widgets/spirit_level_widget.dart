import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;

class SpiritLevelWidget extends StatefulWidget {
  const SpiritLevelWidget({super.key});

  @override
  State<SpiritLevelWidget> createState() => _SpiritLevelWidgetState();
}

class _SpiritLevelWidgetState extends State<SpiritLevelWidget> {
  double x = 0, y = 0;
  bool _hasSensor = true;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (mounted) {
          setState(() {
            x = event.x;
            y = event.y;
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
            const Text("Su Terazisi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (!_hasSensor)
              const Text("Cihazınızda ivmeölçer sensörü bulunamadı.", style: TextStyle(color: Colors.red))
            else
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        ),
                      ),
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 100),
                        alignment: Alignment(
                          (x / 10).clamp(-1.0, 1.0),
                          (y / 10).clamp(-1.0, 1.0),
                        ),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (_hasSensor)
              Text("X: ${x.toStringAsFixed(2)}  Y: ${y.toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }
}
