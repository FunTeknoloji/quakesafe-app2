import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OtherScreen extends StatelessWidget {
  const OtherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Diğer Hizmetler", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLargeCard(
              "FunAI",
              "YAPAY ZEKA DESTEKLİ ASİSTAN",
              Icons.auto_awesome,
              const Color(0xFF2E2452),
              const Color(0xFF1E1736),
            ),
            const SizedBox(height: 16),
            MasonryGridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildGridCard(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeCard(String title, String subtitle, IconData icon, Color color1, Color color2) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildGridCard(OtherItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(item.subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale();
  }

  static final List<OtherItem> _items = [
    OtherItem("Sesli Komut", "ELLER SERBEST KONTROL", Icons.mic, Colors.blue),
    OtherItem("Haberler", "SON DAKİKA GELİŞMELERİ", Icons.newspaper, Colors.orange),
    OtherItem("Şehir Sohbeti", "YEREL BİLGİ PAYLAŞIMI", Icons.location_on, Colors.green),
    OtherItem("Araçlar", "SİREN, FENER VE SENSÖRLER", Icons.build, Colors.amber),
    OtherItem("Afet Planı", "AİLE HAZIRLIK REHBERİ", Icons.assignment, Colors.red),
    OtherItem("Sağlık Haritası", "EN YAKIN HASTANELER", Icons.local_hospital, Colors.pink),
    OtherItem("Hava Durumu", "ANLIK METEOROLOJİ", Icons.cloud, Colors.lightBlue),
    OtherItem("Bağış Yap", "YARDIM KURULUŞLARI", Icons.volunteer_activism, Colors.teal),
    OtherItem("Hazırlık & İlk Yardım", "TEMEL EĞİTİMLER", Icons.medical_services, Colors.indigo),
    OtherItem("Afet Rehberleri", "BİLGİLENDİRİCİ DÖKÜMANLAR", Icons.menu_book, Colors.deepOrange),
    OtherItem("Acil Çağrı", "TEK TUŞLA YARDIM", Icons.phone_in_talk, Colors.redAccent),
  ];
}

class OtherItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  OtherItem(this.title, this.subtitle, this.icon, this.color);
}
