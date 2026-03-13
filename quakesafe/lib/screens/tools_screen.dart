import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../translations.dart';
import '../widgets/compass_widget.dart';
import '../widgets/spirit_level_widget.dart';
import '../widgets/quick_tools_widget.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('tools_bag', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryHeader(AppTranslations.t('sensors_cat', lang)),
          const CompassWidget(),
          const SizedBox(height: 16),
          const SpiritLevelWidget(),
          const SizedBox(height: 24),
          _buildCategoryHeader(AppTranslations.t('emergency_tools', lang)),
          const QuickToolsWidget(),
          const SizedBox(height: 24),
          _buildCategoryHeader(AppTranslations.t('utility_tools', lang)),
          _buildToolTile(
            context,
            AppTranslations.t('morse_code', lang),
            lang == "Türkçe" ? "Işık ile sinyal gönderin" : "Send signals with light",
            Icons.code,
            Colors.amber
          ),
          _buildToolTile(
            context,
            AppTranslations.t('mirror_mode', lang),
            lang == "Türkçe" ? "Ön kamerayı kullanarak ayna yapın" : "Use front camera as mirror",
            Icons.face,
            Colors.cyan
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(title, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
    );
  }

  Widget _buildToolTile(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$title yakında eklenecek.")));
        },
      ),
    );
  }
}
