import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Son Deprem", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: _fetchLastQuake, icon: const Icon(Icons.refresh, size: 20)),
              ],
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_lastQuake == null)
              const Text("Veri alınamadı")
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getMagColor(double.tryParse(_lastQuake!['mag'].toString()) ?? 0),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _lastQuake!['mag'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_lastQuake!['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(_lastQuake!['date'], style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text("Derinlik: ${_lastQuake!['depth']} km"),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getMagColor(double mag) {
    if (mag < 3.0) return Colors.green;
    if (mag < 5.0) return Colors.orange;
    return Colors.red;
  }
}
