import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'settings_screen.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase.from('profiles_quakesafe').select().eq('id', userId).single();
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.purple),
            onPressed: () async {
              if (_profile != null) {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen(profile: _profile!)));
                if (result == true) _fetchProfile();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.purple),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildInfoGrid(),
                  const SizedBox(height: 30),
                  _buildMedicalInfo(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              backgroundImage: _profile?['avatar_url'] != null ? NetworkImage(_profile!['avatar_url']) : null,
              child: _profile?['avatar_url'] == null ? const Icon(Icons.person, size: 60, color: Colors.purple) : null,
            ),
            GestureDetector(
              onTap: () {
                // Logic for avatar update
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fotoğraf güncelleme yakında eklenecek!")));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(_profile?['full_name'] ?? "Kullanıcı", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(_supabase.auth.currentUser?.email ?? "", style: const TextStyle(color: Colors.grey)),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _infoCard(Icons.phone, "Telefon", _profile?['phone']),
        _infoCard(Icons.location_city, "Şehir", _profile?['city']),
        _infoCard(Icons.bloodtype, "Kan Grubu", _profile?['blood_type']),
        _infoCard(Icons.wc, "Cinsiyet", _profile?['gender']),
        _infoCard(Icons.cake, "Doğum Tarihi", _profile?['birth_date']),
        _infoCard(Icons.monitor_weight, "Kilo", "${_profile?['weight'] ?? '-'} kg"),
        _infoCard(Icons.height, "Boy", "${_profile?['height'] ?? '-'} cm"),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildMedicalInfo() {
    return Column(
      children: [
        _longInfoCard(Icons.warning_amber, "Alerjiler", _profile?['allergies']),
        _longInfoCard(Icons.medication, "İlaçlar", _profile?['medications']),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _infoCard(IconData icon, String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                Text(value?.toString() ?? "Girilmemiş", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _longInfoCard(IconData icon, String label, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple, size: 20),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value?.toString() ?? "Belirtilmemiş", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
