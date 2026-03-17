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
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // 1. Core Supabase initialization first
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );

    // 2. Local persistence
    await Hive.initFlutter();
    await Hive.openBox('settings');
    await Hive.openBox('cache');

    // 3. System services
    final notificationService = NotificationService();
    await notificationService.init();

    final earlyWarningService = EarlyWarningService();
    earlyWarningService.startDetection();

    HomeWidget.registerInteractivityCallback(_backgroundCallback);

    runApp(
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(),
        child: const QuakeSafeApp(),
      ),
    );
  } catch (e) {
    debugPrint("Startup Error: $e");
    // Fallback app to show error if initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Hata: $e", style: const TextStyle(color: Colors.white)),
        ),
      ),
    ));
  }
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _checkStatus() async {
    // Artificial delay to ensure all services are fully bonded and active
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 80),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.purple, strokeWidth: 2),
            ],
          ),
        ),
      );
    }

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
