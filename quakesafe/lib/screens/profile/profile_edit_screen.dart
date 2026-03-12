import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ProfileEditScreen({super.key, required this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _supabase = Supabase.instance.client;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _bloodController;
  late TextEditingController _allergiesController;
  late TextEditingController _medsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['full_name']);
    _phoneController = TextEditingController(text: widget.profile['phone']);
    _cityController = TextEditingController(text: widget.profile['city']);
    _bloodController = TextEditingController(text: widget.profile['blood_type']);
    _allergiesController = TextEditingController(text: widget.profile['allergies']);
    _medsController = TextEditingController(text: widget.profile['medications']);
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('profiles_quakesafe').update({
        'full_name': _nameController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'blood_type': _bloodController.text,
        'allergies': _allergiesController.text,
        'medications': _medsController.text,
      }).eq('id', _supabase.auth.currentUser!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil güncellendi!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Profili Düzenle"), backgroundColor: Colors.black, actions: [
        if (_isLoading) const Padding(padding: EdgeInsets.all(15), child: CircularProgressIndicator(strokeWidth: 2))
        else IconButton(icon: const Icon(Icons.check, color: Colors.purple), onPressed: _save)
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _editField(_nameController, "Ad Soyad", Icons.person),
            _editField(_phoneController, "Telefon", Icons.phone),
            _editField(_cityController, "Şehir", Icons.location_city),
            _editField(_bloodController, "Kan Grubu", Icons.bloodtype),
            _editField(_allergiesController, "Alerjiler", Icons.warning),
            _editField(_medsController, "İlaçlar", Icons.medication),
          ],
        ),
      ),
    );
  }

  Widget _editField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.purple),
          prefixIcon: Icon(icon, color: Colors.purple, size: 20),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.purple)),
        ),
      ),
    );
  }
}
