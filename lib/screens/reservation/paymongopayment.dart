// import 'package:flutter/material.dart';
// // Import for Android features.
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class WebViewScreen extends StatefulWidget {
//   @override
//   _WebViewScreenState createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   late WebViewController _controller;

//   @override
//   void initState() {
//     super.initState();
//     // Enable hybrid composition on Android for better performance.
//     WebViewPlatform.instance = SurfaceAndroidWebView();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Facebook WebView'),
//       ),
//       body: WebView(
//         initialUrl: 'https://www.facebook.com',
//         javascriptMode: JavascriptMode.unrestricted,
//         onWebViewCreated: (WebViewController webViewController) {
//           _controller = webViewController;
//         },
//       ),
//     );
//   }
// }
