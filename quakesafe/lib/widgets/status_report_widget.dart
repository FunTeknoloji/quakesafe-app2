import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatusReportWidget extends StatelessWidget {
  const StatusReportWidget({super.key});

  Future<void> _reportStatus(BuildContext context, bool isSafe) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      // For now, we'll send a message to all groups the user is in
      final memberships = await supabase.from('family_members').select('group_id').eq('user_id', userId);

      for (var membership in memberships) {
        await supabase.from('family_messages').insert({
          'group_id': membership['group_id'],
          'user_id': userId,
          'message_type': isSafe ? 'status_safe' : 'status_help',
          'content': isSafe ? "Güvendeyim!" : "YARDIM LAZIM! (Konum paylaşıldı)",
          // Real apps would add lat/long here
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isSafe ? "Güvende olduğunuz bildirildi." : "Yardım talebi gönderildi!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Durum Bildirme", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _reportStatus(context, true),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text("Güvendeyim", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[900],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _reportStatus(context, false),
                  icon: const Icon(Icons.warning, color: Colors.white),
                  label: const Text("Yardım Lazım", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
