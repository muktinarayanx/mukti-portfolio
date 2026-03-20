import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../models/pdf_model.dart';
import '../services/pdf_service.dart';
import 'package:intl/intl.dart';

class DownloadScreen extends StatefulWidget {
  final PdfModel pdf;
  const DownloadScreen({super.key, required this.pdf});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _downloading = false;
  double _progress = 0;
  String? _savedPath;
  String? _errorMsg;

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _savedPath = null;
      _errorMsg = null;
    });

    final result = await PdfService.downloadPdf(
      fileId: widget.pdf.id,
      fileName: widget.pdf.originalName,
      onProgress: (p) => setState(() => _progress = p),
    );

    setState(() => _downloading = false);

    if (result['success']) {
      setState(() => _savedPath = result['path']);
    } else {
      setState(() => _errorMsg = result['message']);
    }
  }

  Future<void> _openFile() async {
    if (_savedPath != null) {
      await OpenFilex.open(_savedPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdf = widget.pdf;
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(pdf.uploadDate.toLocal());

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
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Download PDF',
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
                      // File info card
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFe94560).withOpacity(0.1),
                              ),
                              child: const Icon(Icons.picture_as_pdf,
                                  color: Color(0xFFe94560), size: 52),
                            ),
                            const SizedBox(height: 16),
                            Text(pdf.originalName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            _infoRow(Icons.storage, 'Size', pdf.fileSizeFormatted),
                            _infoRow(Icons.person_outline, 'Uploaded by',
                                pdf.uploaderName),
                            _infoRow(Icons.calendar_today, 'Date', dateStr),
                            _infoRow(Icons.download_outlined, 'Downloads',
                                '${pdf.downloads}'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Progress
                      if (_downloading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _progress,
                            minHeight: 10,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFe94560)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Downloading... ${(_progress * 100).toInt()}%',
                            style: const TextStyle(color: Colors.white54)),
                        const SizedBox(height: 20),
                      ],

                      // Success message
                      if (_savedPath != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 0.8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Download complete!',
                                        style:
                                            TextStyle(color: Colors.green)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(_savedPath!,
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 11),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openFile,
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.green),
                                  ),
                                  icon: const Icon(Icons.open_in_new,
                                      color: Colors.green, size: 18),
                                  label: const Text('Open File',
                                      style: TextStyle(color: Colors.green)),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Error
                      if (_errorMsg != null) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red, width: 0.8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(_errorMsg!,
                                      style:
                                          const TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Download button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _downloading ? null : _download,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4a90e2),
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: _downloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.download_rounded,
                                  color: Colors.white),
                          label: Text(
                            _downloading ? 'Downloading...' : 'Download PDF',
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 15),
          const SizedBox(width: 8),
          Text('$label: ',
              style:
                  const TextStyle(color: Colors.white38, fontSize: 12)),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis),
          )
        ],
      ),
    );
  }
}
