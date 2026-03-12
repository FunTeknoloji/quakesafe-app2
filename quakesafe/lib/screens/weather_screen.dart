import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherFactory _wf = WeatherFactory("YOUR_WEATHER_API_KEY"); // Placeholder, usually from env
  Weather? _weather;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      Weather w = await _wf.currentWeatherByLocation(position.latitude, position.longitude);
      setState(() {
        _weather = w;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
                  Text(_weather!.areaName ?? "", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  Text("${_weather!.temperature?.celsius?.toStringAsFixed(1)}°C", style: const TextStyle(fontSize: 64, color: Colors.purple)),
                  Text(_weather!.weatherDescription ?? "", style: const TextStyle(fontSize: 20, color: Colors.grey)),
                ],
              ),
            ),
    );
  }
}
