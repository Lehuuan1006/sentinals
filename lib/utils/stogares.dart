import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  late SharedPreferences _prefs;
  StorageUtils._();

  static final StorageUtils instance = StorageUtils._();

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future setString({required String key, required String val}) async {
    return _prefs.setString(key, val);
  }

  Future setDouble({required String key, required double val}) async {
    return _prefs.setDouble(key, val);
  }

  Future setBool({required String key, required bool val}) async {
    return _prefs.setBool(key, val);
  }

  Future setInt({required String key, required int val}) async {
    return _prefs.setInt(key, val);
  }

  Future setStringList({required String key, required List<String> val}) async {
    return _prefs.setStringList(key, val);
  }

  String? getString({required String key}) {
    return _prefs.getString(key);
  }

  double? getDouble({required String key}) {
    return _prefs.getDouble(key);
  }

  bool? getBool({required String key}) {
    return _prefs.getBool(key);
  }

  int? getInt({required String key}) {
    return _prefs.getInt(key);
  }

  Object? getObj({required String key}) {
    return _prefs.get(key);
  }

  List<String>? getStringList({required String key}) {
    return _prefs.getStringList(key);
  }

  Set<String> getListKeys() {
    return _prefs.getKeys();
  }

  Future<bool> removeKey({required String key}) {
    return _prefs.remove(key);
  }

  Future<bool> clearAllKeys() {
    return _prefs.clear();
  }

  bool containsKey({required String key}) {
    return _prefs.containsKey(key);
  }

  Future reloadAll() {
    return _prefs.reload();
  }
}
