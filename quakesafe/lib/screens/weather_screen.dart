import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';

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

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy;
    if (code <= 48) return Icons.cloud;
    if (code <= 67) return Icons.umbrella;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.water_drop;
    if (code <= 99) return Icons.thunderstorm;
    return Icons.wb_sunny;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Hava Durumu", style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.black, elevation: 0),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : _weatherData == null
          ? const Center(child: Text("Hava durumu bilgisi alınamadı.", style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCurrentWeather(),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("7 GÜNLÜK TAHMİN", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 16),
                  _buildForecast(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeather() {
    final current = _weatherData!['current_weather'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF0D1117)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.1), blurRadius: 30)],
      ),
      child: Column(
        children: [
          Icon(_getWeatherIcon(current['weathercode']), size: 100, color: Colors.white),
          const SizedBox(height: 20),
          Text("${current['temperature']}°", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200, color: Colors.white)),
          const Text("GÜNCEL DURUM", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildForecast() {
    final daily = _weatherData!['daily'];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = DateTime.parse(daily['time'][index]);
        final dayName = DateFormat('EEEE', 'tr').format(date);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(_getWeatherIcon(daily['weathercode'][index]), color: Colors.white54, size: 20),
                  const SizedBox(width: 15),
                  Text("${daily['temperature_2m_max'][index]}°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text("${daily['temperature_2m_min'][index]}°", style: const TextStyle(color: Colors.white24)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
