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
        domain: 'https://isppaybd.com',
        path: '/',
      ),
    );

    debugPrint("✅ Cookie successfully set before loading page");

    // 3️⃣ Setup webview behavior
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
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
