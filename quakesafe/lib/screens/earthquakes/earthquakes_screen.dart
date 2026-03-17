import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../../services/settings_provider.dart';
import '../../translations.dart';

class EarthquakesScreen extends StatefulWidget {
  const EarthquakesScreen({super.key});

  @override
  State<EarthquakesScreen> createState() => _EarthquakesScreenState();
}

class _EarthquakesScreenState extends State<EarthquakesScreen> {
  List<dynamic> _allQuakes = [];
  List<dynamic> _filteredQuakes = [];
  bool _isLoading = true;
  String? _error;
  double _minMagnitude = 0.0;

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

    // Try loading from cache first for immediate UI response
    final box = Hive.box('cache');
    final cached = box.get('offline_quakes');
    if (cached != null) {
      setState(() {
         _allQuakes = List<dynamic>.from(cached);
         _applyFilter();
         _isLoading = false;
      });
    }

    try {
      final response = await http.get(Uri.parse('https://api.orhanaydogdu.com.tr/deprem/kandilli/live?limit=100'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            _allQuakes = data['result'] ?? [];
            _applyFilter();
            _isLoading = false;
          });
          box.put('offline_quakes', data['result']);
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

  void _applyFilter() {
    setState(() {
      _filteredQuakes = _allQuakes.where((q) {
        final mag = double.tryParse(q['mag'].toString()) ?? 0;
        return mag >= _minMagnitude;
      }).toList();
    });
  }

  void _showDetails(dynamic quake) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 32),
            Text(quake['title'] ?? "Bilinmiyor", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
            const SizedBox(height: 8),
            Text(quake['date_time'] ?? "-", style: const TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 32),
            _detailRow(Icons.waves, "Büyüklük", "${quake['mag']}", _getMagColor(double.tryParse(quake['mag'].toString()) ?? 0)),
            _detailRow(Icons.vertical_align_bottom, "Derinlik", "${quake['depth']} km", Colors.blueAccent),
            _detailRow(Icons.location_on, "Koordinat", quake['geojson'] != null ? "${quake['geojson']['coordinates'][1]}, ${quake['geojson']['coordinates'][0]}" : "-", Colors.orangeAccent),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Kapat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppTranslations.t('quakes', lang), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
              centerTitle: true,
            ),
            actions: [
              IconButton(onPressed: _fetchQuakes, icon: const Icon(Icons.refresh, color: Colors.purple)),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _filterChip("Tümü", 0.0),
                  _filterChip("3.0+", 3.0),
                  _filterChip("4.0+", 4.0),
                  _filterChip("5.0+", 5.0),
                ],
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Colors.purple)))
              : _error != null
                  ? SliverFillRemaining(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final quake = _filteredQuakes[index];
                          final mag = double.tryParse(quake['mag'].toString()) ?? 0;
                          return _buildQuakeTile(quake, mag, index);
                        },
                        childCount: _filteredQuakes.length,
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, double val) {
    bool isSelected = _minMagnitude == val;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold, fontSize: 12)),
        selected: isSelected,
        onSelected: (s) {
          if (s) {
            setState(() {
              _minMagnitude = val;
              _applyFilter();
            });
          }
        },
        backgroundColor: const Color(0xFF111111),
        selectedColor: Colors.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildQuakeTile(dynamic quake, double mag, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          width: 55,
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _getMagColor(mag).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _getMagColor(mag).withValues(alpha: 0.2)),
          ),
          child: Text("${quake['mag']}", style: TextStyle(color: _getMagColor(mag), fontWeight: FontWeight.w900, fontSize: 20)),
        ),
        title: Text(quake['title'] ?? "Bilinmiyor", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(quake['date_time'] ?? "-", style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.white10),
        onTap: () => _showDetails(quake),
      ),
    ).animate().fadeIn(delay: (index * 20).ms).slideX(begin: 0.05, end: 0);
  }

  Color _getMagColor(double mag) {
    if (mag < 3.0) return Colors.greenAccent;
    if (mag < 4.0) return Colors.yellowAccent;
    if (mag < 5.0) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}
