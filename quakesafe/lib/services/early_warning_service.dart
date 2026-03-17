import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'notification_service.dart';

class EarlyWarningService {
  static final EarlyWarningService _instance = EarlyWarningService._internal();
  factory EarlyWarningService() => _instance;
  EarlyWarningService._internal();

  final _notificationService = NotificationService();
  final _battery = Battery();

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  double _threshold = 1.2;
  DateTime? _lastAlertTime;

  // To track if device is stationary
  List<double> _accHistory = [];

  void startDetection() {
    final supabase = Supabase.instance.client;

    _accelerometerSubscription = userAccelerometerEvents.listen((UserAccelerometerEvent event) async {
      double acceleration = (event.x.abs() + event.y.abs() + event.z.abs());

      // Update history for stationarity check
      _accHistory.add(acceleration);
      if (_accHistory.length > 50) _accHistory.removeAt(0);

      // Condition: Charging AND Stationary (low variance in history)
      bool isCharging = await _battery.batteryState == BatteryState.charging;
      bool isStationary = _checkStationarity();

      if (isCharging && isStationary && acceleration > _threshold) {
        _handleTremorDetected(acceleration);
      }
    });

    supabase.from('notifications_quakesafe')
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

  bool _checkStationarity() {
    if (_accHistory.length < 10) return false;
    double avg = _accHistory.reduce((a, b) => a + b) / _accHistory.length;
    // If average acceleration is very low, it's likely stationary on a surface
    return avg < 0.2;
  }

  void _handleTremorDetected(double strength) async {
    final now = DateTime.now();
    if (_lastAlertTime == null || now.difference(_lastAlertTime!).inSeconds > 15) {
      _lastAlertTime = now;

      try {
        final supabase = Supabase.instance.client;
        final userId = supabase.auth.currentUser?.id;
        Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

        if (userId != null) {
          // Send to aggregation table
          await supabase.from('tremor_reports').insert({
            'user_id': userId,
            'strength': strength,
            'lat': pos.latitude,
            'lng': pos.longitude,
          });
        }
      } catch (_) {}
    }
  }

  void _triggerAlert(String title, String message) {
    _notificationService.showNotification(title: title, body: message);
    // Real direct pop-up would happen via a Platform Channel or a specific package for overlays
    // Handled in next step.
  }

  void stopDetection() {
    _accelerometerSubscription?.cancel();
  }
}
