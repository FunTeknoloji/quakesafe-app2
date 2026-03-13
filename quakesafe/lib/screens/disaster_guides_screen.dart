import 'package:flutter/material.dart';

class DisasterGuidesScreen extends StatelessWidget {
  const DisasterGuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Afet Rehberleri", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGuideSection(
            "Deprem Sırasında",
            [
              "Yat, Çök, Kapan, Tutun hareketini yapın.",
              "Pencere, raf ve devrilebilecek eşyalardan uzak durun.",
              "Asansörleri asla kullanmayın.",
              "Merdivenlere koşmayın.",
            ],
            Icons.waves,
            Colors.blue,
          ),
          _buildGuideSection(
            "Deprem Sonrasında",
            [
              "Sarsıntı durduğunda binayı dikkatle terk edin.",
              "Tesisatları (gaz, su, elektrik) kapatın.",
              "Toplanma alanına gidin.",
              "Telefonları sadece acil durumlar için kullanın, internet üzerinden haberleşin.",
            ],
            Icons.exit_to_app,
            Colors.green,
          ),
          _buildGuideSection(
            "Yangın Güvenliği",
            [
              "Duman altındaysanız yere yakın hareket edin (emekleyin).",
              "Kapı kollarını kontrol edin; sıcaksa açmayın.",
              "Yangın tüpü kullanımını (P.A.S.S) öğrenin.",
            ],
            Icons.local_fire_department,
            Colors.red,
          ),
          _buildGuideSection(
            "Afet Çantasında Neler Olmalı?",
            [
              "En az 72 saat yetecek su ve konserve gıda.",
              "İlk yardım çantası.",
              "El feneri ve yedek piller.",
              "Radyo ve düdük.",
              "Önemli evrak kopyaları.",
              "Nakit para.",
            ],
            Icons.backpack,
            Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, List<String> points, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 36),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(color: Colors.purple, fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
