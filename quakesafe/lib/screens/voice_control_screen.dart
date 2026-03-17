import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:torch_light/torch_light.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../translations.dart';
import 'earthquakes/earthquakes_screen.dart';
import 'widgets/status_report_widget.dart';

class VoiceControlScreen extends StatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  State<VoiceControlScreen> createState() => _VoiceControlScreenState();
}

class _VoiceControlScreenState extends State<VoiceControlScreen> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Dinlemek için butona basın";
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _pulseController = AnimationController(vsync: this, duration: 1000.ms);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _pulseController.repeat(reverse: true);
        _speech.listen(onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) {
              _handleCommand(_text.toLowerCase());
              _stopListening();
            }
          });
        });
      }
    } else {
      _stopListening();
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _pulseController.stop();
    _speech.stop();
  }

  void _handleCommand(String cmd) {
    if (cmd.contains("feneri aç") || cmd.contains("ışığı aç")) {
      TorchLight.enableTorch();
    } else if (cmd.contains("feneri kapat") || cmd.contains("ışığı kapat")) {
      TorchLight.disableTorch();
    } else if (cmd.contains("deprem") || cmd.contains("quakes")) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const EarthquakesScreen()));
    } else if (cmd.contains("yardım") || cmd.contains("help")) {
      StatusReportWidget.reportStatus(context, false);
    } else if (cmd.contains("güvendeyim") || cmd.contains("safe")) {
      StatusReportWidget.reportStatus(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('voice_assistant', lang)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            _buildVisualizer(),
            const SizedBox(height: 60),
            Text(
              _text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ).animate(target: _isListening ? 1 : 0).fadeIn().scale(),
            const SizedBox(height: 20),
            const Text(
              "Örn: 'Feneri aç', 'Yardım iste', 'Depremleri göster'",
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _listen,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red : Colors.purple,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.purple).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: _isListening ? 10 : 0,
                    )
                  ],
                ),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizer() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              double scale = 0.2 + (index * 0.15) + (_pulseController.value * 0.5);
              if (!_isListening) scale = 0.2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 6,
                height: 60 * scale,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
