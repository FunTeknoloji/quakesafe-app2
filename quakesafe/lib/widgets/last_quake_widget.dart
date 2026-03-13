import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../translations.dart';
import '../screens/earthquakes/earthquakes_screen.dart';

class LastQuakeWidget extends StatefulWidget {
  const LastQuakeWidget({super.key});

  @override
  State<LastQuakeWidget> createState() => _LastQuakeWidgetState();
}

class _LastQuakeWidgetState extends State<LastQuakeWidget> {
  dynamic _lastQuake;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLastQuake();
  }

  Future<void> _fetchLastQuake() async {
    try {
      final response = await http.get(Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live?limit=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['result'] != null && data['result'].isNotEmpty) {
          if (mounted) {
            setState(() {
              _lastQuake = data['result'][0];
              _isLoading = false;
            });
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

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
              Row(
                children: [
                  const Icon(Icons.waves, color: Colors.white24, size: 20),
                  const SizedBox(width: 12),
                  Text(AppTranslations.t('last_quakes', lang).toUpperCase(),
                    style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EarthquakesScreen())),
                child: Text(lang == "Türkçe" ? "Tümü" : "All", style: const TextStyle(color: Colors.purple, fontSize: 12))
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.purple))
          else if (_lastQuake == null)
            const Text("Veri alınamadı.", style: TextStyle(color: Colors.white24, fontSize: 12))
          else
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EarthquakesScreen())),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161616),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getMagColor(double.tryParse(_lastQuake['mag'].toString()) ?? 0).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Text("${_lastQuake['mag']}",
                        style: TextStyle(color: _getMagColor(double.tryParse(_lastQuake['mag'].toString()) ?? 0), fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_lastQuake['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(_lastQuake['date_time'], style: const TextStyle(color: Colors.white24, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white12, size: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getMagColor(double mag) {
    if (mag < 3.0) return Colors.greenAccent;
    if (mag < 5.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
