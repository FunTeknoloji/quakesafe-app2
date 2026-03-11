import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      // Get groups where user is a member
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ailem")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _actionButton(Icons.add, "Grup Oluştur", Colors.purple, () {}),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(Icons.group_add, "Gruba Katıl", Colors.blue, () {}),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _groups.isEmpty
                      ? const Center(child: Text("Henüz bir grubunuz yok."))
                      : ListView.builder(
                          itemCount: _groups.length,
                          itemBuilder: (context, index) {
                            final group = _groups[index]['family_groups'];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.group)),
                                title: Text(group['name']),
                                subtitle: const Text("Mesajları görmek için tıklayın"),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  // Navigate to ChatScreen
                                },
                              ),
                            ).animate().fadeIn(delay: (index * 50).ms).slideX();
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
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
