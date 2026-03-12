import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await _supabase.from('notifications_quakesafe').select().order('created_at', ascending: false);
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _supabase.from('notifications_quakesafe').update({'is_read': true}).eq('id', id);
      _fetchNotifications();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _supabase.from('notifications_quakesafe').delete().eq('id', id);
      _fetchNotifications();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Bildirimler"), backgroundColor: Colors.black),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _notifications.isEmpty
              ? const Center(child: Text("Bildirim bulunamadı.", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    final isRead = notif['is_read'] ?? false;
                    return Dismissible(
                      key: Key(notif['id'].toString()),
                      background: Container(
                        color: Colors.red[900],
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteNotification(notif['id'].toString()),
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: isRead ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: isRead ? Colors.transparent : Colors.purple.withValues(alpha: 0.3))),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: (isRead ? Colors.grey : Colors.purple).withValues(alpha: 0.1), shape: BoxShape.circle),
                            child: Icon(Icons.notifications_active, color: isRead ? Colors.grey : Colors.purple),
                          ),
                          title: Text(notif['title'] ?? "Bildirim", style: TextStyle(color: Colors.white, fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notif['message'] ?? "", style: TextStyle(color: isRead ? Colors.grey : Colors.grey[300])),
                              const SizedBox(height: 5),
                              Text(notif['created_at'].toString().substring(0, 16), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          trailing: !isRead ? TextButton(onPressed: () => _markAsRead(notif['id'].toString()), child: const Text("Okundu", style: TextStyle(color: Colors.purple, fontSize: 12))) : null,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
