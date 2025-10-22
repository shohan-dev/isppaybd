import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ispapp/features/payment/screens/payment_view.dart';
import '../../../../features/home/screens/home_view.dart';

class BottomNavBarController extends GetxController {
  var currentIndex = 0.obs;

  late final List<Widget> pages;

  @override
  void onInit() {
    super.onInit();
    // Initialize pages after all dependencies are loaded
    pages = [const HomeView(), _buildPingPage(), PaymentView()];
  }

  Widget _buildPingPage() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.network_ping, size: 60, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Ping Test',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Test your network connectivity',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Ping Test Cards
              Expanded(
                child: Column(
                  children: [
                    _buildPingCard(
                      'Google DNS',
                      '8.8.8.8',
                      '15 ms',
                      Icons.dns,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildPingCard(
                      'Cloudflare DNS',
                      '1.1.1.1',
                      '12 ms',
                      Icons.cloud,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildPingCard(
                      'ISP Gateway',
                      '192.168.1.1',
                      '5 ms',
                      Icons.router,
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              // Ping Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Get.snackbar(
                      'Ping Test',
                      'Running network ping test...',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Run Ping Test',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPingCard(
    String title,
    String address,
    String latency,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF424242),
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          Text(
            latency,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
