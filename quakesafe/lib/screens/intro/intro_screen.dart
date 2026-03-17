import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../services/settings_provider.dart';
import '../../translations.dart';
import '../auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Permission> _permissions = [
    Permission.location,
    Permission.camera,
    Permission.microphone,
    Permission.contacts,
    Permission.notification,
  ];

  Future<void> _requestAllPermissions() async {
    await _permissions.request();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final lang = settings.language;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildPage(
                context,
                AppTranslations.t('onboarding_1_title', lang),
                AppTranslations.t('onboarding_1_desc', lang),
                'assets/images/logo.png',
                isLogo: true,
              ),
              _buildPage(
                context,
                AppTranslations.t('onboarding_2_title', lang),
                AppTranslations.t('onboarding_2_desc', lang),
                Icons.radar,
                isIcon: true,
              ),
              _buildPage(
                context,
                AppTranslations.t('onboarding_3_title', lang),
                AppTranslations.t('onboarding_3_desc', lang),
                Icons.groups_3,
                isIcon: true,
              ),
              _buildPermissionsPage(context, lang),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => _buildDot(index)),
                ),
                const SizedBox(height: 30),
                if (_currentPage < 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.purple : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage(BuildContext context, String title, String desc, dynamic asset, {bool isLogo = false, bool isIcon = false}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLogo)
            Image.asset(asset, width: 180).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms)
          else if (isIcon)
            Icon(asset as IconData, size: 120, color: Colors.purple).animate().fadeIn().scale(),
          const SizedBox(height: 60),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ).animate().slideY(begin: 0.3, end: 0),
          const SizedBox(height: 20),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.white54, height: 1.5),
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildPermissionsPage(BuildContext context, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppTranslations.t('onboarding_4_title', lang),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          Text(
            AppTranslations.t('onboarding_4_desc', lang),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 40),
          _permissionTile(Icons.location_on, AppTranslations.t('permission_location', lang)),
          _permissionTile(Icons.camera_alt, AppTranslations.t('permission_camera', lang)),
          _permissionTile(Icons.mic, AppTranslations.t('permission_mic', lang)),
          _permissionTile(Icons.contacts, AppTranslations.t('permission_contacts', lang)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _requestAllPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: Colors.purple.withValues(alpha: 0.5),
              ),
              child: Text(
                AppTranslations.t('get_started', lang).toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
