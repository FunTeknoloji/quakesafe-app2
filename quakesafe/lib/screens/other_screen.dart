import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'fun_ai_screen.dart';
import 'voice_control_screen.dart';
import 'news_screen.dart';
import 'weather_screen.dart';
import 'emergency_call_screen.dart';
import 'disaster_plan_screen.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            backgroundColor: Colors.black,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text("Keşfet & Hizmetler", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                    "GELİŞMİŞ YAPAY ZEKA ASİSTANI",
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
                      const Text("TÜM SERVİSLER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
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
                final item = _items[index];
                return _buildGridCard(context, item);
              },
              childCount: _items.length,
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

  static final List<OtherItem> _items = [
    OtherItem("Sesli Komut", "ELLER SERBEST", Icons.mic, Colors.blue, screen: const VoiceControlScreen()),
    OtherItem("Haberler", "SON DAKİKA", Icons.newspaper, Colors.orange, screen: const NewsScreen()),
    OtherItem("Afet Planı", "AİLE HAZIRLIĞI", Icons.assignment, Colors.red, screen: const DisasterPlanScreen()),
    OtherItem("Hava Durumu", "METEOROLOJİ", Icons.cloud, Colors.lightBlue, screen: const WeatherScreen()),
    OtherItem("Acil Çağrı", "TEK TUŞ YARDIM", Icons.phone_in_talk, Colors.redAccent, screen: const EmergencyCallScreen()),
    OtherItem("Şehir Sohbeti", "YEREL MESAJLAR", Icons.forum_outlined, Colors.green),
    OtherItem("Sağlık Haritası", "HASTANELER", Icons.local_hospital_outlined, Colors.pink),
    OtherItem("Bağış Yap", "YARDIM ELİ", Icons.volunteer_activism_outlined, Colors.teal),
    OtherItem("İlk Yardım", "TEMEL EĞİTİM", Icons.medical_services_outlined, Colors.indigo),
    OtherItem("Rehberler", "DÖKÜMANTASYON", Icons.menu_book_outlined, Colors.deepOrange),
    OtherItem("Ayarlar", "UYGULAMA KONTROL", Icons.settings_suggest_outlined, Colors.blueGrey),
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
