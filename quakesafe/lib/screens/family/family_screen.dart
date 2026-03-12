import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'chat_screen.dart';
import 'dart:math';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      final response = await _supabase
          .from('family_members')
          .select('group_id, family_groups(*)')
          .eq('user_id', userId);

      setState(() {
        _groups = response;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createGroup() async {
    final nameController = TextEditingController();
    final cityController = TextEditingController();
    final meetingPointController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Yeni Grup Oluştur", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameController, "Grup İsmi", Icons.group),
              _dialogField(cityController, "Şehir", Icons.location_city),
              _dialogField(meetingPointController, "Toplanma Alanı (Açıklama)", Icons.map),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              try {
                final inviteCode = _generateInviteCode();
                final groupResponse = await _supabase.from('family_groups').insert({
                  'name': nameController.text,
                  'city': cityController.text,
                  'meeting_point_text': meetingPointController.text,
                  'invite_code': inviteCode,
                }).select().single();

                await _supabase.from('family_members').insert({
                  'group_id': groupResponse['id'],
                  'user_id': _supabase.auth.currentUser!.id,
                  'role': 'admin',
                });

                if (mounted) Navigator.pop(context);
                _fetchGroups();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Oluştur", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _joinGroup() async {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Gruba Katıl", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: _dialogField(codeController, "Davet Kodu", Icons.vpn_key),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              try {
                final group = await _supabase.from('family_groups').select().eq('invite_code', codeController.text.trim()).single();
                await _supabase.from('family_members').insert({
                  'group_id': group['id'],
                  'user_id': _supabase.auth.currentUser!.id,
                  'role': 'member',
                });
                if (mounted) Navigator.pop(context);
                _fetchGroups();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz davet kodu veya zaten üyesiniz!")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text("Katıl", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _generateInviteCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Widget _dialogField(TextEditingController controller, String hint, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.purple, size: 20),
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Ailem"), backgroundColor: Colors.black, actions: [IconButton(onPressed: _fetchGroups, icon: const Icon(Icons.refresh, color: Colors.purple))]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(child: _actionButton(Icons.add_circle_outline, "Grup Oluştur", Colors.purple, _createGroup)),
                      const SizedBox(width: 12),
                      Expanded(child: _actionButton(Icons.group_add_outlined, "Gruba Katıl", Colors.blue[900]!, _joinGroup)),
                    ],
                  ),
                ),
                Expanded(
                  child: _groups.isEmpty
                      ? Center(child: Text("Henüz bir grubunuz yok.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index]['family_groups'];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: const Color(0xFF1A1A1A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(15)),
                                  child: const Icon(Icons.groups_rounded, color: Colors.purple),
                                ),
                                title: Text(group['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                subtitle: Text("Kod: ${group['invite_code']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(groupId: group['id'].toString(), groupName: group['name'])));
                                },
                              ),
                            ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 22),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
    );
  }
}
