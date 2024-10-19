import 'package:flutter/material.dart';
import 'package:ilugan_passenger_mobile_app/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  PaymentScreen({super.key, required this.link});

  final String link; // Make it a final since it's passed as a required argument.

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController controller;
  String? paymentlink;

  @override
  void initState() {
    super.initState();

    // Initialize the payment link when the widget is created.
    paymentlink = widget.link;

    // Initialize the WebView controller when the payment link is available.
    if (paymentlink != null) {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(paymentlink!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextContent(
          name: 'Payment',
          fontsize: 20,
          fcolor: Colors.white,
          fontweight: FontWeight.w500,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: paymentlink != null
          ? WebViewWidget(controller: controller)
          : const Center(child: CircularProgressIndicator()), // Show loader if link isn't ready
    );
  }
}
