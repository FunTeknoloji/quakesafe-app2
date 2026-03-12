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
      final bool isSafe = type == 'safe';
      _reportStatusFromWidget(isSafe);
    } else if (uri.host == 'tool') {
      final type = uri.queryParameters['type'];
      if (type == 'torch') {
        try {
          await TorchLight.enableTorch();
        } catch (_) {
          await TorchLight.disableTorch();
        }
      } else if (type == 'sos') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("SOS Modu Etkinleştirildi")));
      } else if (type == 'whistle') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Düdük Sesi Çalınıyor")));
      }
    }
  }

  Future<void> _reportStatusFromWidget(bool isSafe) async {
    await StatusReportWidget.reportStatus(context, isSafe);
  }

  void _loadCards() async {
    final order = await _storageService.getCardOrder();
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
      _storageService.saveCardOrder(_cards.map((e) => e.id).toList());
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
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(AppTranslations.t('app_name', settings.language), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit, color: Colors.purple),
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.purple),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
        ],
      ),
      body: _isEditMode
          ? ReorderableListView(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              onReorder: _onReorder,
              children: _cards.map((card) => _buildEditCard(card)).toList(),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              children: _cards.map((card) => _buildCardWidget(card)).toList(),
            ),
    );
  }

  Widget _buildEditCard(HomeCard card) {
    return Card(
      key: ValueKey("edit_${card.id}"),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.white.withOpacity(0.1))),
      child: ListTile(
        leading: Icon(card.icon, color: Colors.purple),
        title: Text(card.title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.drag_handle, color: Colors.grey),
      ),
    );
  }
}
