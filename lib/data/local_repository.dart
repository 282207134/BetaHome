import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One versioned local document. No passwords, PINs, or full card numbers.
class LocalRepository {
  LocalRepository(this.preferences);
  final SharedPreferences preferences;
  static const key = 'beta_home.v1';
  Map<String, dynamic> read() {
    try {
      return jsonDecode(preferences.getString(key) ?? '{}')
          as Map<String, dynamic>;
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> value) async {
    await preferences.setString(key, jsonEncode(value));
  }
}
