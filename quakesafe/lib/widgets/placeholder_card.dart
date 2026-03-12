import 'package:flutter/material.dart';

class PlaceholderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderCard({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (title == "Acil Numaralar") {
       return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
         child: Row(
           children: [
             Expanded(
               child: _emergencyBtn(Icons.phone, "112 ARA", Colors.red),
             ),
             const SizedBox(width: 12),
             Expanded(
               child: _emergencyBtn(Icons.campaign, "S.O.S (SMS)", const Color(0xFF1E1E1E)),
             ),
           ],
         ),
       );
    }

    if (title == "Hızlı Rehberler") {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Padding(
             padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text("HIZLI REHBERLER", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
                 Text("Tümü", style: TextStyle(color: Colors.purple, fontSize: 12)),
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: Row(
               children: [
                 Expanded(child: _rehberBtn(Icons.waves, "Deprem")),
                 const SizedBox(width: 12),
                 Expanded(child: _rehberBtn(Icons.local_fire_department, "Yangın")),
               ],
             ),
           ),
         ],
       );
    }

    if (title == "Bağış Yap") {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF00150A),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(15)),
              child: const Icon(Icons.favorite, color: Colors.white),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bağış Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Yardımlaşma hayat kurtarır.", style: TextStyle(color: Colors.green, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.green),
          ],
        ),
      );
    }

    if (title == "Hava Durumu") {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFA000), Color(0xFFFF6F00)]),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("12°  AZ BULUTLU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  Text("HİSSEDİLEN 9°", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.wb_sunny_outlined, size: 40, color: Colors.white38),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _emergencyBtn(IconData icon, String label, Color color) {
    return Container(
      height: 120,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(30)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _rehberBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
