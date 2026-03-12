import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';

class StorageService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadFile(File file, {String folder = 'messages'}) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final storagePath = '$folder/$fileName';

      await _supabase.storage.from('family-uploads').upload(storagePath, file);

      final publicUrl = _supabase.storage.from('family-uploads').getPublicUrl(storagePath);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage(File file) => uploadFile(file, folder: 'images');
  Future<String?> uploadAudio(File file) => uploadFile(file, folder: 'audio');

  Future<List<String>?> getCardOrder() async {
    final box = Hive.box('settings');
    return box.get('card_order')?.cast<String>();
  }

  Future<void> saveCardOrder(List<String> order) async {
    final box = Hive.box('settings');
    await box.put('card_order', order);
  }
}
