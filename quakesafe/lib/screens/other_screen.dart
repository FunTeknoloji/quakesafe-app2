import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            expandedHeight: 150,
            backgroundColor: Colors.black,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppTranslations.t('other', lang),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1)
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.withValues(alpha: 0.2), Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAIPanel(context, lang),
                  const SizedBox(height: 32),
                  _sectionTitle("SERVİSLER"),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _getItems(lang)[index];
                  return _buildModernCard(context, item, index);
                },
                childCount: _getItems(lang).length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel(BuildContext context, String lang) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.purple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FunAIScreen())),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                          child: const Text("PRO AI", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Text("FunAI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                        Text(
                          lang == "Türkçe" ? "Yapay zeka ile anında yardım" : "Instant AI assistance",
                          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 48).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11),
    );
  }

  Widget _buildModernCard(BuildContext context, OtherItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (item.screen != null) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => item.screen!));
            }
          },
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const Spacer(),
                Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).scale(begin: const Offset(0.9, 0.9));
  }

  static List<OtherItem> _getItems(String lang) => [
    OtherItem(AppTranslations.t('mesh_mode', lang), lang == "Türkçe" ? "OFFLINE SOHBET" : "OFFLINE CHAT", Icons.wifi_tethering, Colors.blueGrey, screen: const MeshChatScreen()),
    OtherItem(AppTranslations.t('tools_bag', lang), lang == "Türkçe" ? "EKİPMANLAR" : "EQUIPMENT", Icons.construction, Colors.amber, screen: const ToolsScreen()),
    OtherItem(AppTranslations.t('voice_command', lang), AppTranslations.t('hands_free', lang), Icons.mic, Colors.blue, screen: const VoiceControlScreen()),
    OtherItem(AppTranslations.t('news', lang), lang == "Türkçe" ? "SON DAKİKA" : "BREAKING NEWS", Icons.newspaper, Colors.orange, screen: const NewsScreen()),
    OtherItem(AppTranslations.t('disaster_plan', lang), lang == "Türkçe" ? "AİLE HAZIRLIĞI" : "FAMILY PREP", Icons.assignment, Colors.red, screen: const DisasterPlanScreen()),
    OtherItem(AppTranslations.t('weather', lang), AppTranslations.t('forecast', lang), Icons.cloud, Colors.lightBlue, screen: const WeatherScreen()),
    OtherItem(AppTranslations.t('emergency_call', lang), lang == "Türkçe" ? "ACİL YARDIM" : "EMERGENCY", Icons.phone_in_talk, Colors.redAccent, screen: const EmergencyCallScreen()),
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
