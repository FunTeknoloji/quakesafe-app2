import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final data = await _weatherService.fetchWeather();
    setState(() {
      _weatherData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Hava Durumu"), backgroundColor: Colors.black),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : _weatherData == null
          ? const Center(child: Text("Hava durumu bilgisi alınamadı.", style: TextStyle(color: Colors.grey)))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wb_cloudy_outlined, size: 100, color: Colors.purple),
                  const SizedBox(height: 30),
                  Text("${_weatherData!['current_weather']['temperature']}°C", style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200, color: Colors.white)),
                  const Text("METEO VERİSİ", style: TextStyle(fontSize: 18, color: Colors.purple, letterSpacing: 2)),
                ],
              ),
            ),
    );
  }
}
