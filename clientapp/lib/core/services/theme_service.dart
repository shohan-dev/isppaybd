import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService extends GetxService {
  final _storage = GetStorage();
  final _storageKey = 'isDarkMode';

  bool get isDarkMode => _storage.read(_storageKey) ?? false;

  ThemeMode get themeMode => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    Get.changeThemeMode(themeMode);
  }

  void switchTheme() {
    final newTheme = !isDarkMode;
    _storage.write(_storageKey, newTheme);
    Get.changeThemeMode(newTheme ? ThemeMode.dark : ThemeMode.light);
  }

  void setDarkMode(bool value) {
    _storage.write(_storageKey, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
