import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../translations.dart';

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
    // Cache load
    final box = Hive.box('cache');
    final cached = box.get('offline_weather');
    if (cached != null) {
      setState(() {
         _weatherData = Map<String, dynamic>.from(cached);
         _isLoading = false;
      });
    }

    final data = await _weatherService.fetchWeather();
    if (mounted && data != null) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
      box.put('offline_weather', data);
    }
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
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('weather', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : _weatherData == null
          ? const Center(child: Text("Hava durumu bilgisi alınamadı.", style: TextStyle(color: Colors.grey)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCurrentWeather(lang),
                  const SizedBox(height: 24),
                  _buildDetailedGrid(lang),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppTranslations.t('forecast', lang).toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 16),
                  _buildForecast(lang),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentWeather(String lang) {
    final current = _weatherData!['current_weather'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF311B92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Icon(_getWeatherIcon(current['weathercode']), size: 100, color: Colors.white).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          Text("${current['temperature']}°", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w200, color: Colors.white, letterSpacing: -4)),
          Text(lang == "Türkçe" ? "GÜNCEL DURUM" : "CURRENT STATUS", style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildDetailedGrid(String lang) {
    final current = _weatherData!['current'];
    final daily = _weatherData!['daily'];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _detailTile(lang == "Türkçe" ? "Hissedilen" : "Feels Like", "${current['apparent_temperature']}°", Icons.thermostat),
        _detailTile(lang == "Türkçe" ? "Nem" : "Humidity", "%${current['relative_humidity_2m']}", Icons.water_drop),
        _detailTile(lang == "Türkçe" ? "Rüzgar" : "Wind", "${current['wind_speed_10m']} km/s", Icons.air),
        _detailTile(lang == "Türkçe" ? "UV İndeksi" : "UV Index", "${daily['uv_index_max'][0]}", Icons.wb_sunny),
      ],
    );
  }

  Widget _detailTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecast(String lang) {
    final daily = _weatherData!['daily'];
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = DateTime.parse(daily['time'][index]);
        final dayName = DateFormat('EEEE', lang == "Türkçe" ? 'tr' : 'en').format(date);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(_getWeatherIcon(daily['weathercode'][index]), color: Colors.white54, size: 20),
                  const SizedBox(width: 20),
                  Text("${daily['temperature_2m_max'][index]}°", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
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
