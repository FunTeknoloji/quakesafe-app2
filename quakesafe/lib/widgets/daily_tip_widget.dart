import 'package:flutter/material.dart';
import 'dart:math';

class DailyTipWidget extends StatelessWidget {
  DailyTipWidget({super.key});

  final List<String> _tips = [
    "Deprem anında Çök-Kapan-Tutun hareketini yapın.",
    "Afet çantanızı her 6 ayda bir kontrol edin.",
    "Evdeki ağır mobilyaları duvara sabitleyin.",
    "Deprem sonrası asansörleri kullanmayın.",
    "Bina çıkış yollarını her zaman açık tutun.",
    "İlk yardım çantası hazırlayın ve yerini öğrenin.",
    "Aile afet planınızı oluşturun ve prova yapın.",
  ];

  @override
  Widget build(BuildContext context) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final tip = _tips[dayOfYear % _tips.length];

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.purple.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow),
                SizedBox(width: 10),
                Text("Günün Bilgisi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Text(tip, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
