import '../utils/app_logger.dart';

/// Key-Value Local Storage Wrapper Interface
class LocalStorage {
  LocalStorage._();

  static final Map<String, dynamic> _memoryCache = {};

  static Future<void> setString(String key, String value) async {
    _memoryCache[key] = value;
    AppLogger.debug('Saved String [$key]', tag: 'STORAGE');
  }

  static String? getString(String key) {
    return _memoryCache[key] as String?;
  }

  static Future<void> setBool(String key, bool value) async {
    _memoryCache[key] = value;
    AppLogger.debug('Saved Bool [$key]: $value', tag: 'STORAGE');
  }

  static bool? getBool(String key) {
    return _memoryCache[key] as bool?;
  }

  static Future<void> remove(String key) async {
    _memoryCache.remove(key);
    AppLogger.debug('Removed Key [$key]', tag: 'STORAGE');
  }

  static Future<void> clear() async {
    _memoryCache.clear();
    AppLogger.debug('Cleared All Local Storage', tag: 'STORAGE');
  }
}
