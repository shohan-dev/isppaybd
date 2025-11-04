import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    this.title = 'Payment',
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use platform-aware creation params per platform to avoid channel errors
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

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (err) {
            // ignore: avoid_print
            print('WebView error: $err');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    // Android specific tweaks
    final platformController = controller.platform;
    if (platformController is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      platformController.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
