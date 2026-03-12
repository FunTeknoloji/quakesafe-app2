import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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
  late TextEditingController _allergiesController;
  late TextEditingController _medsController;

  String? _selectedCity;
  String? _selectedBloodType;
  String? _selectedGender;
  int? _selectedHeight;
  int? _selectedWeight;
  DateTime? _selectedBirthDate;

  bool _isLoading = false;

  final List<String> _cities = [
    "Adana", "Adıyaman", "Afyonkarahisar", "Ağrı", "Amasya", "Ankara", "Antalya", "Artvin", "Aydın", "Balıkesir", "Bilecik", "Bingöl", "Bitlis", "Bolu", "Burdur", "Bursa", "Çanakkale", "Çankırı", "Çorum", "Denizli", "Diyarbakır", "Edirne", "Elazığ", "Erzincan", "Erzurum", "Eskişehir", "Gaziantep", "Giresun", "Gümüşhane", "Hakkari", "Hatay", "Isparta", "Mersin", "İstanbul", "İzmir", "Kars", "Kastamonu", "Kayseri", "Kırklareli", "Kırşehir", "Kocaeli", "Konya", "Kütahya", "Malatya", "Manisa", "Kahramanmaraş", "Mardin", "Muğla", "Muş", "Nevşehir", "Niğde", "Ordu", "Rize", "Sakarya", "Samsun", "Siirt", "Sinop", "Sivas", "Tekirdağ", "Tokat", "Trabzon", "Tunceli", "Şanlıurfa", "Uşak", "Van", "Yozgat", "Zonguldak", "Aksaray", "Bayburt", "Karaman", "Kırıkkale", "Batman", "Şırnak", "Bartın", "Ardahan", "Iğdır", "Yalova", "Karabük", "Kilis", "Osmaniye", "Düzce"
  ];

  final List<String> _bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "0+", "0-"];
  final List<String> _genders = ["Erkek", "Kadın", "Belirtmek İstemiyorum"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['full_name']);
    _phoneController = TextEditingController(text: widget.profile['phone']);
    _allergiesController = TextEditingController(text: widget.profile['allergies']);
    _medsController = TextEditingController(text: widget.profile['medications']);

    _selectedCity = widget.profile['city'];
    _selectedBloodType = widget.profile['blood_type'];
    _selectedGender = widget.profile['gender'];
    _selectedHeight = widget.profile['height'] != null ? int.tryParse(widget.profile['height'].toString()) : null;
    _selectedWeight = widget.profile['weight'] != null ? int.tryParse(widget.profile['weight'].toString()) : null;
    if (widget.profile['birth_date'] != null) {
      _selectedBirthDate = DateTime.tryParse(widget.profile['birth_date']);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.from('profiles_quakesafe').update({
        'full_name': _nameController.text,
        'phone': _phoneController.text,
        'city': _selectedCity,
        'blood_type': _selectedBloodType,
        'gender': _selectedGender,
        'height': _selectedHeight,
        'weight': _selectedWeight,
        'birth_date': _selectedBirthDate?.toIso8601String(),
        'allergies': _allergiesController.text,
        'medications': _medsController.text,
      }).eq('id', _supabase.auth.currentUser!.id);

      if (mounted) Navigator.pop(context, true);
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
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: Colors.black,
        actions: [
          if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
          else IconButton(icon: const Icon(Icons.check, color: Colors.purple), onPressed: _save)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField(_nameController, "Ad Soyad", Icons.person),
            _buildTextField(_phoneController, "Telefon", Icons.phone),
            _buildPicker("Şehir", _selectedCity, _cities, (v) => setState(() => _selectedCity = v)),
            _buildPicker("Kan Grubu", _selectedBloodType, _bloodTypes, (v) => setState(() => _selectedBloodType = v)),
            _buildPicker("Cinsiyet", _selectedGender, _genders, (v) => setState(() => _selectedGender = v)),
            _buildNumberPicker("Boy (cm)", _selectedHeight, 50, 250, (v) => setState(() => _selectedHeight = v)),
            _buildNumberPicker("Kilo (kg)", _selectedWeight, 20, 300, (v) => setState(() => _selectedWeight = v)),
            _buildDatePicker(),
            _buildTextField(_allergiesController, "Alerjiler", Icons.warning),
            _buildTextField(_medsController, "İlaçlar", Icons.medication),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.purple, size: 20),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.purple)),
        ),
      ),
    );
  }

  Widget _buildPicker(String label, String? value, List<String> items, Function(String) onSelect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF1E1E1E),
            builder: (context) => ListView(
              children: items.map((i) => ListTile(
                title: Text(i, style: const TextStyle(color: Colors.white)),
                onTap: () { onSelect(i); Navigator.pop(context); },
              )).toList(),
            ),
          );
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
          ),
          child: Text(value ?? "Seçiniz", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildNumberPicker(String label, int? value, int min, int max, Function(int) onSelect) {
    return _buildPicker(label, value?.toString(), List.generate(max - min + 1, (i) => (min + i).toString()), (v) => onSelect(int.parse(v)));
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedBirthDate ?? DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) setState(() => _selectedBirthDate = date);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Doğum Tarihi",
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white12)),
          ),
          child: Text(_selectedBirthDate != null ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!) : "Seçiniz", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
