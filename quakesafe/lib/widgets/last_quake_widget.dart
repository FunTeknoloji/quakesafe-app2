import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';

class LastQuakeWidget extends StatefulWidget {
  const LastQuakeWidget({super.key});

  @override
  State<LastQuakeWidget> createState() => _LastQuakeWidgetState();
}

class _LastQuakeWidgetState extends State<LastQuakeWidget> {
  Map<String, dynamic>? _lastQuake;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLastQuake();
  }

  Future<void> _fetchLastQuake() async {
    try {
      final response = await http.get(Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live?limit=1'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['result'] != null && data['result'].isNotEmpty) {
          setState(() {
            _lastQuake = data['result'][0];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching quake: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.waves, color: Colors.purple, size: 20),
                    SizedBox(width: 10),
                    Text("Son Deprem", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                IconButton(onPressed: _fetchLastQuake, icon: const Icon(Icons.refresh, size: 20, color: Colors.purple)),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.purple))
            else if (_lastQuake == null)
              const Text("Veri alınamadı", style: TextStyle(color: Colors.grey))
            else
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getMagColor(double.tryParse(_lastQuake!['mag'].toString()) ?? 0).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _lastQuake!['mag'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _getMagColor(double.tryParse(_lastQuake!['mag'].toString()) ?? 0)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lastQuake!['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text(_lastQuake!['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Color _getMagColor(double mag) {
    if (mag < 3.0) return Colors.green;
    if (mag < 5.0) return Colors.orange;
    return Colors.red;
  }
}
