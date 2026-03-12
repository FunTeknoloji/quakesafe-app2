import 'package:flutter/material.dart';
import '../../services/mesh_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class MeshNetworkScreen extends StatefulWidget {
  const MeshNetworkScreen({super.key});

  @override
  State<MeshNetworkScreen> createState() => _MeshNetworkScreenState();
}

class _MeshNetworkScreenState extends State<MeshNetworkScreen> {
  final _meshService = MeshService();
  final _supabase = Supabase.instance.client;
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();

  List<Map<String, String>> _meshMessages = [];
  bool _isMeshActive = false;
  bool _isTalking = false;

  @override
  void initState() {
    super.initState();
    _startMesh();
  }

  void _startMesh() async {
    final name = _supabase.auth.currentUser?.email?.split('@')[0] ?? "Kullanıcı";
    bool success = await _meshService.startMesh(name, (sender, message) {
      setState(() {
        _meshMessages.add({'sender': sender, 'message': message, 'type': 'text'});
      });
    });
    setState(() { _isMeshActive = success; });
  }

  void _sendMeshText(String text) {
    _meshService.sendMeshMessage(text);
    setState(() {
      _meshMessages.add({'sender': 'Ben', 'message': text, 'type': 'text'});
    });
  }

  Future<void> _shareLocation() async {
    Position pos = await Geolocator.getCurrentPosition();
    String loc = "Konumum: ${pos.latitude}, ${pos.longitude}";
    _sendMeshText(loc);
  }

  Future<void> _startTalking() async {
    if (await _audioRecorder.hasPermission()) {
      setState(() { _isTalking = true; });
      final dir = Directory.systemTemp;
      // Note: encoder: AudioEncoder.aacLow might not be available in all versions of 'record', using default
      await _audioRecorder.start(const RecordConfig(), path: '${dir.path}/ptt.m4a');
    }
  }

  Future<void> _stopTalking() async {
    final path = await _audioRecorder.stop();
    setState(() { _isTalking = false; });
    if (path != null) {
       _sendMeshText("🎤 [Bas-Konuş Mesajı]");
       // Real P2P audio streaming would require raw byte chunks,
       // for now we simulate the PTT flow by notifying the mesh.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mesh Ağı (Telsiz)", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          Icon(Icons.circle, color: _isMeshActive ? Colors.green : Colors.red, size: 12),
          const SizedBox(width: 20),
        ],
      ),
      body: Column(
        children: [
          _buildDiscoveryHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _meshMessages.length,
              itemBuilder: (context, index) {
                final m = _meshMessages[index];
                final isMe = m['sender'] == 'Ben';
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.purple : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text("${m['sender']}: ${m['message']}", style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          _buildPTTControls(),
        ],
      ),
    );
  }

  Widget _buildDiscoveryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.purple.withValues(alpha: 0.1),
      child: Row(
        children: [
          const CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Çevredeki Cihazlar Taranıyor...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text("İnternet gerekmez, 100 metre menzil.", style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.location_on, color: Colors.purple), onPressed: _shareLocation),
        ],
      ),
    );
  }

  Widget _buildPTTControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onLongPressStart: (_) => _startTalking(),
            onLongPressEnd: (_) => _stopTalking(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _isTalking ? Colors.red : Colors.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  if (_isTalking) BoxShadow(color: Colors.red.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, color: Colors.white, size: 40),
                  Text("BAS KONUŞ", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
