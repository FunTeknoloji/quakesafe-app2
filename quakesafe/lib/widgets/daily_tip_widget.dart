import 'package:flutter/material.dart';

class DailyTipWidget extends StatelessWidget {
  const DailyTipWidget({super.key});

  static const List<String> tips = [
    "Deprem anında sakin kalın ve Çök-Kapan-Tutun hareketini yapın.",
    "Evdeki ağır mobilyaları mutlaka duvara sabitleyin.",
    "Afet çantanızı her 6 ayda bir kontrol edip güncelleyin.",
    "Bina çıkış yollarını asla eşyalarla kapatmayın.",
    "Evdeki her birey ana vanaların yerini ve nasıl kapatılacağını bilmelidir.",
    "Deprem sonrası asansörleri asla kullanmayın.",
    "Pencere önlerinden ve devrilebilecek ağır eşyalardan uzak durun.",
    "Acil durum toplanma alanınızı e-devlet üzerinden öğrenin.",
    "Yangın söndürme cihazının yerini ve kullanımını öğrenin.",
    "Yataklarınızın yanına fener ve kalın tabanlı ayakkabı koyun.",
    "Gaz kokusu alırsanız asla elektrik düğmelerine dokunmayın.",
    "İlk yardım eğitimi alarak hayat kurtarabilirsiniz.",
    "Binalarınızın deprem dayanıklılığını uzmanlara kontrol ettirin.",
    "Elektrik şalterlerini ıslak ellerle asla kapatmaya çalışmayın.",
    "Afet anında telefonları sadece hayati durumlar için kullanın.",
  ];

  @override
  Widget build(BuildContext context) {
    final int dayIndex = DateTime.now().day % tips.length;
    final String currentTip = tips[dayIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.verified_user_outlined, size: 100, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("GÜNÜN BİLGİSİ", style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(
                        currentTip,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
