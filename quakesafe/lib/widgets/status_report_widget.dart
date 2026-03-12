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
    final settings = Provider.of<SettingsProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppTranslations.t('status_report', settings.language), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => reportStatus(context, true),
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(AppTranslations.t('safe', settings.language), style: const TextStyle(color: Colors.white)),
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
                  onPressed: () => reportStatus(context, false),
                  icon: const Icon(Icons.warning, color: Colors.white),
                  label: Text(AppTranslations.t('help', settings.language), style: const TextStyle(color: Colors.white)),
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
