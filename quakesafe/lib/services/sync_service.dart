import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'weather_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _weatherService = WeatherService();
  final _cache = Hive.box('cache');

  void startSync() {
    // Initial fetch
    performSync();

    // Periodic sync every 15 minutes
    Timer.periodic(const Duration(minutes: 15), (timer) {
      performSync();
    });
  }

  Future<void> performSync() async {
    await _syncQuakes();
    await _syncWeather();
  }

  Future<void> _syncQuakes() async {
    try {
      final response = await http.get(Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          _cache.put('offline_quakes', data['result']);
        }
      }
    } catch (_) {}
  }

  Future<void> _syncWeather() async {
    try {
      final data = await _weatherService.fetchWeather();
      if (data != null) {
        _cache.put('offline_weather', data);
      }
    } catch (_) {}
  }
}
