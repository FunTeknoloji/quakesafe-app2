import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

class FunAIScreen extends StatefulWidget {
  const FunAIScreen({super.key});

  @override
  State<FunAIScreen> createState() => _FunAIScreenState();
}

class _FunAIScreenState extends State<FunAIScreen> {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('ai_chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);
      setState(() {
        _messages = List<Map<String, dynamic>>.from(data);
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error loading AI messages: $e");
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final userId = _supabase.auth.currentUser!.id;
    final userMsg = {'user_id': userId, 'role': 'user', 'content': text};

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    await _supabase.from('ai_chat_messages').insert(userMsg);

    try {
      final response = await http.get(Uri.parse('https://text.pollinations.ai/${Uri.encodeComponent(text)}?model=openai&system=Sen%20QuakeSafe%20acil%20durum%20asistan%C4%B1s%C4%B1n.%20Temel%20odak%20noktan%20deprem%2C%20do%C4%9Fal%20afetler%2C%20ilk%20yard%C4%B1m%20ve%20acil%20durum%20haz%C4%B1rl%C4%B1%C4%9F%C4%B1d%C4%B1r.%20Cevaplar%C4%B1n%C4%B1%20k%C4%B1sa%2C%20%C3%B6z%20ve%20net%20ver.%20Maddeler%20halinde%20yaz.%20%C3%96nemli%20yerleri%20kal%C4%B1n%20yap.'));

      if (response.statusCode == 200) {
        final aiText = response.body;
        final aiMsg = {'user_id': userId, 'role': 'model', 'content': aiText};
        await _supabase.from('ai_chat_messages').insert(aiMsg);
        setState(() {
          _messages.add(aiMsg);
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() => _isTyping = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("FunAI Asistan"), backgroundColor: Colors.black),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return _buildTypingIndicator();
                final msg = _messages[index];
                return _buildBubble(msg['content'], msg['role'] == 'user');
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? Colors.purple : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    ).animate().fadeIn().slideX(begin: isMe ? 0.1 : -0.1, end: 0);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
        child: const Text("Yanıt yazılıyor...", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ),
    ).animate().shimmer();
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Bir soru sorun...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
            ),
          ),
          IconButton(icon: const Icon(Icons.send, color: Colors.purple), onPressed: _sendMessage),
        ],
      ),
    );
  }
}
