import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen> {
  List<Map<String, String>> _contacts = [];
  String _customMessage = "Acil durum! Yardıma ihtiyacım var. Konumum: >konum<";
  bool _isSending = false;

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
      // First ensure we have permission
      bool permission = await FlutterContacts.requestPermission();
      if (!permission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rehber izni verilmedi. Lütfen ayarlardan izin verin."))
          );
        }
        return;
      }

      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        // Fetch full contact details since pick might only return partial info
        final fullContact = await FlutterContacts.getContact(contact.id);
        if (fullContact != null && fullContact.phones.isNotEmpty) {
          String phone = fullContact.phones.first.number.replaceAll(RegExp(r'\D'), '');
          setState(() {
            _contacts.add({
              'name': fullContact.displayName,
              'phone': phone,
            });
          });
          _saveEmergencyData();
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rehber hatası: $e")));
    }
  }

  Future<void> _sendHelpSignal() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen önce acil durum kişisi ekleyin!")));
      return;
    }

    setState(() => _isSending = true);

    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
      } catch (_) {}

      String locationStr = pos != null
          ? "https://maps.google.com/?q=${pos.latitude},${pos.longitude}"
          : "[Konum Alınamadı]";

      String finalMsg = _customMessage.replaceAll(">konum<", locationStr);

      // Join numbers with semicolon for Android, comma for iOS
      String separator = ";";
      String numbers = _contacts.map((c) => c['phone']).join(separator);

      final Uri smsUri = Uri.parse("sms:$numbers?body=${Uri.encodeComponent(finalMsg)}");

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        // Fallback: Try one by one if bulk fails
        for (var contact in _contacts) {
          final Uri singleUri = Uri.parse("sms:${contact['phone']}?body=${Uri.encodeComponent(finalMsg)}");
          if (await canLaunchUrl(singleUri)) {
            await launchUrl(singleUri);
          }
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sinyal hatası: $e")));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Acil Çağrı & SOS", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCall112(),
            const SizedBox(height: 32),
            _sectionHeader("ACİL DURUM KİŞİLERİ"),
            const SizedBox(height: 12),
            _buildContactList(),
            _buildAddButton(),
            const SizedBox(height: 32),
            _sectionHeader("SOS MESAJI"),
            const SizedBox(height: 12),
            _buildMessageInput(),
            const SizedBox(height: 40),
            _buildSOSButton(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCall112() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => FlutterPhoneDirectCaller.callNumber('112'),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("112 ACİL SERVİS", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    Text("Hemen ara", style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildContactList() {
    if (_contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
        child: const Center(child: Text("Henüz kişi eklenmedi.", style: TextStyle(color: Colors.white38, fontSize: 13))),
      );
    }
    return Column(
      children: _contacts.map((c) => _contactTile(c)).toList(),
    );
  }

  Widget _contactTile(Map<String, String> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.person, color: Colors.white)),
        title: Text(c['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(c['phone']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
          onPressed: () {
            setState(() => _contacts.remove(c));
            _saveEmergencyData();
          },
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return TextButton.icon(
      onPressed: _addContact,
      icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
      label: const Text("Rehberden Kişi Ekle", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMessageInput() {
    return TextField(
      maxLines: 3,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (v) { _customMessage = v; _saveEmergencyData(); },
      decoration: InputDecoration(
        hintText: "Mesajınızı buraya yazın...",
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildSOSButton() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(colors: [Colors.purple, Color(0xFF4527A0)]),
        boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ElevatedButton(
        onPressed: _isSending ? null : _sendHelpSignal,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isSending
            ? const CircularProgressIndicator(color: Colors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, color: Colors.white),
                  SizedBox(width: 12),
                  Text("SOS SMS GÖNDER", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ],
              ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 11),
      ),
    );
  }
}
