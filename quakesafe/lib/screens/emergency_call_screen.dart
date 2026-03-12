import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen> {
  List<Map<String, String>> _contacts = [];
  String _customMessage = "Acil durum! Yardıma ihtiyacım var. Konumum: >konum<";

  @override
  void initState() {
    super.initState();
    _loadEmergencyData();
  }

  Future<void> _loadEmergencyData() async {
    final prefs = await SharedPreferences.getInstance();
    final contactsJson = prefs.getString('emergency_contacts');
    if (contactsJson != null) {
      setState(() {
        _contacts = List<Map<String, String>>.from(json.decode(contactsJson).map((i) => Map<String, String>.from(i)));
      });
    }
    _customMessage = prefs.getString('emergency_msg') ?? _customMessage;
  }

  Future<void> _saveEmergencyData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_contacts', json.encode(_contacts));
    await prefs.setString('emergency_msg', _customMessage);
  }

  Future<void> _addContact() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null && contact.phones.isNotEmpty) {
          String phone = contact.phones.first.number.replaceAll(RegExp(r'\D'), '');
          if (phone.length >= 10) {
            setState(() {
              _contacts.add({'name': contact.displayName, 'phone': phone});
            });
            _saveEmergencyData();
          } else {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz numara formatı!")));
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  Future<void> _sendHelpSignal() async {
    Position pos = await Geolocator.getCurrentPosition();
    String locationStr = "https://maps.google.com/?q=${pos.latitude},${pos.longitude}";
    String finalMsg = _customMessage.replaceAll(">konum<", locationStr);

    for (var contact in _contacts) {
      final String number = contact['phone']!;
      // Note: Real SMS sending requires platform channel or specific package like 'flutter_sms'
      // but 'url_launcher' can open the native SMS app with body.
      final Uri smsUri = Uri.parse("sms:$number?body=${Uri.encodeComponent(finalMsg)}");
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Acil Çağrı"), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _emergencyButton(Icons.phone_in_talk, "112 ACİL SERVİS", Colors.red[900]!, () => FlutterPhoneDirectCaller.callNumber('112')),
            const SizedBox(height: 30),
            _sectionHeader("ACİL DURUM KİŞİLERİ"),
            ..._contacts.map((c) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(c['name']!, style: const TextStyle(color: Colors.white)),
              subtitle: Text(c['phone']!, style: const TextStyle(color: Colors.grey)),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => _contacts.remove(c)); _saveEmergencyData(); }),
            )),
            ListTile(leading: const Icon(Icons.add, color: Colors.purple), title: const Text("Kişi Ekle", style: TextStyle(color: Colors.purple)), onTap: _addContact),
            const SizedBox(height: 30),
            _sectionHeader("ACİL DURUM MESAJI"),
            TextField(
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) { _customMessage = v; _saveEmergencyData(); },
              decoration: InputDecoration(
                hintText: _customMessage,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            _emergencyButton(Icons.send, "TEK TUŞLA YARDIM İSTE", Colors.purple, _sendHelpSignal),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(padding: const EdgeInsets.symmetric(vertical: 15), child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12))));

  Widget _emergencyButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 28),
        label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
}
