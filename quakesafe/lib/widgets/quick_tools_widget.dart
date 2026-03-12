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
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text("HIZLI ARAÇLAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white54, letterSpacing: 1.2)),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildToolButton(
                icon: Icons.campaign,
                label: "SİREN",
                onTap: () => _playSound("siren", "sounds/siren.mp3"),
                active: _currentlyPlaying == "siren",
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.flashlight_on,
                label: "FENER",
                onTap: _toggleFlash,
                active: _isFlashOn,
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.flash_on,
                label: "ÇAKAR",
                onTap: _toggleSos,
                active: _isSosActive,
              ),
              const SizedBox(width: 12),
              _buildToolButton(
                icon: Icons.record_voice_over,
                label: "DÜDÜK",
                onTap: () => _playSound("whistle", "sounds/whistle.mp3"),
                active: _currentlyPlaying == "whistle",
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
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: active ? Colors.purple.withValues(alpha: 0.2) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: active ? Colors.purple : Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.purple : Colors.white38, size: 28),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? Colors.white : Colors.white24, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
