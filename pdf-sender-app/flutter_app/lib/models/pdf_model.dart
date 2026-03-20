class PdfModel {
  final String id;
  final String originalName;
  final int fileSize;
  final DateTime uploadDate;
  final int downloads;
  final String downloadUrl;
  final String uploaderName;
  final String uploaderEmail;

  PdfModel({
    required this.id,
    required this.originalName,
    required this.fileSize,
    required this.uploadDate,
    required this.downloads,
    required this.downloadUrl,
    required this.uploaderName,
    required this.uploaderEmail,
  });

  factory PdfModel.fromJson(Map<String, dynamic> json) {
    final uploader = json['uploader'] as Map<String, dynamic>? ?? {};
    return PdfModel(
      id: json['_id'] ?? '',
      originalName: json['originalName'] ?? 'Unknown',
      fileSize: json['fileSize'] ?? 0,
      uploadDate: json['uploadDate'] != null
          ? DateTime.parse(json['uploadDate'])
          : DateTime.now(),
      downloads: json['downloads'] ?? 0,
      downloadUrl: json['downloadUrl'] ?? '',
      uploaderName: uploader['name'] ?? 'Unknown',
      uploaderEmail: uploader['email'] ?? '',
    );
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
