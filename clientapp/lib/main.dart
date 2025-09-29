import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clientapp/core/config/theme/app_theme.dart';
import 'package:clientapp/core/routes/app_pages.dart';
import 'package:clientapp/core/routes/app_routes.dart';
import 'package:clientapp/core/bindings/initial_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'IsppayBD User Portal',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
