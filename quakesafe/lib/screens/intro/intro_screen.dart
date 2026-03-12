import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';
import '../auth/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool _permissionsRequested = false;

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.location,
      Permission.notification,
      Permission.storage,
      Permission.contacts,
    ].request();

    setState(() {
      _permissionsRequested = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 150)
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 200.ms),
                const SizedBox(height: 30),
                const Text(
                  "QuakeSafe",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().slideY(begin: 1, end: 0, duration: 600.ms),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    _permissionsRequested
                        ? "Hazırsınız! Giriş yaparak devam edebilirsiniz."
                        : "Güvenliğiniz için konum, kamera ve mikrofon izinlerini onaylamanız gerekmektedir.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_permissionsRequested) {
                      _requestPermissions();
                    } else {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    _permissionsRequested ? "Devam Et" : "İzinleri Onayla",
                    style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, delay: 1000.ms),
        ],
      ),
    );
  }
}
