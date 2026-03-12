import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
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
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 100,
        decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(25)),
        child: const Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    if (_weatherData == null) return const SizedBox();

    final current = _weatherData!['current_weather'];
    final temp = current['temperature'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getWeatherColors(current['weathercode']),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${temp.toStringAsFixed(0)}°  ${_getWeatherName(current['weathercode'])}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const Text("OPEN-METEO", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            Icon(_getWeatherIcon(current['weathercode']), size: 40, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  List<Color> _getWeatherColors(int code) {
    if (code == 0) return [const Color(0xFFFFA000), const Color(0xFFFF6F00)]; // Clear
    if (code <= 3) return [const Color(0xFF546E7A), const Color(0xFF263238)]; // Cloudy
    if (code <= 67) return [const Color(0xFF1E88E5), const Color(0xFF0D47A1)]; // Rain
    return [const Color(0xFF4527A0), const Color(0xFF311B92)]; // Other/Storm
  }

  String _getWeatherName(int code) {
    if (code == 0) return "GÜNEŞLİ";
    if (code <= 3) return "PARÇALI BULUTLU";
    if (code <= 48) return "SİSLİ";
    if (code <= 67) return "YAĞMURLU";
    if (code <= 77) return "KARLI";
    if (code <= 82) return "SAĞANAK";
    return "FIRTINALI";
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.wb_cloudy_outlined;
    if (code <= 67) return Icons.umbrella_outlined;
    return Icons.thunderstorm_outlined;
  }
}
