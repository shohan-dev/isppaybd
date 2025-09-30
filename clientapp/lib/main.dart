import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:clientapp/core/config/theme/app_theme.dart';
import 'package:clientapp/core/routes/app_pages.dart';
import 'package:clientapp/core/routes/app_routes.dart';
import 'package:clientapp/core/bindings/initial_binding.dart';
import 'package:clientapp/core/services/theme_service.dart';
import 'package:clientapp/core/services/local_storage_service.dart';

Future<void> initServices() async {
  // Initialize GetStorage
  await GetStorage.init();

  // Initialize core services
  Get.put<LocalStorageService>(LocalStorageService(), permanent: true);
  Get.put<ThemeService>(ThemeService(), permanent: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return GetMaterialApp(
      title: 'IsppayBD User Portal',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeService.themeMode,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
