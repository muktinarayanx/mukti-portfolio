import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pdf_model.dart';
import '../models/user_model.dart';
import '../services/pdf_service.dart';
import 'download_screen.dart';

class PdfListScreen extends StatefulWidget {
  final UserModel user;
  const PdfListScreen({super.key, required this.user});

  @override
  State<PdfListScreen> createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  List<PdfModel> _pdfs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPdfs();
  }

  Future<void> _fetchPdfs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await PdfService.fetchPdfList();
      setState(() {
        _pdfs = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteFile(PdfModel pdf) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213e),
        title: const Text('Delete File', style: TextStyle(color: Colors.white)),
        content: Text('Delete "${pdf.originalName}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final result = await PdfService.deletePdf(pdf.id);
      if (!mounted) return;
      if (result['success']) {
        _fetchPdfs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('File deleted'),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Delete failed'),
              backgroundColor: Colors.red),
        );
      }
    }
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
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text('Available PDFs',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white70),
                      onPressed: _fetchPdfs,
                      tooltip: 'Refresh',
                    )
                  ],
                ),
              ),

              // Body
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFe94560)))
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi_off,
                                    color: Colors.white38, size: 60),
                                const SizedBox(height: 12),
                                Text(_error!,
                                    style: const TextStyle(color: Colors.white54),
                                    textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchPdfs,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFe94560)),
                                  child: const Text('Retry',
                                      style: TextStyle(color: Colors.white)),
                                )
                              ],
                            ),
                          )
                        : _pdfs.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.folder_open,
                                        color: Colors.white24, size: 72),
                                    SizedBox(height: 12),
                                    Text('No PDFs uploaded yet',
                                        style: TextStyle(color: Colors.white38)),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchPdfs,
                                color: const Color(0xFFe94560),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  itemCount: _pdfs.length,
                                  itemBuilder: (_, i) =>
                                      _buildPdfCard(_pdfs[i]),
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPdfCard(PdfModel pdf) {
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(pdf.uploadDate.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFe94560).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.picture_as_pdf,
                      color: Color(0xFFe94560), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pdf.originalName,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(pdf.fileSizeFormatted,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text(pdf.uploaderName,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_outlined,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(dateStr,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.download_outlined,
                    color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Text('${pdf.downloads} downloads',
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DownloadScreen(pdf: pdf),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4a90e2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white, size: 18),
                    label: const Text('Download',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ),
                ),
                if (widget.user.isUploader) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _deleteFile(pdf),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 22),
                    tooltip: 'Delete',
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}
