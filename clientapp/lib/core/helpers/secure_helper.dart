import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSecureHelper {
  final _storage = FlutterSecureStorage();

  Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }
}
