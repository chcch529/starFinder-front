import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PDFViewerPage extends StatefulWidget {

  final String assetPath;

  PDFViewerPage({required this.assetPath});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    final ByteData data = await rootBundle.load(widget.assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/sample.pdf');

    await tempFile.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );

    setState(() {
      pdfPath = tempFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: pdfPath != null
          ? PDFView(
        filePath: pdfPath!,
        enableSwipe: true,
        swipeHorizontal: true,
        autoSpacing: false,
        pageFling: false,
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
