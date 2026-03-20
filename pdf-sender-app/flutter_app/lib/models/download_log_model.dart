class DownloadLogModel {
  final String id;
  final String fileName;
  final String downloaderName;
  final DateTime downloadedAt;

  DownloadLogModel({
    required this.id,
    required this.fileName,
    required this.downloaderName,
    required this.downloadedAt,
  });

  factory DownloadLogModel.fromJson(Map<String, dynamic> json) {
    return DownloadLogModel(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? 'Unknown File',
      downloaderName: json['downloaderName'] ?? 'Unknown User',
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.parse(json['downloadedAt'])
          : DateTime.now(),
    );
  }
}
