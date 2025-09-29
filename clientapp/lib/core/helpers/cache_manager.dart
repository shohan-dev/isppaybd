// ignore_for_file: avoid_print

import 'package:get_storage/get_storage.dart';

class AppCacheManagerHelper {
  static final GetStorage _box = GetStorage();

  // Save single data under a specific key
  static Future<void> saveSingleData(String key, dynamic value) async {
    try {
      await _box.write(key, value);
      print("✅ Single data saved under key: $key");
    } catch (e) {
      print("❌ Error saving single data: $e");
    }
  }

  // Retrieve single data by key
  static Future<dynamic> getSingleData(String key) async {
    try {
      return _box.read(key);
    } catch (e) {
      print("❌ Error retrieving single data: $e");
      return null;
    }
  }

  // Save multiple data (e.g., Map or List) under a specific key
  static Future<void> saveMultipleData(String key, dynamic data) async {
    try {
      await _box.write(key, data);
      print("✅ Multiple data saved under key: $key");
    } catch (e) {
      print("❌ Error saving multiple data: $e");
    }
  }

  // Retrieve multiple data (Map or List) by key
  static Future<dynamic> getMultipleData(String key) async {
    try {
      return _box.read(key);
    } catch (e) {
      print("❌ Error retrieving multiple data: $e");
      return null;
    }
  }

  // Save a single data entry under a specific key in a map of multiple data
  static Future<void> saveDataUnderKey(
    String boxName,
    String key,
    dynamic value,
  ) async {
    try {
      // Retrieve existing data or create an empty map if not available
      Map<String, dynamic> existingData = await getMultipleData(boxName) ?? {};
      existingData[key] = value;
      await saveMultipleData(boxName, existingData);
      print("✅ Data saved under key $key in $boxName");
    } catch (e) {
      print("❌ Error saving data under key: $e");
    }
  }

  // Retrieve a specific entry by key from a map of multiple data
  static Future<dynamic> getDataByKey(String boxName, String key) async {
    try {
      Map<String, dynamic> data = await getMultipleData(boxName) ?? {};
      return data[key];
    } catch (e) {
      print("❌ Error retrieving data by key: $e");
      return null;
    }
  }

  // Remove a specific entry by key from a map of multiple data
  static Future<void> removeDataByKey(String boxName, String key) async {
    try {
      Map<String, dynamic> existingData = await getMultipleData(boxName) ?? {};
      existingData.remove(key);
      await saveMultipleData(boxName, existingData);
      print("✅ Data removed for key $key from $boxName");
    } catch (e) {
      print("❌ Error removing data by key: $e");
    }
  }

  // Clear all data under a specific box (key)
  static Future<void> clearData(String boxName) async {
    try {
      await _box.remove(boxName);
      print("✅ All data cleared for $boxName");
    } catch (e) {
      print("❌ Error clearing data for $boxName: $e");
    }
  }

  // Clear all data in the cache
  static Future<void> clearAllData() async {
    try {
      await _box.erase();
      print("✅ All data cleared");
    } catch (e) {
      print("❌ Error clearing all data: $e");
    }
  }

  // Check if a key exists in a specific box (key)
  static bool isKeyExist(String boxName, String key) {
    final data = _box.read(boxName);
    if (data is Map) {
      return data.containsKey(key);
    }
    return false;
  }

  // Get all keys from a specific box (key)
  static List getAllKeys(String boxName) {
    final data = _box.read(boxName);
    if (data is Map) {
      return data.keys.toList();
    }
    return [];
  }

  // Check if a specific key exists in the cache
  static bool hasData(String key) {
    return _box.hasData(key);
  }

  // Get all keys in the cache
  static List<String> getAllCacheKeys() {
    return _box.getKeys().toList();
  }
}
