import 'package:hive_flutter/hive_flutter.dart';

class AppStorageHelper {
  static bool initialized = false;
  static const String _defaultBox = "myapp";

  /// Initialize Hive and open default box
  static Future<void> init() async {
    try {
      if (!initialized) {
        print('🚀 Initializing AppStorageHelper...');
        await Hive.initFlutter();
        await Hive.openBox(_defaultBox);
        initialized = true;
        print('✅ AppStorageHelper initialized successfully');
      } else {
        print('📋 AppStorageHelper already initialized');
        // Double-check box is still open
        if (!Hive.isBoxOpen(_defaultBox)) {
          print('⚠️ Box was unexpectedly closed, reopening...');
          await Hive.openBox(_defaultBox);
          print('✅ Box reopened successfully');
        }
      }
    } catch (e) {
      print('❌ CRITICAL: Failed to initialize AppStorageHelper: $e');
      initialized = false;
      rethrow;
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
    try {
      final box = _openBoxSync(boxName);

      if (ttl != null) {
        final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
        box.put(key, {"value": value, "expiry": expiry});
      } else {
        box.put(key, value);
      }
      print('✅ Storage PUT success: $key = $value');
    } catch (e) {
      print('❌ Storage PUT failed: $key = $value, Error: $e');
      print('🔄 Attempting to reinitialize storage...');

      // Emergency fix: Try to reinitialize storage
      try {
        if (!Hive.isBoxOpen(boxName)) {
          print('📦 Box $boxName was not open, this should not happen');
        }
        // Force get the box reference and try again
        final box = Hive.box(boxName);

        if (ttl != null) {
          final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
          box.put(key, {"value": value, "expiry": expiry});
        } else {
          box.put(key, value);
        }
        print('✅ Storage PUT retry success: $key = $value');
      } catch (retryError) {
        print('❌ Storage PUT retry failed: $retryError');
        print('⚠️ CRITICAL: Storage is completely broken!');
      }
    }
  }

  /// Get data synchronously (Default is now optional)
  static T? get<T>(
    String key, {
    String boxName = _defaultBox,
    T? defaultValue,
  }) {
    try {
      final box = _openBoxSync(boxName);
      final data = box.get(key);

      if (data is Map && data.containsKey("expiry")) {
        final expiry = data["expiry"] as int;
        if (expiry < DateTime.now().millisecondsSinceEpoch) {
          box.delete(key);
          print('⏰ Expired data removed for key: $key');
          return defaultValue;
        }
        final result = _cast<T>(data["value"]) ?? defaultValue;
        print('✅ Storage GET success (TTL): $key = $result');
        return result;
      }

      final result = _cast<T>(data) ?? defaultValue;
      print('✅ Storage GET success: $key = $result');
      return result;
    } catch (e) {
      print('❌ Storage GET failed: $key, Error: $e');
      print('🔄 Returning default value: $defaultValue');
      return defaultValue;
    }
  }

  /// Check if a key exists in the storage
  static bool exists(String key, {String boxName = _defaultBox}) {
    return _openBoxSync(boxName).containsKey(key);
  }

  /// Delete a specific key
  static void delete(String key, {String boxName = _defaultBox}) {
    try {
      _openBoxSync(boxName).delete(key);
      print('✅ Storage DELETE success: $key');
    } catch (e) {
      print('❌ Storage DELETE failed: $key, Error: $e');
    }
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
