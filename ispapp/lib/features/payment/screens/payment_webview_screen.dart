// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  final String token;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Payment',
    this.token = '',
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String get token => widget.token;
  final listofwebsite = [
    "https://isppaybd.com/payment",
    "https://isppaybd.com/dashboard",
    "https://isppaybd.com/auth/login",
    "https://isppaybd.com",
  ];

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    // 1️⃣ Setup controller (Platform aware)
    late final WebViewController controller;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      final params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
      controller = WebViewController.fromPlatformCreationParams(params);
    } else {
      const params = PlatformWebViewControllerCreationParams();
      controller = WebViewController.fromPlatformCreationParams(params);
    }

    // 2️⃣ Setup cookies BEFORE loading
    final cookieManager = WebViewCookieManager();
    await cookieManager
        .clearCookies(); // optional but recommended for fresh session

    await cookieManager.setCookie(
      WebViewCookie(
        name: 'ci_session',
        value: token,
        domain: '.isppaybd.com',
        path: '/',
      ),
    );

    // print("token is: $token");

    debugPrint("✅ Cookie successfully set before loading page");

    // 3️⃣ Setup webview behavior
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrlAndClose(url);
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            _checkUrlAndClose(url);
            try {
              final cookies = await controller.runJavaScriptReturningResult(
                'document.cookie',
              );
              debugPrint('🍪 Current cookies for $url -> $cookies');
            } catch (e) {
              debugPrint('⚠️ Failed to get cookies: $e');
            }
          },
          onWebResourceError: (err) => debugPrint('🚨 WebView Error: $err'),
        ),
      );

    // 4️⃣ Load after cookie setup
    await controller.loadRequest(Uri.parse(widget.url));

    // 5️⃣ Android-specific optimization
    final platformController = controller.platform;
    if (platformController is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      platformController.setMediaPlaybackRequiresUserGesture(false);
    }

    setState(() => _controller = controller);
  }

  void _checkUrlAndClose(String url) {
    debugPrint('🔍 Checking URL: $url');

    // Check if the current URL EXACTLY matches any URL in the list
    for (final targetUrl in listofwebsite) {
      // Exact match check (with or without trailing slash)
      final urlWithoutSlash =
          url.endsWith('/') ? url.substring(0, url.length - 1) : url;
      final targetWithoutSlash =
          targetUrl.endsWith('/')
              ? targetUrl.substring(0, targetUrl.length - 1)
              : targetUrl;

      if (urlWithoutSlash == targetWithoutSlash) {
        debugPrint('✅ EXACT URL match found: $url == $targetUrl');
        debugPrint('🔙 Auto-closing webview and navigating back...');

        // Close the webview and go back
        Future.delayed(const Duration(milliseconds: 0), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
        return;
      }
    }

    debugPrint('✔️ URL is different, continuing: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _controllerWidget(),
    );
  }

  Widget _controllerWidget() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: Colors.blue)),
      ],
    );
  }
}
