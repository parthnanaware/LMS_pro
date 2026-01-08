import 'package:flutter/material.dart';
import 'package:lms_pro/pdf/pdfviwer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title = "Resource",
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(widget.url);

    if (uri == null || (!uri.hasScheme)) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
            child: Text("Invalid URL", style: TextStyle(color: Colors.red))),
      );
    }

    if (widget.url.toLowerCase().endsWith(".pdf")) {
      return PdfViewerPage(
        pdfUrl: widget.url,
        title: widget.title,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(const Color(0x00000000))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageFinished: (_) => setState(() => _isLoading = false),
                ),
              )
              ..loadRequest(uri),
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
