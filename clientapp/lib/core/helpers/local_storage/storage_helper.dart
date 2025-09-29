import 'package:hive_flutter/hive_flutter.dart';

class SStorageHelper {
  static bool initialized = false;
  static const String _defaultBox = "myapp";

  /// Initialize Hive and open default box
  static Future<void> init() async {
    if (!initialized) {
      await Hive.initFlutter();
      await Hive.openBox(_defaultBox);
      initialized = true;
    }
  }

  /// Open a box asynchronously (Must call before using sync methods)
  static Future<void> openBoxAsync(
    String boxName, {
    List<int>? encryptionKey,
  }) async {
    if (!Hive.isBoxOpen(boxName)) {
      if (encryptionKey != null) {
        await Hive.openBox(
          boxName,
          encryptionCipher: HiveAesCipher(encryptionKey),
        );
      } else {
        await Hive.openBox(boxName);
      }
    }
  }

  /// Save data synchronously (Ensure the box is opened first)
  static void put(
    String key,
    dynamic value, {
    String boxName = _defaultBox,
    Duration? ttl,
  }) {
    final box = _openBoxSync(boxName);

    if (ttl != null) {
      final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
      box.put(key, {"value": value, "expiry": expiry});
    } else {
      box.put(key, value);
    }
  }

  /// Get data synchronously (Default is now optional)
  static T? get<T>(
    String key, {
    String boxName = _defaultBox,
    T? defaultValue,
  }) {
    final box = _openBoxSync(boxName);
    final data = box.get(key);

    if (data is Map && data.containsKey("expiry")) {
      final expiry = data["expiry"] as int;
      if (expiry < DateTime.now().millisecondsSinceEpoch) {
        box.delete(key);
        return defaultValue;
      }
      return _cast<T>(data["value"]) ?? defaultValue;
    }

    return _cast<T>(data) ?? defaultValue;
  }

  /// Check if a key exists in the storage
  static bool exists(String key, {String boxName = _defaultBox}) {
    return _openBoxSync(boxName).containsKey(key);
  }

  /// Delete a specific key
  static void delete(String key, {String boxName = _defaultBox}) {
    _openBoxSync(boxName).delete(key);
  }

  /// Clear a specific box synchronously
  static void clearBoxSync({String boxName = _defaultBox}) {
    _openBoxSync(boxName).clear();
  }

  /// Delete all stored data asynchronously
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }

  // clear all data except the one values
  static void clearAllExcept(List<String> keys) {
    final box = _openBoxSync(_defaultBox);
    final allKeys = box.keys.cast<String>();
    for (var key in allKeys) {
      if (!keys.contains(key)) {
        box.delete(key);
      }
    }
  }

  // logout user only remove user data
  static void logout() {
    clearAllExcept([
      'themeMode',
      'appLanguage',
      "countryCode",
      "isNotFirst",
      "location",
    ]);
  }

  /// Internal method to get opened box (Throws error if not opened)
  static Box _openBoxSync(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box $boxName is not opened. Call openBoxAsync() first.');
    }
    return Hive.box(boxName);
  }

  /// Safe type casting to avoid runtime errors
  static T? _cast<T>(dynamic value) {
    try {
      if (value is T) return value;
      if (T == double && value is num) return value.toDouble() as T;
      if (T == int && value is num) return value.toInt() as T;
      if (T == String) return value.toString() as T;
      return null;
    } catch (e) {
      return null;
    }
  }
}
