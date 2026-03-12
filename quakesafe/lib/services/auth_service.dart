import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safe_device/safe_device.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

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
        if (await SafeDevice.isJailBroken || await SafeDevice.isRealDevice == false) {
           // SafeDevice doesn't have isProxyed in some versions, using jailbreak/realdevice as proxy
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

      await _storage.write(key: 'user_profile', value: json.encode(profile));
    } catch (e) {
      if (e is AuthException) {
        throw "Giriş başarısız: E-posta veya şifre hatalı.";
      }
      rethrow;
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

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final accessToken = googleAuth?.accessToken;
      final idToken = googleAuth?.idToken;

      if (idToken == null) {
        throw 'Google ile giriş başarısız: ID Token alınamadı.';
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw "Google ile giriş sırasında bir hata oluştu: ${e.toString()}";
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _storage.delete(key: 'user_profile');
  }

  Future<Map<String, dynamic>?> getLocalProfile() async {
    final data = await _storage.read(key: 'user_profile');
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }
}
