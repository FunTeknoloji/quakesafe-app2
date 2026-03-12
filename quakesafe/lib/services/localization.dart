class AppLocalization {
  static Map<String, Map<String, String>> _values = {
    'Türkçe': {
      'app_title': 'QuakeSafe',
      'home': 'Ana Sayfa',
      'quakes': 'Depremler',
      'family': 'Ailem',
      'other': 'Diğer',
      'profile': 'Profil',
      'settings': 'Ayarlar',
      'edit': 'Düzenle',
      'save': 'Kaydet',
      'delete': 'Sil',
      'cancel': 'İptal',
      'logout': 'Çıkış Yap',
      'delete_account': 'Hesabı Sil',
      'offline_mode': 'Çevrimdışı Mod',
      'send': 'Gönder',
      'type_message': 'Mesaj yazın...',
    },
    'English': {
      'app_title': 'QuakeSafe',
      'home': 'Home',
      'quakes': 'Earthquakes',
      'family': 'Family',
      'other': 'Other',
      'profile': 'Profile',
      'settings': 'Settings',
      'edit': 'Edit',
      'save': 'Save',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'logout': 'Logout',
      'delete_account': 'Delete Account',
      'offline_mode': 'Offline Mode',
      'send': 'Send',
      'type_message': 'Type a message...',
    },
  };

  static String get(String key, String lang) {
    return _values[lang]?[key] ?? key;
  }
}
