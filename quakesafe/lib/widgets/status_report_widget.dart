import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
          SnackBar(
            content: Text(isSafe ? "Güvende olduğunuz bildirildi." : "Yardım talebi gönderildi!"),
            backgroundColor: isSafe ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e"), behavior: SnackBarBehavior.floating));
      }
    }
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
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.purple, size: 24),
              SizedBox(width: 12),
              Text("Güvenlik Durumu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          const Text("AİLENİZE DURUMUNUZU ANLIK OLARAK BİLDİRİN", style: TextStyle(fontSize: 9, color: Colors.white24, letterSpacing: 0.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: _statusBtn(
                  context,
                  true,
                  "GÜVENDEYİM",
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _statusBtn(
                  context,
                  false,
                  "YARDIM LAZIM",
                  Icons.warning_rounded,
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
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1000.ms),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
