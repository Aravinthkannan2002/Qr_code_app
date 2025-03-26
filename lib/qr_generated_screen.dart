import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QrGeneratedScreen extends StatefulWidget {
  const QrGeneratedScreen({super.key});

  @override
  State<QrGeneratedScreen> createState() => _QrGeneratedScreenState();
}

class _QrGeneratedScreenState extends State<QrGeneratedScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScreenshotController _screenController = ScreenshotController();
  String qrData = "";
  String selectedType = "text";
  final Map<String, TextEditingController> _controller = {
    'name': TextEditingController(),
    'phone': TextEditingController(),
    'email': TextEditingController(),
    'url': TextEditingController(),
  };

  String _generateQRData() {
    switch (selectedType) {
      case 'contact':
        return '''BEGIN:VCARD\nVERSION:3.0\nFN:${_controller['name']?.text}\nTEL:${_controller['phone']?.text}\nEMAIL:${_controller['email']?.text}\nEND:VCARD''';
      case 'url':
        String url = _controller['url']?.text ?? '';
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'http://$url';
        }
        return url;
      default:
        return _textController.text;
    }
  }

  Future<void> _shareQRCode() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/qr_code.png';
    final capture = await _screenController.capture();
    if (capture == null) return;
    File imageFile = File(imagePath);
    await imageFile.writeAsBytes(capture);
    await Share.shareXFiles([XFile(imagePath)], text: 'Share QR Code');
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.black),
          border: OutlineInputBorder(
            
            borderSide: BorderSide(
               color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (_) {
          setState(() {
            qrData = _generateQRData();
          });
        },
      ),
    );
  }

  Widget _buildInputFields() {
    switch (selectedType) {
      case "contact":
        return Column(
          children: [
            _buildTextField(_controller['name']!, "Name"),
            _buildTextField(_controller['phone']!, "Phone"),
            _buildTextField(_controller['email']!, "Email"),
          ],
        );
      case 'url':
        return _buildTextField(_controller['url']!, "URL");
      default:
        return _buildTextField(_textController, "Enter text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "Generated QR Code",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SegmentedButton<String>(
                        selected: {selectedType},
                        onSelectionChanged: (Set<String> selection) {
                          setState(() {
                            selectedType = selection.first;
                            qrData = '';
                          });
                        },
                        segments: const [
                          ButtonSegment(
                            value: "text",
                            label: Text("Text",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                            icon: Icon(Icons.text_fields),
                          ),
                          ButtonSegment(
                            value: "url",
                            label: Text("URL",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.black),),
                            icon: Icon(Icons.link),
                          ),
                          ButtonSegment(
                            value: "contact",
                            label: Text("Contact",style: TextStyle(
                                   fontSize: 12,fontWeight: FontWeight.bold,
                                   color: Colors.black,
                            ),
                            ),
                            icon: Icon(Icons.person),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInputFields(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (qrData.isNotEmpty)
                Column(
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Screenshot(
                          controller: _screenController,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 200,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _shareQRCode,
                      icon: const Icon(Icons.share, color: Colors.indigo),
                      label: Text(
                        "Share QR Code",
                        style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
