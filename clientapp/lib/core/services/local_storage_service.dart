import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageService extends GetxService {
  final GetStorage _storage = GetStorage();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
  }

  // Regular storage methods
  void write(String key, dynamic value) {
    _storage.write(key, value);
  }

  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  void remove(String key) {
    _storage.remove(key);
  }

  void clearAll() {
    _storage.erase();
  }

  // Secure storage methods
  Future<void> writeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAllSecure() async {
    await _secureStorage.deleteAll();
  }

  // User session methods
  void saveUserSession(Map<String, dynamic> userData) {
    write('user_data', userData);
    write('is_logged_in', true);
  }

  Map<String, dynamic>? getUserData() {
    return read<Map<String, dynamic>>('user_data');
  }

  bool isLoggedIn() {
    return read<bool>('is_logged_in') ?? false;
  }

  void clearUserSession() {
    remove('user_data');
    remove('is_logged_in');
  }
}
