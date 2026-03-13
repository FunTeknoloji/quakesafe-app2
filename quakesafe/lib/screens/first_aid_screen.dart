import 'package:flutter/material.dart';

class FirstAidScreen extends StatelessWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("İlk Yardım Eğitimi", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            "Temel Yaşam Desteği (ABC)",
            "A: Hava yolu (Airway)\nB: Solunum (Breathing)\nC: Dolaşım (Circulation)",
            Icons.favorite,
            Colors.red,
          ),
          _buildInfoCard(
            "Kanamalarda İlk Yardım",
            "Yaraya temiz bir bezle bastırın. Kanama durmazsa bez sayısını artırın ve basınç uygulamaya devam edin. Yaralı bölgeyi kalp seviyesinden yukarı kaldırın.",
            Icons.opacity,
            Colors.redAccent,
          ),
          _buildInfoCard(
            "Kırık, Çıkık ve Burkulmalar",
            "Hareketsizliği sağlayın (tespit edin). Soğuk uygulama yapın. Yaralı bölgeyi kalp seviyesinden yukarıda tutun. Asla yerine oturtmaya çalışmayın.",
            Icons.healing,
            Colors.orange,
          ),
          _buildInfoCard(
            "Yanıklarda İlk Yardım",
            "Yanık bölgeyi en az 15-20 dakika soğuk (buzlu değil) su altında tutun. Su toplayan yerleri patlatmayın. Üzerine diş macunu, salça vb. sürmeyin.",
            Icons.whatshot,
            Colors.deepOrange,
          ),
          _buildInfoCard(
            "Zehirlenmelerde İlk Yardım",
            "Kişiyi toksik bölgeden uzaklaştırın. Bilinci yerindeyse su içirin. Kusturmaya çalışmayın (yakıcı madde ise yemek borusuna zarar verir).",
            Icons.warning,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
