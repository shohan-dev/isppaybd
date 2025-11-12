import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ispapp/core/config/constants/color.dart';
import 'package:ispapp/features/payment/screens/payment_view.dart';
import 'package:ispapp/features/ping/ping_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
      const SpeedTestView(),
      const PaymentView(),
    ];
  }



  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class SpeedTestView extends StatefulWidget {
  const SpeedTestView({super.key});

  @override
  State<SpeedTestView> createState() => _SpeedTestViewState();
}

class _SpeedTestViewState extends State<SpeedTestView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => _isLoading = true),
              onPageFinished: (_) => setState(() => _isLoading = false),
              onWebResourceError: (error) {
                debugPrint('Speed Test WebView Error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse('https://fast.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
