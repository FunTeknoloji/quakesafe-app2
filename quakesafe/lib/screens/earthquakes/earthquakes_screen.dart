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

  @override
  void initState() {
    super.initState();
    _fetchQuakes();
  }

  Future<void> _fetchQuakes() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _quakes = data['result'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showDetails(dynamic quake) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 20),
            Text(quake['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            _detailRow(Icons.waves, "Büyüklük", "${quake['mag']}"),
            _detailRow(Icons.vertical_align_bottom, "Derinlik", "${quake['depth']} km"),
            _detailRow(Icons.calendar_today, "Tarih", quake['date']),
            _detailRow(Icons.location_on, "Koordinat", "${quake['geojson']['coordinates'][1]}, ${quake['geojson']['coordinates'][0]}"),
            const SizedBox(height: 20),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 300.ms),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Son Depremler"),
        actions: [IconButton(onPressed: _fetchQuakes, icon: const Icon(Icons.refresh))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : ListView.builder(
              itemCount: _quakes.length,
              itemBuilder: (context, index) {
                final quake = _quakes[index];
                final mag = double.tryParse(quake['mag'].toString()) ?? 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getMagColor(mag).withOpacity(0.2),
                    child: Text("${quake['mag']}", style: TextStyle(color: _getMagColor(mag), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(quake['title']),
                  subtitle: Text(quake['date']),
                  onTap: () => _showDetails(quake),
                ).animate().fadeIn(delay: (index * 20).ms).slideX(begin: 0.1, end: 0);
              },
            ),
    );
  }

  Color _getMagColor(double mag) {
    if (mag < 3.0) return Colors.green;
    if (mag < 5.0) return Colors.orange;
    return Colors.red;
  }
}
