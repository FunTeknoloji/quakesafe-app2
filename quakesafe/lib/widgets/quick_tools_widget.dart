import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class QuickToolsWidget extends StatefulWidget {
  const QuickToolsWidget({super.key});

  @override
  State<QuickToolsWidget> createState() => _QuickToolsWidgetState();
}

class _QuickToolsWidgetState extends State<QuickToolsWidget> {
  bool _isFlashOn = false;
  bool _isSosActive = false;
  Timer? _sosTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _sosTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    try {
      if (_isFlashOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  void _toggleSos() {
    setState(() {
      _isSosActive = !_isSosActive;
      if (_isSosActive) {
        _sosTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
          if (timer.tick % 2 == 0) {
            TorchLight.enableTorch();
          } else {
            TorchLight.disableTorch();
          }
        });
      } else {
        _sosTimer?.cancel();
        TorchLight.disableTorch();
      }
    });
  }

  Future<void> _playSound(String soundName, String assetPath) async {
    try {
      if (_currentlyPlaying == soundName) {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlaying = null;
        });
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource(assetPath));
        setState(() {
          _currentlyPlaying = soundName;
        });
      }
    } catch (e) {
      debugPrint("Audio play error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Hızlı Araçlar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildToolButton(
                icon: _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
                label: "El Feneri",
                onTap: _toggleFlash,
                active: _isFlashOn,
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.emergency,
                label: "SOS Flash",
                onTap: _toggleSos,
                active: _isSosActive,
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.record_voice_over,
                label: "Düdük",
                onTap: () => _playSound("whistle", "sounds/whistle.mp3"),
                active: _currentlyPlaying == "whistle",
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.warning_rounded,
                label: "Siren",
                onTap: () => _playSound("siren", "sounds/siren.mp3"),
                active: _currentlyPlaying == "siren",
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.pets,
                label: "Köpek",
                onTap: () => _playSound("dog", "sounds/dog.mp3"),
                active: _currentlyPlaying == "dog",
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.campaign,
                label: "Tiz Ses",
                onTap: () => _playSound("high", "sounds/whistle.mp3"), // Placeholder
                active: _currentlyPlaying == "high",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: active ? Colors.purple : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}
