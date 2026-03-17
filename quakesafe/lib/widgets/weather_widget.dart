import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.purple, strokeWidth: 2)),
      );
    }

    if (_weatherData == null) return const SizedBox();

    final current = _weatherData!['current_weather'];
    final temp = current['temperature'];
    final colors = _getWeatherColors(current['weathercode']);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[0], colors[1].withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors[1].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                _getWeatherIcon(current['weathercode']),
                size: 150,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${temp.toStringAsFixed(0)}°",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        _getWeatherName(current['weathercode']),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    _getWeatherIcon(current['weathercode']),
                    size: 48,
                    color: Colors.white,
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .moveY(begin: -5, end: 5, duration: 2000.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getWeatherColors(int code) {
    if (code == 0) return [const Color(0xFFFF9800), const Color(0xFFF57C00)]; // Clear
    if (code <= 3) return [const Color(0xFF607D8B), const Color(0xFF455A64)]; // Cloudy
    if (code <= 67) return [const Color(0xFF2196F3), const Color(0xFF1976D2)]; // Rain
    return [const Color(0xFF673AB7), const Color(0xFF512DA8)]; // Other/Storm
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
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.cloud;
    if (code <= 67) return Icons.umbrella;
    return Icons.thunderstorm;
  }
}
