import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherFactory _wf = WeatherFactory("895284fb362c0355490fd394e3345479"); // OpenWeather API Key
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
      Weather w = await _wf.currentWeatherByLocation(position.latitude, position.longitude);
      setState(() {
        _weather = w;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Weather error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Hava Durumu"), backgroundColor: Colors.black),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : _weather == null
          ? const Center(child: Text("Hava durumu bilgisi alınamadı.", style: TextStyle(color: Colors.grey)))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                    child: Icon(_getIcon(_weather!.weatherConditionCode), size: 100, color: Colors.purple),
                  ),
                  const SizedBox(height: 30),
                  Text(_weather!.areaName ?? "", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text("${_weather!.temperature?.celsius?.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w200, color: Colors.white)),
                  Text(_weather!.weatherDescription?.toUpperCase() ?? "", style: const TextStyle(fontSize: 18, color: Colors.purple, letterSpacing: 2)),
                  const SizedBox(height: 40),
                  _weatherDetail("Nem", "${_weather!.humidity}%"),
                  _weatherDetail("Rüzgar", "${_weather!.windSpeed} m/s"),
                ],
              ),
            ),
    );
  }

  Widget _weatherDetail(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Text("$label: $value", style: const TextStyle(color: Colors.grey)));
  }

  IconData _getIcon(int? code) {
    if (code == null) return Icons.wb_sunny;
    if (code >= 200 && code < 300) return Icons.thunderstorm;
    if (code >= 300 && code < 600) return Icons.cloudy_snowing;
    if (code >= 600 && code < 700) return Icons.ac_unit;
    if (code >= 801) return Icons.cloud;
    return Icons.wb_sunny;
  }
}
