import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../services/settings_provider.dart';
import '../../services/mesh_service.dart';
import 'package:hive/hive.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'group_settings_screen.dart';
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
  final _searchController = TextEditingController();
  final _audioRecorder = AudioRecorder();
  final _imagePicker = ImagePicker();
  final _audioPlayer = AudioPlayer();
  final _translator = GoogleTranslator();
  final _storageService = StorageService();
  final _meshService = MeshService();

  bool _isRecording = false;
  bool _isSearching = false;
  bool _isMeshEnabled = false;
  List<dynamic> _members = [];
  Map<String, String> _translations = {};
  bool _isAdmin = false;

  late final Stream<List<Map<String, dynamic>>> _messagesStream;
  List<Map<String, dynamic>> _cachedMessages = [];

  @override
  void initState() {
    super.initState();
    _loadCachedMessages();
    _fetchMembers();
    _initMesh();
    _messagesStream = _supabase
        .from('family_messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', widget.groupId)
        .order('created_at', ascending: false);
    _checkAdminStatus();
    _updatePresence();
  }

  void _checkAdminStatus() async {
    final res = await _supabase.from('family_members').select('role').eq('group_id', widget.groupId).eq('user_id', _supabase.auth.currentUser!.id).single();
    setState(() { _isAdmin = res['role'] == 'admin'; });
  }

  void _updatePresence() {
     _supabase.from('city_presence').upsert({
       'user_id': _supabase.auth.currentUser!.id,
       'last_seen': DateTime.now().toIso8601String(),
       'is_online': true,
     });
  }

  void _loadCachedMessages() {
    final box = Hive.box('cache');
    final data = box.get('chat_${widget.groupId}');
    if (data != null) {
      setState(() { _cachedMessages = List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e))); });
    }
  }

  void _initMesh() async {
    final name = _supabase.auth.currentUser?.email?.split('@')[0] ?? "User";
    _meshService.startMesh(name, (sender, message) {
      if (mounted) {
        setState(() {
          // If we receive a mesh message, add it to our cached list if we're in mesh mode
          if (_isMeshEnabled) {
             _cachedMessages.insert(0, {
               'sender_id': 'mesh_$sender',
               'message': message,
               'type': 'text',
               'created_at': DateTime.now().toIso8601String(),
               'plan_data': {'mesh': true}
             });
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("MESH [$sender]: $message"),
          backgroundColor: Colors.blueGrey,
        ));
      }
    });
  }

  Future<void> _fetchMembers() async {
    try {
      final data = await _supabase.from('family_members').select('profiles_quakesafe(id, full_name)').eq('group_id', widget.groupId);
      setState(() { _members = data; });
    } catch (_) {}
  }

  Future<void> _sendMessage({
    String type = 'text',
    String? message,
    String? mediaUrl,
    double? lat,
    double? lng,
  }) async {
    final content = message ?? _messageController.text.trim();
    if (content.isEmpty && type == 'text' && mediaUrl == null) return;

    if (_isMeshEnabled) {
      _meshService.sendMeshMessage(content);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mesaj Mesh üzerinden gönderildi.")));
      if (type == 'text') _messageController.clear();
      return;
    }

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
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _imagePicker.pickImage(source: source);
    if (image != null) {
      final url = await _storageService.uploadImage(File(image.path));
      if (url != null) _sendMessage(type: 'image', message: "📸 Fotoğraf", mediaUrl: url);
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
            _mediaOption(Icons.image, "Galeri", Colors.blue, () => _pickImage(ImageSource.gallery)),
            _mediaOption(Icons.camera_alt, "Kamera", Colors.red, () => _pickImage(ImageSource.camera)),
            _mediaOption(Icons.location_on, "Konum", Colors.green, () async {
              Position pos = await Geolocator.getCurrentPosition();
              _sendMessage(type: 'location', message: "📍 Konum paylaşıldı", lat: pos.latitude, lng: pos.longitude);
            }),
          ],
        ),
      ),
    );
  }

  Widget _mediaOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () { Navigator.pop(context); onTap(); },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), radius: 30, child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final userLangCode = settings.language == "Türkçe" ? "tr" : "en";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Mesaj ara...", border: InputBorder.none, hintStyle: TextStyle(color: Colors.white54)),
              onChanged: (v) => setState(() {}),
            )
          : GestureDetector(
              onTap: _showGroupDetails,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.groupName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text("Grup bilgileri için tıklayın", style: TextStyle(fontSize: 10, color: Colors.white54)),
                ],
              ),
            ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white), onPressed: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) _searchController.clear();
          })),
          IconButton(
            icon: Icon(_isMeshEnabled ? Icons.wifi_tethering : Icons.wifi_tethering_off, color: _isMeshEnabled ? Colors.green : Colors.white),
            onPressed: _toggleMesh,
            tooltip: "Mesh (Çevrimdışı) Modu",
          ),
          IconButton(icon: const Icon(Icons.phone, color: Colors.white), onPressed: () => _startCall(false)),
          IconButton(icon: const Icon(Icons.videocam, color: Colors.white), onPressed: () => _startCall(true)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final box = Hive.box('cache');
                  box.put('chat_${widget.groupId}', snapshot.data!);
                }

                var messages = snapshot.hasData ? snapshot.data! : _cachedMessages;
                if (messages.isEmpty && !snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.purple));

                if (_isSearching && _searchController.text.isNotEmpty) {
                  messages = messages.where((m) => (m['message']?.toString() ?? "").toLowerCase().contains(_searchController.text.toLowerCase())).toList();
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['sender_id'] == _supabase.auth.currentUser!.id;
                    return _buildMessageBubble(msg, isMe, userLangCode);
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

  void _toggleMesh() {
    setState(() {
      _isMeshEnabled = !_isMeshEnabled;
      if (!_isMeshEnabled) _meshService.stopMesh();
      else _initMesh();
    });
  }

  void _startCall(bool isVideo) {
    _sendMessage(
      type: 'text',
      message: isVideo ? "📹 Görüntülü arama başlatıldı" : "📞 Sesli arama başlatıldı",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 60, child: Icon(Icons.group, size: 60)),
            const SizedBox(height: 20),
            Text(widget.groupName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(isVideo ? "Görüntülü Arama Başlatılıyor..." : "Sesli Arama Başlatılıyor...", style: const TextStyle(color: Colors.white54)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(backgroundColor: Colors.red, radius: 35, child: IconButton(icon: const Icon(Icons.call_end, color: Colors.white), onPressed: () => Navigator.pop(context))),
                if (isVideo) CircleAvatar(backgroundColor: Colors.white10, radius: 35, child: IconButton(icon: const Icon(Icons.videocam_off, color: Colors.white), onPressed: () {})),
                CircleAvatar(backgroundColor: Colors.white10, radius: 35, child: IconButton(icon: const Icon(Icons.mic_off, color: Colors.white), onPressed: () {})),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, String userLang) {
    bool isEdited = msg['plan_data'] != null && msg['plan_data']['edited'] == true;
    bool isRead = msg['plan_data'] != null && msg['plan_data']['read'] == true;
    String? translatedText = _translations[msg['id'].toString()];

    // Mark as read if not me and not already read
    if (!isMe && !isRead) {
       _supabase.from('family_messages').update({'plan_data': {...(msg['plan_data'] ?? {}), 'read': true}}).eq('id', msg['id']);
    }

    return GestureDetector(
      onLongPress: isMe ? () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (context) => Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("Düzenle", style: TextStyle(color: Colors.white)), onTap: () {
              Navigator.pop(context);
              _editMessage(msg['id'].toString(), msg['message']);
            }),
            ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Sil", style: TextStyle(color: Colors.white)), onTap: () {
              Navigator.pop(context);
              _supabase.from('family_messages').delete().eq('id', msg['id']);
            }),
            const SizedBox(height: 20),
          ]),
        );
      } : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.fromLTRB(isMe ? 50 : 16, 4, isMe ? 16 : 50, 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? Colors.purple : const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 18),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (msg['type'] == 'image' && msg['media_url'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _showFullImage(msg['media_url']),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(msg['media_url'], loadingBuilder: (context, child, loading) => loading == null ? child : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))),
                  ),
                ),
              ),
            if (msg['type'] == 'text')
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (msg['type'] == 'text') Text(msg['message'] ?? "", style: const TextStyle(color: Colors.white)),
                if (translatedText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text("🌍 $translatedText", style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isEdited) const Text("düzenlendi • ", style: TextStyle(fontSize: 10, color: Colors.white38)),
                    GestureDetector(
                      onTap: () async {
                        final textToTranslate = msg['type'] == 'text' ? msg['message'] : "Fotoğraf";
                        final t = await _translator.translate(textToTranslate, to: userLang);
                        setState(() { _translations[msg['id'].toString()] = t.text; });
                      },
                      child: const Text("Çevir", style: TextStyle(fontSize: 10, color: Colors.white54, decoration: TextDecoration.underline)),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(isRead ? Icons.done_all : Icons.done, size: 12, color: isRead ? Colors.blue : Colors.white54),
                    ]
                  ],
                ),
              ])
            else if (msg['type'] == 'location')
              InkWell(
                onTap: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${msg['lat']},${msg['lng']}")),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_on, color: Colors.white, size: 16), Text(" Konumu Gör", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline))])
              )
            else if (msg['type'] == 'audio')
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: () => _audioPlayer.play(UrlSource(msg['media_url']))
                  ),
                  const Text("Sesli Mesaj", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
          ]),
        ),
      ),
    );
  }

  Future<void> _downloadImage(String url) async {
    try {
      if (await Permission.storage.request().isGranted || await Permission.photos.request().isGranted) {
        final dir = await getExternalStorageDirectory();
        if (dir == null) return;

        final String fileName = "QuakeSafe_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final String savePath = "${dir.path}/$fileName";

        await Dio().download(url, savePath);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Görüntü indirildi: $savePath")));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İndirme hatası: $e")));
    }
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(child: Image.network(url)),
            Positioned(top: 40, left: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 30), onPressed: () => Navigator.pop(context))),
            Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.download, color: Colors.white, size: 30), onPressed: () => _downloadImage(url))),
          ],
        ),
      ),
    );
  }

  void _showGroupDetails() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => FamilyGroupSettingsScreen(groupId: widget.groupId, groupName: widget.groupName, isAdmin: _isAdmin)));
  }

  void _editMessage(String id, String current) {
    final c = TextEditingController(text: current);
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text("Mesajı Düzenle", style: TextStyle(color: Colors.white)),
      content: TextField(controller: c, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.white70))),
        TextButton(onPressed: () async {
          await _supabase.from('family_messages').update({'message': c.text, 'plan_data': {'edited': true}}).eq('id', id);
          Navigator.pop(context);
        }, child: const Text("Kaydet", style: TextStyle(color: Colors.purple))),
      ],
    ));
  }

  Widget _buildInput() {
    bool showMentions = _messageController.text.contains('@');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMentions && _members.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            color: const Color(0xFF1E1E1E),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index]['profiles_quakesafe'];
                return ListTile(
                  title: Text(member['full_name'] ?? "Bilinmiyor", style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    final text = _messageController.text;
                    final lastAt = text.lastIndexOf('@');
                    setState(() {
                      _messageController.text = text.substring(0, lastAt + 1) + member['full_name'] + " ";
                      _messageController.selection = TextSelection.fromPosition(TextPosition(offset: _messageController.text.length));
                    });
                  },
                );
              },
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
          decoration: const BoxDecoration(color: Color(0xFF1A1A1A), border: Border(top: BorderSide(color: Colors.white10))),
          child: Row(children: [
            IconButton(icon: const Icon(Icons.add_circle, color: Colors.purple), onPressed: _showMediaMenu),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)),
                child: TextField(
                  controller: _messageController,
                  onChanged: (v) => setState(() {}),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: _isRecording ? "Kaydediliyor..." : "Mesaj...", border: InputBorder.none, hintStyle: const TextStyle(color: Colors.white54))
                )
              )
            ),
            if (_messageController.text.isEmpty && !_isRecording)
              GestureDetector(
                onLongPressStart: (_) => _startRecording(),
                onLongPressEnd: (_) => _stopRecording(),
                child: const Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.mic, color: Colors.purple)),
              )
            else if (_isRecording)
              const Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red)))
            else
              IconButton(icon: const Icon(Icons.send, color: Colors.purple), onPressed: () => _sendMessage()),
          ]),
        ),
      ],
    );
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/temp_audio.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);
      setState(() { _isRecording = true; });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    setState(() { _isRecording = false; });
    if (path != null) {
      final url = await _storageService.uploadAudio(File(path));
      if (url != null) _sendMessage(type: 'audio', message: "🎤 Sesli Mesaj", mediaUrl: url);
    }
  }
}
