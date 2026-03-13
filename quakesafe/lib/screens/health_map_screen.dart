import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../translations.dart';

class HealthMapScreen extends StatelessWidget {
  const HealthMapScreen({super.key});

  Future<void> _openMap(String query) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('health_map', lang)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF051125),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppTranslations.t('health_map_info', lang),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryCard(
              context,
              AppTranslations.t('state_hospitals', lang),
              Icons.near_me,
              Colors.red,
              () => _openMap(lang == "Türkçe" ? "devlet hastanesi" : "state hospital"),
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              context,
              AppTranslations.t('pharmacies', lang),
              Icons.near_me,
              Colors.blue,
              () => _openMap(lang == "Türkçe" ? "eczane" : "pharmacy"),
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              context,
              AppTranslations.t('family_health_centers', lang),
              Icons.near_me,
              Colors.green,
              () => _openMap(lang == "Türkçe" ? "aile sağlığı merkezi" : "family health center"),
            ),
            const SizedBox(height: 12),
            _buildCategoryCard(
              context,
              AppTranslations.t('veterinarians', lang),
              Icons.near_me,
              Colors.orange,
              () => _openMap(lang == "Türkçe" ? "veteriner" : "veterinarian"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}
