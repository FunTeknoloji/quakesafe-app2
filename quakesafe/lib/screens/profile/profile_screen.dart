import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'settings_screen.dart';
import 'profile_edit_screen.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final local = _authService.getLocalProfile();
    if (local != null) {
      setState(() { _profile = local; _isLoading = false; });
    }
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase.from('profiles_quakesafe').select().eq('id', userId).single();
      setState(() { _profile = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black background
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.purple))
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                backgroundColor: Colors.black,
                pinned: true,
                elevation: 0,
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text("Profilim", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  centerTitle: true,
                  titlePadding: EdgeInsets.only(bottom: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildMainCard(),
                    const SizedBox(height: 20),
                    _buildEmergencyTitle(),
                    _buildInfoGrid(),
                    _buildLongInfoSection("Alerjiler", _profile?['allergies'], Icons.warning_amber_rounded, Colors.orange),
                    _buildLongInfoSection("Kullanılan İlaçlar", _profile?['medications'], Icons.medication_outlined, Colors.blue),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(color: Colors.purple.withValues(alpha: 0.05), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white10,
                      backgroundImage: _profile?['avatar_url'] != null ? NetworkImage(_profile!['avatar_url']) : null,
                      child: _profile?['avatar_url'] == null ? const Icon(Icons.person, size: 40, color: Colors.white24) : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_profile?['full_name'] ?? "Bilinmiyor", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(_supabase.auth.currentUser?.email ?? "", style: const TextStyle(color: Colors.white38, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.purple, size: 12),
                          const SizedBox(width: 4),
                          Text(_profile?['city'] ?? "Türkiye", style: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileEditScreen(profile: _profile!)));
                    if (res == true) _loadProfile();
                  },
                  icon: const Icon(Icons.edit_note, size: 20),
                  label: const Text("Düzenle"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(15)),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  onPressed: _showQRCode,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmergencyTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.medical_services_outlined, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          const Text("ACİL DURUM KARTI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 14)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(4)),
            child: const Text("HAYATİ", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _infoTile("KAN", _profile?['blood_type'] ?? "-", Icons.bloodtype, Colors.red),
          _infoTile("BOY", "${_profile?['height'] ?? '-'} cm", Icons.straighten, Colors.green),
          _infoTile("KİLO", "${_profile?['weight'] ?? '-'} kg", Icons.monitor_weight_outlined, Colors.orange),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.5), size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showQRCode() {
    final String shareUrl = "https://quakesafe.funteknoloji.com/profile/share/${_supabase.auth.currentUser!.id}";
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("ACİL DURUM KARTI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: QrImageView(data: shareUrl, size: 200, version: QrVersions.auto),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _qrAction(Icons.copy, "Kopyala", () {
                  Clipboard.setData(ClipboardData(text: shareUrl));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link kopyalandı!")));
                }),
                _qrAction(Icons.share, "Paylaş", () => Share.share("Acil Durum Bilgilerim: $shareUrl")),
                _qrAction(Icons.download, "İndir", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("QR Kod kaydedildi!")))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Colors.white10, child: Icon(icon, color: Colors.purple, size: 20)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildLongInfoSection(String title, String? value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value ?? "Belirtilmedi", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
