import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
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
  late SharedPreferences _prefs;

  bool _isLoaded = false;
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
    _initSettings();
  }

  Future<void> _initSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final userId = _supabase.auth.currentUser!.id;
    final profile = await _supabase.from('profiles_quakesafe').select().eq('id', userId).single();

    setState(() {
      _blockForeign = profile['block_foreign_access'] ?? _prefs.getBool('block_foreign') ?? false;
      _blockVpn = profile['block_vpn'] ?? _prefs.getBool('block_vpn') ?? false;
      _groupNotif = _prefs.getBool('group_notif') ?? true;
      _quakeNotif = _prefs.getBool('quake_notif') ?? true;
      _minMag = _prefs.getDouble('min_mag') ?? 4.0;
      _lang = _prefs.getString('language') ?? "Türkçe";
      _animations = _prefs.getBool('animations') ?? true;
      _fontSize = _prefs.getDouble('font_size') ?? 1.0;
      _isLoaded = true;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) await _prefs.setBool(key, value);
    if (value is double) await _prefs.setDouble(key, value);
    if (value is String) await _prefs.setString(key, value);

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (key == 'animations') settings.setAnimations(value);
    if (key == 'font_size') settings.setFontSize(value);
    if (key == 'language') settings.setLanguage(value);
    if (key == 'block_foreign') settings.setBlockForeign(value);
    if (key == 'block_vpn') settings.setBlockVpn(value);

    if (key == 'block_foreign' || key == 'block_vpn') {
      final dbKey = key == 'block_foreign' ? 'block_foreign_access' : 'block_vpn';
      await _supabase.from('profiles_quakesafe').update({dbKey: value}).eq('id', _supabase.auth.currentUser!.id);
    }
  }

  void _confirmDelete() {
    final deleteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("HESABI SİL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Tüm verileriniz kalıcı olarak silinecektir. Devam etmek için 'SİL' yazın.", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 15),
            TextField(controller: deleteController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "SİL", hintStyle: TextStyle(color: Colors.grey))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL")),
          TextButton(
            onPressed: () async {
              if (deleteController.text == "SİL") {
                await _authService.deleteAccount();
                if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
              }
            },
            child: const Text("ONAYLA", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Ayarlar"), backgroundColor: Colors.black),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _categoryHeader("GÜVENLİK"),
          _switchTile("Yurt Dışı Girişi Engelle", _blockForeign, (v) { setState(() => _blockForeign = v); _saveSetting('block_foreign', v); }),
          _switchTile("VPN / Proxy Engelle", _blockVpn, (v) { setState(() => _blockVpn = v); _saveSetting('block_vpn', v); }),

          _categoryHeader("BİLDİRİMLER"),
          _switchTile("Grup Sohbeti Bildirimleri", _groupNotif, (v) { setState(() => _groupNotif = v); _saveSetting('group_notif', v); }),
          _switchTile("Yeni Deprem Bildirimleri", _quakeNotif, (v) { setState(() => _quakeNotif = v); _saveSetting('quake_notif', v); }),
          if (_quakeNotif) _magSlider(),

          _categoryHeader("GÖRÜNÜM VE DİL"),
          _dropdownTile("Dil", _lang, ["Türkçe", "English"], (v) { setState(() => _lang = v!); _saveSetting('language', v); }),
          _switchTile("Animasyonlar", _animations, (v) { setState(() => _animations = v); _saveSetting('animations', v); }),
          _fontSlider(),

          const SizedBox(height: 40),
          _actionButton("Hesabı Sil", Colors.red[900]!, _confirmDelete),
          const SizedBox(height: 12),
          _actionButton("Çıkış Yap", Colors.grey[800]!, () async {
            await _authService.signOut();
            if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
          }),
        ],
      ),
    );
  }

  Widget _categoryHeader(String title) => Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 8), child: Text(title, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)));

  Widget _switchTile(String title, bool value, Function(bool) onChanged) => SwitchListTile(title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)), value: value, onChanged: onChanged, activeColor: Colors.purple);

  Widget _magSlider() => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [const Text("Min. Büyüklük: ", style: TextStyle(color: Colors.grey, fontSize: 13)), Expanded(child: Slider(value: _minMag, min: 1.0, max: 9.0, divisions: 80, onChanged: (v) { setState(() => _minMag = v); _saveSetting('min_mag', v); })), Text(_minMag.toStringAsFixed(1), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold))]));

  Widget _fontSlider() => ListTile(title: const Text("Yazı Tipi Boyutu", style: TextStyle(color: Colors.white, fontSize: 15)), subtitle: Slider(value: _fontSize, min: 0.8, max: 1.5, onChanged: (v) { setState(() => _fontSize = v); _saveSetting('font_size', v); }));

  Widget _dropdownTile(String title, String value, List<String> items, Function(String?) onChanged) => ListTile(title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)), trailing: DropdownButton<String>(value: value, dropdownColor: const Color(0xFF1E1E1E), style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold), items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: onChanged, underline: Container()));

  Widget _actionButton(String label, Color color, VoidCallback onTap) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
}
