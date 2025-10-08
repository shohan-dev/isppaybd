import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/local_storage/storage_helper.dart';

class StorageService {
  static StorageService? _instance;
  late FlutterSecureStorage _secureStorage;

  StorageService._internal() {
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
  }

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  // Initialize storage
  static Future<void> init() async {
    await AppStorageHelper.init();
  }

  // Authentication related storage
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserToken = 'user_token';
  static const String _keyUserData = 'user_data';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLoginEmail = 'last_login_email';

  // Check if user is logged in
  bool isLoggedIn() {
    return AppStorageHelper.get<bool>(_keyIsLoggedIn, defaultValue: false)!;
  }

  // Set login status
  Future<void> setLoginStatus(bool isLoggedIn) async {
    AppStorageHelper.put(_keyIsLoggedIn, isLoggedIn);
  }

  // Save user token securely
  Future<void> saveUserToken(String token) async {
    await _secureStorage.write(key: _keyUserToken, value: token);
  }

  // Get user token
  Future<String?> getUserToken() async {
    return await _secureStorage.read(key: _keyUserToken);
  }

  // Save user data
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    AppStorageHelper.put(_keyUserData, userData);
  }

  // Get user data
  Map<String, dynamic>? getUserData() {
    return AppStorageHelper.get<Map<String, dynamic>>(_keyUserData);
  }

  // Save remember me preference
  Future<void> setRememberMe(bool remember) async {
    AppStorageHelper.put(_keyRememberMe, remember);
  }

  // Get remember me preference
  bool getRememberMe() {
    return AppStorageHelper.get<bool>(_keyRememberMe, defaultValue: false)!;
  }

  // Save last login email
  Future<void> saveLastLoginEmail(String email) async {
    AppStorageHelper.put(_keyLastLoginEmail, email);
  }

  // Get last login email
  String? getLastLoginEmail() {
    return AppStorageHelper.get<String>(_keyLastLoginEmail);
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    AppStorageHelper.delete(_keyIsLoggedIn);
    AppStorageHelper.delete(_keyUserData);
    AppStorageHelper.delete(_keyLastLoginEmail);
    await _secureStorage.delete(key: _keyUserToken);
  }

  // Clear all data
  Future<void> clearAll() async {
    await AppStorageHelper.clearAll();
    await _secureStorage.deleteAll();
  }

  // Save any key-value pair
  Future<void> save(String key, dynamic value) async {
    AppStorageHelper.put(key, value);
  }

  // Read any key
  T? read<T>(String key) {
    return AppStorageHelper.get<T>(key);
  }

  // Remove any key
  Future<void> remove(String key) async {
    AppStorageHelper.delete(key);
  }

  // Save secure data
  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  // Read secure data
  Future<String?> readSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Delete secure data
  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  // Check if a key exists
  bool exists(String key) {
    return AppStorageHelper.exists(key);
  }

  // Check if secure key exists
  Future<bool> existsSecure(String key) async {
    final value = await _secureStorage.read(key: key);
    return value != null;
  }

  // Save data with TTL (Time To Live)
  Future<void> saveWithTTL(String key, dynamic value, Duration ttl) async {
    AppStorageHelper.put(key, value, ttl: ttl);
  }

  // Logout user - keep essential app data
  void logout() {
    AppStorageHelper.logout();
  }

  // Get all keys
  Iterable<String> getAllKeys() {
    return AppStorageHelper.get('hive_keys') ?? [];
  }

  // Batch operations
  Future<void> saveBatch(Map<String, dynamic> data) async {
    data.forEach((key, value) {
      AppStorageHelper.put(key, value);
    });
  }

  // Clear all except specified keys
  void clearAllExcept(List<String> keysToKeep) {
    AppStorageHelper.clearAllExcept(keysToKeep);
  }

  // App settings storage helpers
  Future<void> saveAppSetting(String key, dynamic value) async {
    AppStorageHelper.put('app_settings_$key', value);
  }

  T? getAppSetting<T>(String key, {T? defaultValue}) {
    return AppStorageHelper.get<T>(
      'app_settings_$key',
      defaultValue: defaultValue,
    );
  }

  // Theme storage
  Future<void> saveThemeMode(String themeMode) async {
    AppStorageHelper.put('themeMode', themeMode);
  }

  String getThemeMode() {
    return AppStorageHelper.get<String>('themeMode', defaultValue: 'light')!;
  }

  // Language storage
  Future<void> saveLanguage(String languageCode) async {
    AppStorageHelper.put('appLanguage', languageCode);
  }

  String getLanguage() {
    return AppStorageHelper.get<String>('appLanguage', defaultValue: 'en')!;
  }

  // First time app launch
  bool isFirstTime() {
    return !AppStorageHelper.get<bool>('isNotFirst', defaultValue: false)!;
  }

  void setFirstTimeComplete() {
    AppStorageHelper.put('isNotFirst', true);
  }

  // Device/Location storage
  Future<void> saveCountryCode(String countryCode) async {
    AppStorageHelper.put('countryCode', countryCode);
  }

  String? getCountryCode() {
    return AppStorageHelper.get<String>('countryCode');
  }

  Future<void> saveLocation(Map<String, dynamic> location) async {
    AppStorageHelper.put('location', location);
  }

  Map<String, dynamic>? getLocation() {
    return AppStorageHelper.get<Map<String, dynamic>>('location');
  }
}
