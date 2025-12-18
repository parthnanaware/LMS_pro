// lib/pdf/pdfviwer.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    this.title = "PDF Viewer",
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? path;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    downloadPdf();
  }

  Future<void> downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode != 200) {
        throw "invalid response";
      }

      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf");

      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        path = file.path;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : path == null
          ? const Center(child: Text("Error loading PDF"))
          : PDFView(filePath: path!),
    );
  }
}
