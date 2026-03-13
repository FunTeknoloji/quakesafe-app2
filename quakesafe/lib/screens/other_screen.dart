import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_provider.dart';
import '../translations.dart';
import 'fun_ai_screen.dart';
import 'voice_control_screen.dart';
import 'news_screen.dart';
import 'weather_screen.dart';
import 'emergency_call_screen.dart';
import 'health_map_screen.dart';
import 'city_chat_screen.dart';
import 'disaster_plan_screen.dart';
import 'tools_screen.dart';
import 'mesh_chat_screen.dart';
import 'first_aid_screen.dart';
import 'disaster_guides_screen.dart';
import 'simple_info_screen.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            backgroundColor: Colors.black,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppTranslations.t('other', lang), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildLargeCard(
                    context,
                    "FunAI",
                    lang == "Türkçe" ? "GELİŞMİŞ YAPAY ZEKA ASİSTANI" : "ADVANCED AI ASSISTANT",
                    Icons.auto_awesome,
                    const Color(0xFF3D2C8D),
                    const Color(0xFF1C0C5B),
                    const FunAIScreen(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.grid_view_rounded, color: Colors.purple, size: 20),
                      const SizedBox(width: 10),
                      Text(lang == "Türkçe" ? "TÜM SERVİSLER" : "ALL SERVICES", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (context, index) {
                final item = _getItems(lang)[index];
                return _buildGridCard(context, item);
              },
              childCount: _getItems(lang).length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeCard(BuildContext context, String title, String subtitle, IconData icon, Color color1, Color color2, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: color1.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 20),
                  Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5), letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 40),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildGridCard(BuildContext context, OtherItem item) {
    return GestureDetector(
      onTap: () {
        if (item.screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => item.screen!));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("${item.title} yakında eklenecek."),
            backgroundColor: Colors.purple,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(height: 16),
            Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text(item.subtitle, style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  static List<OtherItem> _getItems(String lang) => [
    OtherItem(AppTranslations.t('mesh_mode', lang), lang == "Türkçe" ? "INTERNETSİZ MESAJ" : "OFFLINE CHAT", Icons.wifi_tethering, Colors.blueGrey, screen: const MeshChatScreen()),
    OtherItem(AppTranslations.t('tools_bag', lang), AppTranslations.t('equipment', lang), Icons.construction, Colors.amber, screen: const ToolsScreen()),
    OtherItem(AppTranslations.t('voice_command', lang), AppTranslations.t('hands_free', lang), Icons.mic, Colors.blue, screen: const VoiceControlScreen()),
    OtherItem(AppTranslations.t('news', lang), lang == "Türkçe" ? "SON DAKİKA" : "BREAKING NEWS", Icons.newspaper, Colors.orange, screen: const NewsScreen()),
    OtherItem(AppTranslations.t('disaster_plan', lang), lang == "Türkçe" ? "AİLE HAZIRLIĞI" : "FAMILY PREP", Icons.assignment, Colors.red, screen: const DisasterPlanScreen()),
    OtherItem(AppTranslations.t('weather', lang), AppTranslations.t('forecast', lang), Icons.cloud, Colors.lightBlue, screen: const WeatherScreen()),
    OtherItem(AppTranslations.t('emergency_call', lang), lang == "Türkçe" ? "TEK TUŞ YARDIM" : "ONE TOUCH HELP", Icons.phone_in_talk, Colors.redAccent, screen: const EmergencyCallScreen()),
    OtherItem(AppTranslations.t('city_chat', lang), lang == "Türkçe" ? "YEREL MESAJLAR" : "LOCAL MESSAGES", Icons.forum_outlined, Colors.green, screen: const CityChatScreen()),
    OtherItem(AppTranslations.t('health_map', lang), lang == "Türkçe" ? "HASTANELER" : "HOSPITALS", Icons.local_hospital_outlined, Colors.pink, screen: const HealthMapScreen()),
    OtherItem(AppTranslations.t('first_aid', lang), AppTranslations.t('basic_training', lang), Icons.medical_services_outlined, Colors.indigo, screen: const FirstAidScreen()),
    OtherItem(AppTranslations.t('guides', lang), AppTranslations.t('documentation', lang), Icons.menu_book_outlined, Colors.deepOrange, screen: const DisasterGuidesScreen()),
  ];
}

class OtherItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget? screen;
  OtherItem(this.title, this.subtitle, this.icon, this.color, {this.screen});
}
