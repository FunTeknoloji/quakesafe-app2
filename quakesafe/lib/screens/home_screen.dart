import 'package:flutter/material.dart';
import '../models/home_card.dart';
import '../services/storage_service.dart';
import '../widgets/quick_tools_widget.dart';
import '../widgets/last_quake_widget.dart';
import '../widgets/status_report_widget.dart';
import '../widgets/spirit_level_widget.dart';
import '../widgets/compass_widget.dart';
import '../widgets/daily_tip_widget.dart';
import '../widgets/assembly_area_widget.dart';
import '../widgets/placeholder_card.dart';
import 'notifications/notifications_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeCard> _cards = [];
  bool _isEditMode = false;

  final Map<String, IconData> _iconMap = {
    'quick_tools': Icons.bolt,
    'status_report': Icons.report,
    'last_quake': Icons.waves,
    'spirit_level': Icons.square_foot,
    'compass': Icons.explore,
    'daily_tip': Icons.lightbulb,
    'assembly_areas': Icons.map,
    'family_groups': Icons.group,
    'voice_assistant': Icons.mic,
    'news': Icons.newspaper,
    'emergency_numbers': Icons.phone,
    'quick_guides': Icons.menu_book,
    'donate': Icons.volunteer_activism,
    'weather': Icons.cloud,
  };

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    final order = await StorageService.getCardOrder();
    final List<HomeCard> defaultCards = [
      HomeCard(id: 'quick_tools', title: 'Hızlı Araçlar', icon: _iconMap['quick_tools']!),
      HomeCard(id: 'status_report', title: 'Durum Bildirme', icon: _iconMap['status_report']!),
      HomeCard(id: 'last_quake', title: 'Son Depremler', icon: _iconMap['last_quake']!),
      HomeCard(id: 'family_groups', title: 'Aile Grupları', icon: _iconMap['family_groups']!),
      HomeCard(id: 'spirit_level', title: 'Su Terazisi', icon: _iconMap['spirit_level']!),
      HomeCard(id: 'compass', title: 'Pusula', icon: _iconMap['compass']!),
      HomeCard(id: 'daily_tip', title: 'Günün Bilgisi', icon: _iconMap['daily_tip']!),
      HomeCard(id: 'assembly_areas', title: 'Toplanma Alanları', icon: _iconMap['assembly_areas']!),
      HomeCard(id: 'voice_assistant', title: 'Sesli Asistan', icon: _iconMap['voice_assistant']!),
      HomeCard(id: 'news', title: 'Haberler', icon: _iconMap['news']!),
      HomeCard(id: 'emergency_numbers', title: 'Acil Numaralar', icon: _iconMap['emergency_numbers']!),
      HomeCard(id: 'quick_guides', title: 'Hızlı Rehberler', icon: _iconMap['quick_guides']!),
      HomeCard(id: 'donate', title: 'Bağış Yap', icon: _iconMap['donate']!),
      HomeCard(id: 'weather', title: 'Hava Durumu', icon: _iconMap['weather']!),
    ];

    if (order != null) {
      List<HomeCard> orderedCards = [];
      for (var id in order) {
        final card = defaultCards.firstWhere((element) => element.id == id, orElse: () => defaultCards.first);
        if (!orderedCards.any((e) => e.id == card.id)) orderedCards.add(card);
      }
      for (var card in defaultCards) {
        if (!orderedCards.any((element) => element.id == card.id)) {
          orderedCards.add(card);
        }
      }
      setState(() {
        _cards = orderedCards;
      });
    } else {
      setState(() {
        _cards = defaultCards;
      });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, item);
      StorageService.saveCardOrder(_cards.map((e) => e.id).toList());
    });
  }

  Widget _buildCardWidget(HomeCard card) {
    Widget child;
    switch (card.id) {
      case 'quick_tools':
        child = QuickToolsWidget(key: ValueKey(card.id));
        break;
      case 'status_report':
        child = StatusReportWidget(key: ValueKey(card.id));
        break;
      case 'last_quake':
        child = LastQuakeWidget(key: ValueKey(card.id));
        break;
      case 'spirit_level':
        child = SpiritLevelWidget(key: ValueKey(card.id));
        break;
      case 'compass':
        child = CompassWidget(key: ValueKey(card.id));
        break;
      case 'daily_tip':
        child = DailyTipWidget(key: ValueKey(card.id));
        break;
      case 'assembly_areas':
        child = AssemblyAreaWidget(key: ValueKey(card.id));
        break;
      default:
        child = PlaceholderCard(key: ValueKey(card.id), title: card.title, icon: card.icon);
    }
    return child.animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuakeSafe"),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit, color: Colors.purple),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
        ],
      ),
      body: _isEditMode
          ? ReorderableListView(
              padding: const EdgeInsets.only(bottom: 20),
              onReorder: _onReorder,
              children: _cards.map((card) => _buildEditCard(card)).toList(),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: _cards.map((card) => _buildCardWidget(card)).toList(),
            ),
    );
  }

  Widget _buildEditCard(HomeCard card) {
    return Card(
      key: ValueKey("edit_${card.id}"),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(card.icon, color: Colors.purple),
        title: Text(card.title),
        trailing: const Icon(Icons.drag_handle),
      ),
    );
  }
}
