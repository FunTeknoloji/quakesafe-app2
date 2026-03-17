import 'package:flutter/material.dart';
import '../models/home_card.dart';
import '../services/storage_service.dart';
import '../widgets/quick_tools_widget.dart';
import '../widgets/recent_chats_widget.dart';
import '../widgets/status_report_widget.dart';
import '../widgets/spirit_level_widget.dart';
import '../widgets/compass_widget.dart';
import '../widgets/daily_tip_widget.dart';
import '../widgets/assembly_area_widget.dart';
import '../widgets/weather_widget.dart';
import '../widgets/last_quake_widget.dart';
import '../widgets/placeholder_card.dart';
import 'notifications/notifications_screen.dart';
import '../translations.dart';
import '../services/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import 'package:torch_light/torch_light.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeCard> _cards = [];
  bool _isEditMode = false;
  final _storageService = StorageService();

  final Map<String, IconData> _iconMap = {
    'quick_tools': Icons.bolt,
    'emergency_numbers': Icons.phone,
    'assembly_areas': Icons.map,
    'daily_tip': Icons.lightbulb,
    'quick_guides': Icons.menu_book,
    'donate': Icons.volunteer_activism,
    'weather': Icons.cloud,
    'last_quake': Icons.waves,
    'status_report': Icons.report,
    'compass': Icons.explore,
    'spirit_level': Icons.square_foot,
  };

  @override
  void initState() {
    super.initState();
    _loadCards();
    _setupHomeWidget();
  }

  void _setupHomeWidget() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetAction);
    HomeWidget.widgetClicked.listen(_handleWidgetAction);
  }

  void _handleWidgetAction(Uri? uri) async {
    if (uri == null) return;
    if (uri.host == 'status') {
      final type = uri.queryParameters['type'];
      StatusReportWidget.reportStatus(context, type == 'safe');
    }
  }

  void _loadCards() async {
    final order = await _storageService.getCardOrder();
    final List<HomeCard> defaultCards = [
      HomeCard(id: 'emergency_numbers', title: 'Acil Numaralar', icon: _iconMap['emergency_numbers']!),
      HomeCard(id: 'assembly_areas', title: 'Toplanma Alanları', icon: _iconMap['assembly_areas']!),
      HomeCard(id: 'daily_tip', title: 'Günün Bilgisi', icon: _iconMap['daily_tip']!),
      HomeCard(id: 'weather', title: 'Hava Durumu', icon: _iconMap['weather']!),
      HomeCard(id: 'last_quake', title: 'Son Depremler', icon: _iconMap['last_quake']!),
      HomeCard(id: 'status_report', title: 'Durum Bildirme', icon: _iconMap['status_report']!),
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
      setState(() { _cards = orderedCards; });
    } else {
      setState(() { _cards = defaultCards; });
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _cards.removeAt(oldIndex);
      _cards.insert(newIndex, item);
      _storageService.saveCardOrder(_cards.map((e) => e.id).toList());
    });
  }

  Widget _buildCardWidget(HomeCard card) {
    switch (card.id) {
      case 'status_report': return StatusReportWidget(key: ValueKey(card.id));
      case 'last_quake': return const LastQuakeWidget();
      case 'recent_chats': return const RecentChatsWidget();
      case 'daily_tip': return DailyTipWidget(key: ValueKey(card.id));
      case 'assembly_areas': return AssemblyAreaWidget(key: ValueKey(card.id));
      case 'weather': return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherScreen())),
          child: const WeatherWidget(key: ValueKey('weather_widget'))
        );
      default: return PlaceholderCard(key: ValueKey(card.id), title: card.title, icon: card.icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("QuakeSafe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.white38), onPressed: () => setState(() => _isEditMode = !_isEditMode)),
          IconButton(icon: const Icon(Icons.notifications_none_outlined, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()))),
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
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(card.icon, color: Colors.purple),
        title: Text(card.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.drag_handle, color: Colors.white12),
      ),
    );
  }
}
