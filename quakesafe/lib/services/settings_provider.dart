import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsProvider with ChangeNotifier {
  final Box _box = Hive.box('settings');

  bool get animationsEnabled => _box.get('animations', defaultValue: true);
  double get fontSizeFactor => _box.get('font_size', defaultValue: 1.0);
  String get language => _box.get('language', defaultValue: "Türkçe");

  void setAnimations(bool value) {
    _box.put('animations', value);
    notifyListeners();
  }

  void setFontSize(double value) {
    _box.put('font_size', value);
    notifyListeners();
  }

  void setLanguage(String value) {
    _box.put('language', value);
    notifyListeners();
  }

  bool get blockForeign => _box.get('block_foreign', defaultValue: false);
  bool get blockVpn => _box.get('block_vpn', defaultValue: false);

  void setBlockForeign(bool v) { _box.put('block_foreign', v); notifyListeners(); }
  void setBlockVpn(bool v) { _box.put('block_vpn', v); notifyListeners(); }
}
