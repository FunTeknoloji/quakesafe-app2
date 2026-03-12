import 'package:flutter/material.dart';
import '../../services/disaster_plan_service.dart';

class DisasterPlanScreen extends StatefulWidget {
  const DisasterPlanScreen({super.key});

  @override
  State<DisasterPlanScreen> createState() => _DisasterPlanScreenState();
}

class _DisasterPlanScreenState extends State<DisasterPlanScreen> {
  final _planService = DisasterPlanService();
  Map<String, dynamic> _plan = {
    'toplanma': '',
    'görevler': '',
    'güvenlik': '',
    'evraklar': '',
    'stoklar': '',
    'dostlarımız': '',
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    final data = await _planService.getPlan();
    if (data != null) {
      setState(() {
        _plan = {..._plan, ...data};
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePlan() async {
    await _planService.savePlan(_plan);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plan kaydedildi!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Afet Planı", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded, color: Colors.purple),
            onPressed: _savePlan
          )
        ]
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _planCategory("Toplanma", "toplanma", Icons.meeting_room, "Ailenizle nerede buluşacaksınız?"),
                      _planCategory("Görevler", "görevler", Icons.assignment_turned_in, "Kim hangi çantayı alacak, kim kime bakacak?"),
                      _planCategory("Güvenlik", "güvenlik", Icons.security, "Vanalar, şalterler nerede? Kapatma sırası nedir?"),
                      _planCategory("Evraklar", "evraklar", Icons.folder, "Tapu, kimlik, sigorta kopyaları nerede?"),
                      _planCategory("Stoklar", "stoklar", Icons.inventory, "Gıda, su ve ilaç stoklarınızın yeri."),
                      _planCategory("Dostlarımız", "dostlarımız", Icons.pets, "Evcil hayvanlarınız için tahliye planı."),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.purple, Color(0xFF6A1B9A)]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.white, size: 40),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hazırlık Hayat Kurtarır", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(height: 4),
                Text("Afet anında ne yapacağınızı önceden planlayın ve tüm aileyle paylaşın.", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCategory(String title, String key, IconData icon, String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.withValues(alpha: 0.1),
            child: Icon(icon, color: Colors.purple, size: 20),
          ),
          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(_plan[key].isEmpty ? "Henüz planlanmadı" : "Planlandı", style: TextStyle(color: _plan[key].isEmpty ? Colors.grey : Colors.green, fontSize: 11)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: TextEditingController(text: _plan[key])..selection = TextSelection.fromPosition(TextPosition(offset: _plan[key].length)),
                onChanged: (v) => setState(() => _plan[key] = v),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
