import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_card.dart';

class StorageService {
  static const String _keyCardOrder = 'card_order';

  static Future<void> saveCardOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyCardOrder, order);
  }

  static Future<List<String>?> getCardOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCardOrder);
  }
}
