import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../translations.dart';

class StatusReportWidget extends StatelessWidget {
  const StatusReportWidget({super.key});

  static Future<void> reportStatus(BuildContext? context, bool isSafe) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (_) {}

      final memberships = await supabase.from('family_members').select('group_id').eq('user_id', user.id);

      for (var membership in memberships) {
        await supabase.from('family_messages').insert({
          'group_id': membership['group_id'],
          'sender_id': user.id,
          'type': isSafe ? 'text' : 'location',
          'message': isSafe ? "Güvendeyim / I am Safe" : "YARDIM LAZIM / I NEED HELP (GPS Shared)",
          'lat': position?.latitude,
          'lng': position?.longitude,
        });
      }

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSafe ? "Güvende olduğunuz bildirildi." : "Yardım talebi gönderildi!")),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Durumunuz", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text("AİLENİZE GÜVENDE OLDUĞUNUZU BİLDİRİN", style: TextStyle(fontSize: 10, color: Colors.white24, letterSpacing: 1, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _statusBtn(
                  context,
                  true,
                  "GÜVENDEYİM",
                  Icons.verified_user_outlined,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statusBtn(
                  context,
                  false,
                  "YARDIM LAZIM",
                  Icons.report_problem_outlined,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBtn(BuildContext context, bool isSafe, String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => reportStatus(context, isSafe),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
