// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_cookie_manager/webview_cookie_manager.dart';
// import 'dart:convert';

// class OtherScreen extends StatefulWidget {
//   const OtherScreen({super.key});

//   @override
//   State<OtherScreen> createState() => _OtherScreenState();
// }

// class _OtherScreenState extends State<OtherScreen> {
//   late final WebViewController _controller;
//   final cookieManager = WebviewCookieManager();

//   @override
//   void initState() {
//     super.initState();
//     _initWebView();
//   }

//   void _initWebView() {
//     _controller =
//         WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..setNavigationDelegate(
//             NavigationDelegate(
//               onPageFinished: (String url) async {
//                 debugPrint("========================");
//                 debugPrint("✅ Page Loaded: $url");

//                 try {
//                   // 🍪 1. Get cookies
//                   final cookies = await cookieManager.getCookies(url);
//                   for (var c in cookies) {
//                     debugPrint('🍪 Cookie: ${c.name} = ${c.value}');
//                   }

//                   // 🗃️ 2. Get Local Storage
//                   final localStorage = await _controller
//                       .runJavaScriptReturningResult(
//                         "JSON.stringify(window.localStorage)",
//                       );
//                   debugPrint('📦 Local Storage: $localStorage');

//                   // 💾 3. Get Session Storage
//                   final sessionStorage = await _controller
//                       .runJavaScriptReturningResult(
//                         "JSON.stringify(window.sessionStorage)",
//                       );
//                   debugPrint('🧠 Session Storage: $sessionStorage');

//                   // 🧩 4. Extract HTML content to search manually
//                   final html = await _controller.runJavaScriptReturningResult(
//                     "document.documentElement.outerHTML",
//                   );

//                   // Clean output (it returns a JS string with quotes)
//                   String htmlString = html.toString();
//                   if (htmlString.startsWith('"') && htmlString.endsWith('"')) {
//                     htmlString = htmlString.substring(1, htmlString.length - 1);
//                   }
//                   htmlString = htmlString
//                       .replaceAll(r'\n', '\n')
//                       .replaceAll(r'\"', '"');
//                   debugPrint(
//                     '🌐 HTML content (partial): ${htmlString.substring(0, htmlString.length > 400 ? 400 : htmlString.length)}...',
//                   );

//                   // 🔍 5. Try to detect user_id or role from HTML
//                   if (htmlString.contains('user_id')) {
//                     debugPrint('✅ Found user_id in HTML');
//                   } else {
//                     debugPrint('⚠️ No user_id visible in HTML');
//                   }
//                 } catch (e) {
//                   debugPrint('⚠️ Error while fetching data: $e');
//                 }
//               },
//             ),
//           )
//           ..loadRequest(Uri.parse('https://isppaybd.com'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Web Session Viewer')),
//       body: WebViewWidget(controller: _controller),
//     );
//   }
// }
