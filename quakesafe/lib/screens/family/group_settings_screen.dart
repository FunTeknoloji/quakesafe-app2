import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
import '../../translations.dart';

class FamilyGroupSettingsScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final bool isAdmin;
  const FamilyGroupSettingsScreen({super.key, required this.groupId, required this.groupName, required this.isAdmin});

  @override
  State<FamilyGroupSettingsScreen> createState() => _FamilyGroupSettingsScreenState();
}

class _FamilyGroupSettingsScreenState extends State<FamilyGroupSettingsScreen> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final data = await _supabase
          .from('family_members')
          .select('user_id, role, profiles_quakesafe(full_name, city)')
          .eq('group_id', widget.groupId);
      setState(() {
        _members = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeMember(String userId) async {
    try {
      await _supabase.from('family_members').delete().eq('group_id', widget.groupId).eq('user_id', userId);
      _fetchMembers();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Üye gruptan çıkarıldı.")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.groupName), backgroundColor: Colors.black),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("GRUP ÜYELERİ", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                ..._members.map((m) => _memberTile(m)),
                if (widget.isAdmin) ...[
                  const SizedBox(height: 40),
                  const Text("YÖNETİCİ ARAÇLARI", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  _adminAction("Grubu Dağıt", Icons.delete_forever, Colors.red, () {
                    // Logic to delete group
                  }),
                ]
              ],
            ),
    );
  }

  Widget _memberTile(dynamic m) {
    final profile = m['profiles_quakesafe'];
    final bool isMe = m['user_id'] == _supabase.auth.currentUser!.id;
    final bool isOtherAdmin = m['role'] == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(profile['full_name'] ?? "İsimsiz", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(m['role'] == 'admin' ? "Yönetici" : "Üye", style: TextStyle(color: m['role'] == 'admin' ? Colors.purple : Colors.white24, fontSize: 12)),
        trailing: widget.isAdmin && !isMe && !isOtherAdmin
            ? IconButton(
                icon: const Icon(Icons.person_remove, color: Colors.redAccent, size: 20),
                onPressed: () => _removeMember(m['user_id']),
              )
            : null,
      ),
    );
  }

  Widget _adminAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      onTap: onTap,
    );
  }
}
