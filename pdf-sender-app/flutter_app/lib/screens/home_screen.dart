import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/download_log_model.dart';
import '../services/auth_service.dart';
import '../services/pdf_service.dart';
import 'login_screen.dart';
import 'pdf_list_screen.dart';
import 'upload_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DownloadLogModel> _logs = [];
  bool _isLoadingLogs = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.user.isUploader) {
      _fetchLogs();
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchLogs());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLogs() async {
    if (_isLoadingLogs && _logs.isEmpty) return;
    setState(() => _isLoadingLogs = true);
    try {
      final logs = await PdfService.fetchDownloadLogs();
      if (mounted) {
        setState(() {
          _logs = logs;
          _isLoadingLogs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLogs = false);
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return '${difference.inSeconds} sec ago';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return DateFormat('dd MMM, hh:mm a').format(dateTime);
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
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf,
                        color: Color(0xFFe94560), size: 30),
                    const SizedBox(width: 10),
                    const Text('PDF Share',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      onPressed: () => _logout(context),
                      tooltip: 'Logout',
                    )
                  ],
                ),
              ),

              // Welcome card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFe94560),
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, ${widget.user.name}!',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: widget.user.isUploader
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: widget.user.isUploader
                                      ? Colors.green
                                      : Colors.blue,
                                  width: 0.8),
                            ),
                            child: Text(
                              widget.user.role.toUpperCase(),
                              style: TextStyle(
                                color: widget.user.isUploader
                                    ? Colors.green
                                    : Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action tiles
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 140,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTile(
                          context,
                          icon: Icons.list_alt_rounded,
                          label: 'PDF List',
                          subtitle: 'Browse all files',
                          color: const Color(0xFF4a90e2),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    PdfListScreen(user: widget.user)),
                          ),
                        ),
                      ),
                      if (widget.user.isUploader) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTile(
                            context,
                            icon: Icons.upload_file_rounded,
                            label: 'Upload PDF',
                            subtitle: 'Share a document',
                            color: const Color(0xFFe94560),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      UploadScreen(user: widget.user)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Important Messages Section (Uploaders Only)
              if (widget.user.isUploader)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      border: const Border(
                        top: BorderSide(color: Colors.white12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active_outlined,
                                  color: Colors.amber, size: 22),
                              const SizedBox(width: 8),
                              const Text(
                                'Important Messages',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_isLoadingLogs)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      color: Colors.white54, strokeWidth: 2),
                                )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: _logs.isEmpty
                              ? Center(
                                  child: Text(
                                    _isLoadingLogs
                                        ? 'Loading messages...'
                                        : 'No recent downloads.',
                                    style: const TextStyle(
                                        color: Colors.white54),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  itemCount: _logs.length,
                                  itemBuilder: (context, index) {
                                    final log = _logs[index];
                                    return _buildMessageCard(log);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(DownloadLogModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.download_done_rounded,
                color: Colors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    children: [
                      TextSpan(
                        text: log.downloaderName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' downloaded '),
                      TextSpan(
                        text: log.fileName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatRelativeTime(log.downloadedAt),
                  style: const TextStyle(color: Colors.amber, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
