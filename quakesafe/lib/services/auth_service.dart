import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safe_device/safe_device.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _cache = Hive.box('cache');

  Future<void> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final userId = response.user!.id;

      final profile = await _supabase.from('profiles_quakesafe').select().eq('id', userId).single();

      if (profile['is_platform_banned'] == true) {
        final expiresAt = profile['platform_ban_expires_at'] != null
            ? DateTime.parse(profile['platform_ban_expires_at'])
            : null;

        if (expiresAt == null || expiresAt.isAfter(DateTime.now())) {
          await _supabase.auth.signOut();
          String reason = profile['platform_ban_reason'] ?? "Neden belirtilmedi.";
          String expiry = expiresAt != null ? "Bitiş: ${expiresAt.toLocal()}" : "Süresiz";
          throw "Erişiminiz engellendi. \nSebep: $reason \n$expiry";
        }
      }

      if (profile['block_vpn'] == true) {
        // isProxyEnabled is not available in safe_device 1.3.8, using available checks
        bool isSuspicious = await SafeDevice.isJailBroken || await SafeDevice.isRealDevice == false;
        if (isSuspicious) {
          await _supabase.auth.signOut();
          throw "Güvensiz cihaz veya VPN algılandı.";
        }
      }

      if (profile['block_foreign_access'] == true) {
        final ipResponse = await http.get(Uri.parse('https://ipapi.co/json/'));
        if (ipResponse.statusCode == 200) {
          final data = json.decode(ipResponse.body);
          if (data['country_code'] != 'TR') {
            await _supabase.auth.signOut();
            throw "Yurt dışından erişim engellenmiştir.";
          }
        }
      }

      await _cache.put('user_profile', profile);
    } catch (e) {
      if (e is AuthException) {
        throw "Giriş başarısız: E-posta veya şifre hatalı.";
      }
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('profiles_quakesafe').delete().eq('id', user.id);
        await _supabase.auth.signOut();
        await _cache.clear();
        await Hive.box('settings').clear();
      }
    } catch (e) {
      throw "Hesap silinemedi: $e";
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (response.user != null) {
        throw "Kayıt başarılı! Lütfen e-posta adresinizi onaylayın.";
      }
    } catch (e) {
      if (e is AuthException) {
        throw "Kayıt hatası: ${e.message}";
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw "Sıfırlama e-postası gönderilemedi: ${e.toString()}";
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _cache.delete('user_profile');
  }

  Map<String, dynamic>? getLocalProfile() {
    final data = _cache.get('user_profile');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
