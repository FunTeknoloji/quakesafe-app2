import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:home_widget/home_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/earthquakes/earthquakes_screen.dart';
import 'screens/family/family_screen.dart';
import 'screens/other_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/intro/intro_screen.dart';
import 'services/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/early_warning_service.dart';
import 'constants.dart';
import 'translations.dart';

@pragma('vm:entry-point')
Future<void> _backgroundCallback(Uri? uri) async {
  if (uri?.host == 'status') {
    // Background action handling
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();

  final earlyWarningService = EarlyWarningService();
  earlyWarningService.startDetection();

  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');

  HomeWidget.registerInteractivityCallback(_backgroundCallback);

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const QuakeSafeApp(),
    ),
  );
}

class QuakeSafeApp extends StatelessWidget {
  const QuakeSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'QuakeSafe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme.copyWith(
        textTheme: AppTheme.darkTheme.textTheme.apply(
          fontSizeFactor: settings.fontSizeFactor,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const MainNavigationScreen();
    } else {
      return const IntroScreen();
    }
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const HomeScreen(),
      const EarthquakesScreen(),
      const FamilyScreen(),
      const OtherScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppTranslations.t('home', settings.language)),
          BottomNavigationBarItem(icon: const Icon(Icons.waves), label: AppTranslations.t('quakes', settings.language)),
          BottomNavigationBarItem(icon: const Icon(Icons.group), label: AppTranslations.t('family', settings.language)),
          BottomNavigationBarItem(icon: const Icon(Icons.more_horiz), label: AppTranslations.t('other', settings.language)),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppTranslations.t('profile', settings.language)),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
