import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../services/settings_provider.dart';
import '../services/auth_service.dart';
import '../translations.dart';

class CityChatScreen extends StatefulWidget {
  const CityChatScreen({super.key});

  @override
  State<CityChatScreen> createState() => _CityChatScreenState();
}

class _CityChatScreenState extends State<CityChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  final _messageController = TextEditingController();

  String? _userCity;
  late final Stream<List<Map<String, dynamic>>> _generalStream;
  late final Stream<List<Map<String, dynamic>>> _cityStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final profile = _authService.getLocalProfile();
    _userCity = profile?['city'];

    _generalStream = _supabase
        .from('city_chat_messages')
        .stream(primaryKey: ['id'])
        .eq('is_general', true)
        .order('created_at', ascending: false)
        .limit(50);

    if (_userCity != null) {
      _cityStream = _supabase
          .from('city_chat_messages')
          .stream(primaryKey: ['id'])
          .eq('city', _userCity!)
          .eq('is_general', false)
          .order('created_at', ascending: false)
          .limit(50);
    } else {
       _cityStream = const Stream.empty();
    }
  }

  Future<void> _sendMessage({bool isGeneral = true, String? type = 'text', double? lat, double? lng}) async {
    final content = _messageController.text.trim();
    if (content.isEmpty && type == 'text') return;

    final userId = _supabase.auth.currentUser!.id;
    final profile = _authService.getLocalProfile();

    try {
      await _supabase.from('city_chat_messages').insert({
        'sender_id': userId,
        'sender_name': profile?['full_name'] ?? "Anonim",
        'message': type == 'location' ? "📍 Konum paylaşıldı" : content,
        'type': type,
        'lat': lat,
        'lng': lng,
        'is_general': isGeneral,
        'city': isGeneral ? null : _userCity,
      });
      _messageController.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('city_chat', lang)),
        backgroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.purple,
          tabs: [
            Tab(text: AppTranslations.t('general', lang)),
            Tab(text: _userCity ?? AppTranslations.t('local', lang)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(_generalStream, true),
          _userCity == null
            ? Center(child: Text("Lütfen profilinizden şehir seçiniz.", style: TextStyle(color: Colors.white54)))
            : _buildChatList(_cityStream, false),
        ],
      ),
    );
  }

  Widget _buildChatList(Stream<List<Map<String, dynamic>>> stream, bool isGeneral) {
    return Column(
      children: [
        _buildSafetyWarning(),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              final messages = snapshot.data ?? [];
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
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
        _buildInput(isGeneral),
      ],
    );
  }

  Widget _buildSafetyWarning() {
    final settings = Provider.of<SettingsProvider>(context);
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.orange.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(AppTranslations.t('chat_safety_warning', settings.language), style: const TextStyle(color: Colors.orange, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
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
            if (!isMe) Text(msg['sender_name'] ?? "Anonim", style: const TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            if (msg['type'] == 'location')
              InkWell(
                onTap: () => launchUrl(Uri.parse("https://www.google.com/maps/search/?api=1&query=${msg['lat']},${msg['lng']}")),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.location_on, color: Colors.white, size: 16), Text(" Konumu Gör", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline))])
              )
            else
              Text(msg['message'] ?? "", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg['created_at']),
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return "";
    final dt = DateTime.parse(iso).toLocal();
    return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildInput(bool isGeneral) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      decoration: const BoxDecoration(color: Color(0xFF121212)),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.purple),
            onPressed: () async {
              Position pos = await Geolocator.getCurrentPosition();
              _sendMessage(isGeneral: isGeneral, type: 'location', lat: pos.latitude, lng: pos.longitude);
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
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
            onPressed: () => _sendMessage(isGeneral: isGeneral),
          ),
        ],
      ),
    );
  }
}
