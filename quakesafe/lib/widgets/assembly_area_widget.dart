import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssemblyAreaWidget extends StatelessWidget {
  const AssemblyAreaWidget({super.key});

  final String _url = 'https://www.turkiye.gov.tr/afet-ve-acil-durum-yonetimi-acil-toplanma-alani-sorgulama';

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(_url))) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: _launchUrl,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[900]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
          ),
          child: const Row(
            children: [
              Icon(Icons.map, color: Colors.white),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  "Toplanma Alanlarını Sorgula",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.open_in_new, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
