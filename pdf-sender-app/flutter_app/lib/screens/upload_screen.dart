import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/user_model.dart';
import '../services/pdf_service.dart';

class UploadScreen extends StatefulWidget {
  final UserModel user;
  const UploadScreen({super.key, required this.user});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  String? _fileName;
  int? _fileSize;
  bool _uploading = false;
  double _progress = 0.0;
  String? _message;
  bool _success = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        _fileSize = result.files.single.size;
        _message = null;
        _success = false;
        _progress = 0;
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF first')),
      );
      return;
    }

    setState(() {
      _uploading = true;
      _progress = 0;
      _message = null;
    });

    final result = await PdfService.uploadPdf(
      file: _selectedFile!,
      onProgress: (p) => setState(() => _progress = p),
    );

    setState(() {
      _uploading = false;
      _success = result['success'];
      _message = result['message'];
    });

    if (result['success']) {
      setState(() {
        _selectedFile = null;
        _fileName = null;
        _fileSize = null;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Upload PDF',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Pick area
                      GestureDetector(
                        onTap: _uploading ? null : _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedFile != null
                                  ? const Color(0xFFe94560)
                                  : Colors.white24,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFile != null
                                    ? Icons.picture_as_pdf
                                    : Icons.cloud_upload_outlined,
                                size: 64,
                                color: _selectedFile != null
                                    ? const Color(0xFFe94560)
                                    : Colors.white38,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedFile != null
                                    ? _fileName!
                                    : 'Tap to select a PDF',
                                style: TextStyle(
                                  color: _selectedFile != null
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 15,
                                  fontWeight: _selectedFile != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_selectedFile != null && _fileSize != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    _formatSize(_fileSize!),
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Progress
                      if (_uploading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFe94560)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading... ${(_progress * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Status message
                      if (_message != null)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (_success ? Colors.green : Colors.red)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _success ? Colors.green : Colors.red,
                                width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _success
                                    ? Icons.check_circle_outline
                                    : Icons.error_outline,
                                color:
                                    _success ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(_message!,
                                    style: TextStyle(
                                        color: _success
                                            ? Colors.green
                                            : Colors.red)),
                              )
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Upload button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: (_uploading || _selectedFile == null)
                              ? null
                              : _upload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFe94560),
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.upload_rounded,
                                  color: Colors.white),
                          label: Text(
                            _uploading ? 'Uploading...' : 'Upload PDF',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
