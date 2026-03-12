import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const ChatScreen({super.key, required this.groupId, required this.groupName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  late final Stream<List<Map<String, dynamic>>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = _supabase
        .from('family_messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', widget.groupId)
        .order('created_at', ascending: false);
  }

  Future<void> _sendMessage({String type = 'text', String? content}) async {
    final text = content ?? _messageController.text.trim();
    if (text.isEmpty && type == 'text') return;
    if (type == 'text') _messageController.clear();

    try {
      await _supabase.from('family_messages').insert({
        'group_id': widget.groupId,
        'user_id': _supabase.auth.currentUser!.id,
        'message_type': type,
        'content': text,
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mesaj gönderilemedi: $e")));
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/voice_msg_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      // In a real app, upload the file to Supabase storage first
      // For now, we'll just send a placeholder message
      _sendMessage(type: 'voice', content: "Sesli mesaj (Placeholder)");
    }
  }

  void _showMediaMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _mediaOption(Icons.image, "Galeri", Colors.blue, () {}),
            _mediaOption(Icons.location_on, "Konum", Colors.green, () => _sendMessage(type: 'location', content: "Mevcut Konum")),
            _mediaOption(Icons.camera_alt, "Kamera", Colors.red, () {}),
          ],
        ),
      ),
    );
  }

  Widget _mediaOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showGroupInfo() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => GroupInfoScreen(groupId: widget.groupId, groupName: widget.groupName)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showGroupInfo,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.groupName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Grup bilgisi için dokunun", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Hata: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purple));
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['user_id'] == _supabase.auth.currentUser!.id;
                    return _buildMessageBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(isMe ? 50 : 16, 4, isMe ? 16 : 50, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (msg['message_type'] == 'text')
              Text(msg['content'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 15))
            else if (msg['message_type'] == 'location')
              Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, color: Colors.white, size: 16), const SizedBox(width: 5), Text(msg['content'] ?? "Konum paylaşıldı", style: const TextStyle(color: Colors.white))])
            else if (msg['message_type'] == 'voice')
              const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.mic, color: Colors.white, size: 16), SizedBox(width: 5), Text("Sesli mesaj", style: TextStyle(color: Colors.white))]),
            const SizedBox(height: 4),
            Text(msg['created_at'].toString().substring(11, 16), style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add_circle, color: Colors.purple, size: 28), onPressed: _showMediaMenu),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Mesaj yazın...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
              ),
            ),
          ),
          GestureDetector(
            onLongPress: _startRecording,
            onLongPressUp: _stopRecording,
            child: IconButton(
              icon: Icon(_isRecording ? Icons.fiber_manual_record : Icons.mic, color: _isRecording ? Colors.red : Colors.purple),
              onPressed: () {}, // Handled by long press
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.purple), onPressed: () => _sendMessage()),
        ],
      ),
    );
  }
}

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  const GroupInfoScreen({super.key, required this.groupId, required this.groupName});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _members = [];
  Map<String, dynamic>? _group;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    try {
      final groupData = await _supabase.from('family_groups').select().eq('id', widget.groupId).single();
      final memberData = await _supabase.from('family_members').select('*, profiles_quakesafe(*)').eq('group_id', widget.groupId);
      setState(() {
        _group = groupData;
        _members = memberData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Grup Bilgisi"), backgroundColor: Colors.black),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(radius: 40, backgroundColor: Colors.purple, child: Icon(Icons.group, size: 40, color: Colors.white)),
                const SizedBox(height: 15),
                Text(_group?['name'] ?? widget.groupName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Davet Kodu: ${_group?['invite_code'] ?? '...'}", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),
                _sectionHeader("Üyeler (${_members.length})"),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index]['profiles_quakesafe'];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: member['avatar_url'] != null ? NetworkImage(member['avatar_url']) : null, child: member['avatar_url'] == null ? const Icon(Icons.person) : null),
                      title: Text(member['full_name'] ?? "Bilinmiyor", style: const TextStyle(color: Colors.white)),
                      subtitle: Text(_members[index]['role'] == 'admin' ? "Yönetici" : "Üye", style: TextStyle(color: Colors.purple[200], fontSize: 12)),
                      trailing: const Icon(Icons.info_outline, color: Colors.grey, size: 18),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _sectionHeader("Acil Durum"),
                _infoItem(Icons.location_on, "Ev Konumu", _group?['location']),
                _infoItem(Icons.map, "Toplanma Alanı", _group?['assembly_area']),
              ],
            ),
          ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withValues(alpha: 0.05),
      child: Text(title, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoItem(IconData icon, String label, String? value) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      subtitle: Text(value ?? "Belirtilmemiş", style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }
}
