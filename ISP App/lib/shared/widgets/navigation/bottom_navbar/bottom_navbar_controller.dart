import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ispapp/features/payment/screens/payment_view.dart';
import 'package:ispapp/features/ping&speed/ping_screen.dart';
import 'package:ispapp/features/ping&speed/speed_screen.dart';
import '../../../../features/home/screens/home_view.dart';

class BottomNavBarController extends GetxController {
  var currentIndex = 0.obs;

  late final List<Widget> pages;

  @override
  void onInit() {
    super.onInit();
    // Initialize pages after all dependencies are loaded
    pages = [
      const HomeView(),
      PingScreen(),
      const SpeedTestScreen(),
      const PaymentView(),
    ];
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
