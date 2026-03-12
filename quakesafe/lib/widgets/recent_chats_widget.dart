import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../screens/family/chat_screen.dart';

class RecentChatsWidget extends StatefulWidget {
  const RecentChatsWidget({super.key});

  @override
  State<RecentChatsWidget> createState() => _RecentChatsWidgetState();
}

class _RecentChatsWidgetState extends State<RecentChatsWidget> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _recentChats = [];

  @override
  void initState() {
    super.initState();
    _fetchRecentChats();
  }

  Future<void> _fetchRecentChats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final memberships = await _supabase.from('family_members').select('group_id').eq('user_id', userId);
      final List<int> groupIds = memberships.map((m) => m['group_id'] as int).toList();

      if (groupIds.isEmpty) return;

      final response = await _supabase
          .from('family_groups')
          .select('id, name, family_messages(message, created_at, type)')
          .inFilter('id', groupIds);

      if (mounted) {
        setState(() {
          _recentChats = response;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.forum_outlined, color: Colors.white24, size: 20),
                  SizedBox(width: 12),
                  Text("SOHBETLER", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                ],
              ),
              TextButton(onPressed: () {}, child: const Text("Tümü", style: TextStyle(color: Colors.purple, fontSize: 12))),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentChats.isEmpty)
            const Text("Henüz aktif sohbet bulunmuyor.", style: TextStyle(color: Colors.white24, fontSize: 12))
          else
            ..._recentChats.map((chat) {
              final messages = List<dynamic>.from(chat['family_messages'] ?? []);
              messages.sort((a, b) => (b['created_at'] ?? "").compareTo(a['created_at'] ?? ""));

              final lastMsg = messages.isNotEmpty ? messages.first : null;
              final String timeStr = lastMsg != null ? DateFormat('HH:mm').format(DateTime.parse(lastMsg['created_at'])) : "";
              final String msgPreview = lastMsg != null
                ? (lastMsg['type'] == 'image' ? "📸 Fotoğraf" : lastMsg['message'] ?? "")
                : "Henüz mesaj yok";

              return GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(groupId: chat['id'].toString(), groupName: chat['name'])));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.withValues(alpha: 0.2),
                        child: Text(chat['name'][0].toUpperCase(), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chat['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(msgPreview, style: const TextStyle(color: Colors.white24, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Text(timeStr, style: const TextStyle(color: Colors.white12, fontSize: 11)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white12, size: 16),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
