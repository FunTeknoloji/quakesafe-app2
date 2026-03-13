import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/mesh_service.dart';
import '../services/settings_provider.dart';
import '../translations.dart';

class MeshChatScreen extends StatefulWidget {
  const MeshChatScreen({super.key});

  @override
  State<MeshChatScreen> createState() => _MeshChatScreenState();
}

class _MeshChatScreenState extends State<MeshChatScreen> {
  final _meshService = MeshService();
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isMeshActive = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();
  }

  void _toggleMesh() async {
    if (_isMeshActive) {
      _meshService.stopMesh();
      setState(() => _isMeshActive = false);
    } else {
      final username = Supabase.instance.client.auth.currentUser?.email?.split('@')[0] ?? "User";
      bool success = await _meshService.startMesh(username, (sender, message) {
        setState(() {
          _messages.insert(0, {
            'sender': sender,
            'message': message,
            'time': DateTime.now(),
            'isMe': false,
          });
        });
      });
      if (success) {
        setState(() => _isMeshActive = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mesh başlatılamadı. Bluetooth ve Konum açık mı?")));
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _meshService.sendMeshMessage(text);
    setState(() {
      _messages.insert(0, {
        'sender': 'Ben',
        'message': text,
        'time': DateTime.now(),
        'isMe': true,
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('mesh_mode', lang)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isMeshActive ? Icons.stop_circle : Icons.play_circle, color: _isMeshActive ? Colors.red : Colors.green),
            onPressed: _toggleMesh,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lang == "Türkçe"
                      ? "Çevrimdışı mesajlaşma modu. İnternet gerekmez, Bluetooth ve Konum kullanır."
                      : "Offline messaging mode. No internet required, uses Bluetooth and Location.",
                    style: const TextStyle(color: Colors.blue, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'];
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) Text(msg['sender'], style: const TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(msg['message'], style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      decoration: const BoxDecoration(color: Color(0xFF121212)),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: _isMeshActive,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Mesaj yazın...",
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: _isMeshActive ? _sendMessage : null,
          ),
        ],
      ),
    );
  }
}
