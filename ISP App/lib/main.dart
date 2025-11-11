import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/config/theme/app_theme.dart';
import 'core/helpers/local_storage/storage_helper.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_pages.dart';
import 'core/bindings/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await AppStorageHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ISP Broadband',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      initialBinding: AppBinding(),
      getPages: AppPages.pages,
    );
  }
}
