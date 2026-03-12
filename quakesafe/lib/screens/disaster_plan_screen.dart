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
      appBar: AppBar(title: const Text("Afet Planı"), backgroundColor: Colors.black, actions: [IconButton(icon: const Icon(Icons.save, color: Colors.purple), onPressed: _savePlan)]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _planCategory("Toplanma", "toplanma", Icons.meeting_room),
          _planCategory("Görevler", "görevler", Icons.assignment_turned_in),
          _planCategory("Güvenlik", "güvenlik", Icons.security),
          _planCategory("Evraklar", "evraklar", Icons.folder),
          _planCategory("Stoklar", "stoklar", Icons.inventory),
          _planCategory("Dostlarımız", "dostlarımız", Icons.pets),
        ],
      ),
    );
  }

  Widget _planCategory(String title, String key, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.purple),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 4,
              controller: TextEditingController(text: _plan[key])..selection = TextSelection.fromPosition(TextPosition(offset: _plan[key].length)),
              onChanged: (v) => _plan[key] = v,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Detayları girin...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
