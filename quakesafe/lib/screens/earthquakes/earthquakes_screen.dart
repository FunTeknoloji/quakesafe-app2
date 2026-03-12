import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

class EarthquakesScreen extends StatefulWidget {
  const EarthquakesScreen({super.key});

  @override
  State<EarthquakesScreen> createState() => _EarthquakesScreenState();
}

class _EarthquakesScreenState extends State<EarthquakesScreen> {
  List<dynamic> _quakes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuakes();
  }

  Future<void> _fetchQuakes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _quakes = data['result'] ?? [];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = "Veri formatı hatalı.";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = "Sunucu hatası: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        _error = "Bağlantı hatası: Veri çekilemedi.";
        _isLoading = false;
      });
    }
  }

  void _showDetails(dynamic quake) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 30),
            Text(quake['title'] ?? "Bilinmiyor", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 20),
            _detailRow(Icons.waves, "Büyüklük", "${quake['mag']}"),
            _detailRow(Icons.vertical_align_bottom, "Derinlik", "${quake['depth']} km"),
            _detailRow(Icons.calendar_today, "Tarih", quake['date'] ?? "-"),
            _detailRow(Icons.location_on, "Koordinat", quake['geojson'] != null ? "${quake['geojson']['coordinates'][1]}, ${quake['geojson']['coordinates'][0]}" : "-"),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                child: const Text("Kapat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.purple, size: 22),
          ),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Son Depremler", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(onPressed: _fetchQuakes, icon: const Icon(Icons.refresh, color: Colors.purple))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _quakes.length,
                  itemBuilder: (context, index) {
                    final quake = _quakes[index];
                    final mag = double.tryParse(quake['mag'].toString()) ?? 0;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _getMagColor(mag).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: _getMagColor(mag).withValues(alpha: 0.3)),
                          ),
                          child: Text("${quake['mag']}", style: TextStyle(color: _getMagColor(mag), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        title: Text(quake['title'] ?? "Bilinmiyor", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(quake['date'] ?? "-", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                        onTap: () => _showDetails(quake),
                      ),
                    ).animate().fadeIn(delay: (index * 10).ms).slideX(begin: 0.05, end: 0);
                  },
                ),
    );
  }

  Color _getMagColor(double mag) {
    if (mag < 3.0) return Colors.greenAccent;
    if (mag < 5.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
