import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> _sendMessage({
    String type = 'text',
    String? message,
    String? mediaUrl,
    double? lat,
    double? lng,
    bool isLive = false,
    Map<String, dynamic>? planData,
  }) async {
    final content = message ?? _messageController.text.trim();
    if (content.isEmpty && type == 'text' && mediaUrl == null) return;
    if (type == 'text') _messageController.clear();

    try {
      await _supabase.from('family_messages').insert({
        'group_id': widget.groupId,
        'sender_id': _supabase.auth.currentUser!.id,
        'message': content,
        'type': type,
        'media_url': mediaUrl,
        'lat': lat,
        'lng': lng,
        'is_live': isLive,
        'plan_data': planData,
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() => _isRecording = false);
    if (path != null) {
      _sendMessage(type: 'audio', message: "Sesli mesaj");
    }
  }

  void _showMediaMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _mediaOption(Icons.image, "Galeri", Colors.blue, () {}),
            _mediaOption(Icons.location_on, "Konum", Colors.green, () => _sendMessage(type: 'location', message: "Konum paylaşıldı", lat: 0.0, lng: 0.0)),
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
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), radius: 30, child: Icon(icon, color: color, size: 28)),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GroupInfoScreen(groupId: widget.groupId, groupName: widget.groupName))),
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
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purple));
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == _supabase.auth.currentUser!.id;
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
            if (msg['type'] == 'text')
              Text(msg['message'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 15))
            else if (msg['type'] == 'location')
              Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, color: Colors.white, size: 16), const SizedBox(width: 5), Text(msg['message'] ?? "Konum", style: const TextStyle(color: Colors.white))])
            else if (msg['type'] == 'audio')
              const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.mic, color: Colors.white, size: 16), SizedBox(width: 5), Text("Sesli mesaj", style: TextStyle(color: Colors.white))])
            else if (msg['type'] == 'emergency_card')
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(10)), child: const Text("ACİL DURUM!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(height: 4),
            Text(msg['created_at'].toString().substring(11, 16), style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.purple, size: 30), onPressed: _showMediaMenu),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: _isRecording ? Colors.red : Colors.purple, shape: BoxShape.circle),
              child: Icon(_isRecording ? Icons.fiber_manual_record : Icons.mic, color: Colors.white),
            ),
          ),
          IconButton(icon: const Icon(Icons.send_rounded, color: Colors.purple, size: 30), onPressed: () => _sendMessage()),
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
                const SizedBox(height: 30),
                const CircleAvatar(radius: 50, backgroundColor: Color(0xFF1E1E1E), child: Icon(Icons.group, size: 50, color: Colors.purple)),
                const SizedBox(height: 15),
                Text(_group?['name'] ?? widget.groupName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text("KOD: ${_group?['invite_code']}", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 40),
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
                    );
                  },
                ),
                const SizedBox(height: 20),
                _sectionHeader("Konum Bilgileri"),
                _infoItem(Icons.location_on, "Şehir", _group?['city']),
                _infoItem(Icons.map, "Toplanma Noktası", _group?['meeting_point_text']),
              ],
            ),
          ),
    );
  }

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
