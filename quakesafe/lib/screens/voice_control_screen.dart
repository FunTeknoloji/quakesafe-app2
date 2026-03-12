import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:torch_light/torch_light.dart';

class VoiceControlScreen extends StatefulWidget {
  const VoiceControlScreen({super.key});

  @override
  State<VoiceControlScreen> createState() => _VoiceControlScreenState();
}

class _VoiceControlScreenState extends State<VoiceControlScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Dinlemek için butona basın";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) {
          setState(() {
            _text = val.recognizedWords;
            _handleCommand(_text.toLowerCase());
          });
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleCommand(String cmd) {
    if (cmd.contains("feneri aç") || cmd.contains("ışığı aç")) {
      TorchLight.enableTorch();
    } else if (cmd.contains("feneri kapat") || cmd.contains("ışığı kapat")) {
      TorchLight.disableTorch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Sesli Kontrol"), backgroundColor: Colors.black),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text, style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 50),
            FloatingActionButton(
              onPressed: _listen,
              backgroundColor: _isListening ? Colors.red : Colors.purple,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          ],
        ),
      ),
    );
  }
}
