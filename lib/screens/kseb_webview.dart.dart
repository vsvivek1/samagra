import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KsebWebView extends StatefulWidget {
  const KsebWebView({super.key});

  @override
  State<KsebWebView> createState() => _KsebWebViewState();
}

class _KsebWebViewState extends State<KsebWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('httppp')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.kseb.in'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 237, 233, 233),
              borderRadius: BorderRadiusDirectional.circular(5),
            ),
            child: const Text('KSEB Website')),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
