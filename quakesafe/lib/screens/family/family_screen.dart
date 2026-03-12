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
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      final response = await _supabase
          .from('family_members')
          .select('group_id, family_groups(*)')
          .eq('user_id', userId!);

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
    final locationController = TextEditingController();
    final assemblyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Yeni Grup Oluştur", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nameController, "Grup İsmi"),
            _dialogField(locationController, "Ev Konumu (Adres)"),
            _dialogField(assemblyController, "Toplanma Alanı"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İptal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty) return;
              final inviteCode = _generateInviteCode();
              final group = await _supabase.from('family_groups').insert({
                'name': nameController.text,
                'location': locationController.text,
                'assembly_area': assemblyController.text,
                'invite_code': inviteCode,
              }).select().single();

              await _supabase.from('family_members').insert({
                'group_id': group['id'],
                'user_id': _supabase.auth.currentUser!.id,
                'role': 'admin',
              });

              Navigator.pop(context);
              _fetchGroups();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
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
        backgroundColor: Colors.grey[900],
        title: const Text("Gruba Katıl", style: TextStyle(color: Colors.white)),
        content: _dialogField(codeController, "Davet Kodu"),
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
                Navigator.pop(context);
                _fetchGroups();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Geçersiz davet kodu!")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Katıl", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _generateInviteCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  Widget _dialogField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Ailem"), backgroundColor: Colors.black),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(child: _actionButton(Icons.add, "Grup Oluştur", Colors.purple, _createGroup)),
                      const SizedBox(width: 12),
                      Expanded(child: _actionButton(Icons.group_add, "Gruba Katıl", Colors.blue[900]!, _joinGroup)),
                    ],
                  ),
                ),
                Expanded(
                  child: _groups.isEmpty
                      ? const Center(child: Text("Henüz bir grubunuz yok.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index]['family_groups'];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: Colors.white.withOpacity(0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.group, color: Colors.purple),
                                ),
                                title: Text(group['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                subtitle: Text("Kod: ${group['invite_code']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(groupId: group['id'].toString(), groupName: group['name'])));
                                },
                              ),
                            ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
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
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );
  }
}
