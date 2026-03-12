import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssemblyAreaWidget extends StatelessWidget {
  const AssemblyAreaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: ListTile(
        onTap: () => launchUrl(Uri.parse("https://www.turkiye.gov.tr/afet-ve-acil-durum-yonetimi-acil-toplanma-alani-sorgulama")),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
        title: const Text("Toplanma Alanı Sorgula", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: const Text("e-Devlet", style: TextStyle(color: Colors.white24, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      ),
    );
  }
}
