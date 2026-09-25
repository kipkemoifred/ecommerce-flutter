import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);
  static Future<bool> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  static bool? getBool(String key) => _prefs.getBool(key);
  static Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  static Future<bool> remove(String key) => _prefs.remove(key);
  static Future<bool> clear() => _prefs.clear();
}
