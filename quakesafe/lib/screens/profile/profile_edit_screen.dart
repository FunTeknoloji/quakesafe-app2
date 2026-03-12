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
    _nameController = TextEditingController(text: widget.profile['full_name']?.toString() ?? "");
    _phoneController = TextEditingController(text: widget.profile['phone']?.toString() ?? "");
    _allergiesController = TextEditingController(text: widget.profile['allergies']?.toString() ?? "");
    _medsController = TextEditingController(text: widget.profile['medications']?.toString() ?? "");

    _selectedCity = widget.profile['city']?.toString();
    _selectedBloodType = widget.profile['blood_type']?.toString();
    _selectedGender = widget.profile['gender']?.toString();
    _selectedHeight = widget.profile['height'] != null ? int.tryParse(widget.profile['height'].toString()) : null;
    _selectedWeight = widget.profile['weight'] != null ? int.tryParse(widget.profile['weight'].toString()) : null;
    if (widget.profile['birth_date'] != null) {
      _selectedBirthDate = DateTime.tryParse(widget.profile['birth_date'].toString());
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
        title: const Text("Bilgileri Güncelle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.purple, strokeWidth: 2)))
          else TextButton(onPressed: _save, child: const Text("Kaydet", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kişisel Bilgiler", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildTextField(_nameController, "Ad Soyad", Icons.person_outline),
            _buildTextField(_phoneController, "Telefon Numarası", Icons.phone_android_outlined),
            _buildPicker("İkamet Şehri", _selectedCity, _cities, (v) => setState(() => _selectedCity = v)),
            _buildPicker("Cinsiyet", _selectedGender, _genders, (v) => setState(() => _selectedGender = v)),
            _buildDatePicker(),

            const SizedBox(height: 24),
            const Text("Hayati Bilgiler (Acil Durum)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _buildPicker("Kan Grubu", _selectedBloodType, _bloodTypes, (v) => setState(() => _selectedBloodType = v)),
            Row(
              children: [
                Expanded(child: _buildNumberPicker("Boy (cm)", _selectedHeight, 50, 250, (v) => setState(() => _selectedHeight = v))),
                const SizedBox(width: 12),
                Expanded(child: _buildNumberPicker("Kilo (kg)", _selectedWeight, 20, 300, (v) => setState(() => _selectedWeight = v))),
              ],
            ),
            _buildTextField(_allergiesController, "Kronik Alerjiler", Icons.warning_amber_outlined),
            _buildTextField(_medsController, "Düzenli Kullanılan İlaçlar", Icons.medication_outlined),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.purple, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildPicker(String label, String? value, List<String> items, Function(String) onSelect) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
          builder: (context) => Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
              Padding(padding: const EdgeInsets.all(20), child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(items[index], style: const TextStyle(color: Colors.white70)),
                    onTap: () { onSelect(items[index]); Navigator.pop(context); },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 4),
                Text(value ?? "Seçiniz", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPicker(String label, int? value, int min, int max, Function(int) onSelect) {
    return _buildPicker(label, value?.toString(), List.generate(max - min + 1, (i) => (min + i).toString()), (v) => onSelect(int.parse(v)));
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedBirthDate ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: Colors.purple, onPrimary: Colors.white, surface: Color(0xFF1E1E1E))), child: child!),
        );
        if (date != null) setState(() => _selectedBirthDate = date);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Doğum Tarihi", style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(height: 4),
                Text(_selectedBirthDate != null ? DateFormat('dd MMMM yyyy', 'tr').format(_selectedBirthDate!) : "Seçiniz", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              ],
            ),
            const Icon(Icons.calendar_month_outlined, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}
