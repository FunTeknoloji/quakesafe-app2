import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();

  bool _blockForeign = false;
  bool _blockVpn = false;
  bool _groupNotif = true;
  bool _quakeNotif = true;
  double _minMag = 4.0;
  String _lang = "Türkçe";
  bool _animations = true;
  double _fontSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final profile = await _supabase.from('profiles_quakesafe').select().eq('id', userId).single();
      setState(() {
        _blockForeign = profile['block_foreign_access'] ?? false;
        _blockVpn = profile['block_vpn'] ?? false;
      });
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  Future<void> _updateProfile(String key, dynamic value) async {
    try {
      await _supabase.from('profiles_quakesafe').update({key: value}).eq('id', _supabase.auth.currentUser!.id);
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Ayarlar"), backgroundColor: Colors.black),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader("Güvenlik"),
          _switchTile("Yurt Dışı Girişi Engelle", "block_foreign_access", _blockForeign, (v) { setState(() => _blockForeign = v); _updateProfile('block_foreign_access', v); }),
          _switchTile("VPN / Proxy Engelle", "block_vpn", _blockVpn, (v) { setState(() => _blockVpn = v); _updateProfile('block_vpn', v); }),

          const SizedBox(height: 20),
          _sectionHeader("Bildirimler"),
          _switchTile("Grup Sohbeti Bildirimleri", "", _groupNotif, (v) => setState(() => _groupNotif = v)),
          _switchTile("Yeni Deprem Bildirimleri", "", _quakeNotif, (v) => setState(() => _quakeNotif = v)),
          if (_quakeNotif) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text("Min. Büyüklük: ", style: TextStyle(color: Colors.grey)),
                Expanded(
                  child: Slider(
                    value: _minMag, min: 1.0, max: 9.0, divisions: 80, label: _minMag.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _minMag = v),
                  ),
                ),
                Text(_minMag.toStringAsFixed(1), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionHeader("Görünüm ve Dil"),
          _dropdownTile("Dil", _lang, ["Türkçe", "English"], (v) => setState(() => _lang = v!)),
          _switchTile("Animasyonlar", "", _animations, (v) => setState(() => _animations = v)),
          ListTile(
            title: const Text("Yazı Tipi Boyutu", style: TextStyle(color: Colors.white)),
            subtitle: Slider(value: _fontSize, min: 0.8, max: 1.5, onChanged: (v) => setState(() => _fontSize = v)),
          ),

          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Çıkış Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900], padding: const EdgeInsets.symmetric(vertical: 15)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16), child: Text(title, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 14)));
  }

  Widget _switchTile(String title, String key, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.purple,
    );
  }

  Widget _dropdownTile(String title, String value, List<String> items, Function(String?) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
    );
  }
}
