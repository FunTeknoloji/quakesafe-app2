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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeCard> _cards = [];

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
      HomeCard(id: 'spirit_level', title: 'Su Terazisi', icon: _iconMap['spirit_level']!),
      HomeCard(id: 'compass', title: 'Pusula', icon: _iconMap['compass']!),
      HomeCard(id: 'daily_tip', title: 'Günün Bilgisi', icon: _iconMap['daily_tip']!),
      HomeCard(id: 'assembly_areas', title: 'Toplanma Alanları', icon: _iconMap['assembly_areas']!),
      HomeCard(id: 'family_groups', title: 'Aile Grupları', icon: _iconMap['family_groups']!),
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
        orderedCards.add(card);
      }
      // Add any missing cards
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
    switch (card.id) {
      case 'quick_tools':
        return QuickToolsWidget(key: ValueKey(card.id));
      case 'status_report':
        return StatusReportWidget(key: ValueKey(card.id));
      case 'last_quake':
        return LastQuakeWidget(key: ValueKey(card.id));
      case 'spirit_level':
        return SpiritLevelWidget(key: ValueKey(card.id));
      case 'compass':
        return CompassWidget(key: ValueKey(card.id));
      case 'daily_tip':
        return DailyTipWidget(key: ValueKey(card.id));
      case 'assembly_areas':
        return AssemblyAreaWidget(key: ValueKey(card.id));
      default:
        return PlaceholderCard(key: ValueKey(card.id), title: card.title, icon: card.icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuakeSafe"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: ReorderableListView(
        onReorder: _onReorder,
        children: _cards.map((card) => _buildCardWidget(card)).toList(),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimler")),
      body: const Center(child: Text("Henüz bildiriminiz yok.")),
    );
  }
}
