import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class EarlyWarningService {
  static final EarlyWarningService _instance = EarlyWarningService._internal();
  factory EarlyWarningService() => _instance;
  EarlyWarningService._internal();

  final _supabase = Supabase.instance.client;
  final _notificationService = NotificationService();

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  double _threshold = 1.5; // G-force threshold for earthquake detection
  DateTime? _lastAlertTime;

  void startDetection() {
    _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      double acceleration = (event.x.abs() + event.y.abs() + event.z.abs());
      if (acceleration > _threshold) {
        _handleTremorDetected(acceleration);
      }
    });

    // Listen for global alerts from Supabase
    _supabase.from('notifications_quakesafe')
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> data) {
        if (data.isNotEmpty) {
           final lastNotif = data.first;
           if (lastNotif['title'].toString().contains("ERKEN UYARI") || lastNotif['title'].toString().contains("EARLY WARNING")) {
              _triggerAlert(lastNotif['title'], lastNotif['message']);
           }
        }
      });
  }

  void _handleTremorDetected(double strength) async {
    final now = DateTime.now();
    if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds > 30) {
      _lastAlertTime = now;

      // Report tremor to Supabase for aggregation
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId != null) {
          await _supabase.from('notifications_quakesafe').insert({
            'user_id': userId,
            'title': '⚠️ SARSINTI ALGILANDI',
            'message': 'Cihazınızda yüksek şiddetli bir sarsıntı algılandı ($strength). Lütfen güvenli bir yere geçin.',
            'is_read': false,
          });
        }
      } catch (_) {}
    }
  }

  void _triggerAlert(String title, String message) {
    _notificationService.showNotification(title: title, body: message);
  }

  void stopDetection() {
    _accelerometerSubscription?.cancel();
  }
}
