import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../models/pdf_model.dart';
import '../models/download_log_model.dart';
import 'auth_service.dart';

class PdfService {
  // ── Shared auth header ─────────────────────────────────────────────────────
  static Future<Map<String, String>> _authHeader() async {
    final token = await AuthService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ── Upload PDF ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> uploadPdf({
    required File file,
    required Function(double) onProgress,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.uploadEndpoint}');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        await http.MultipartFile.fromPath(
          'pdf',
          file.path,
          contentType: MediaType('application', 'pdf'),
        ),
      );

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
        onTimeout: () {
          throw Exception('Upload timed out. Please check your connection and try again.');
        },
      );
      onProgress(1.0); // mark complete

      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'File uploaded successfully'};
      }
      return {'success': false, 'message': body['message'] ?? 'Upload failed'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ── List PDFs ──────────────────────────────────────────────────────────────
  static Future<List<PdfModel>> fetchPdfList() async {
    final headers = await _authHeader();
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.listEndpoint}');

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => PdfModel.fromJson(e)).toList();
      }
      if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception('Failed to load PDFs (${response.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Could not connect to server');
    }
  }

  // ── Fetch Download Logs (Uploader Only) ────────────────────────────────────
  static Future<List<DownloadLogModel>> fetchDownloadLogs() async {
    final headers = await _authHeader();
    final url = Uri.parse('${AppConstants.baseUrl}${AppConstants.downloadLogsEndpoint}');

    try {
      final response = await http.get(url, headers: headers).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => DownloadLogModel.fromJson(e)).toList();
      }
      if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception('Failed to load logs (${response.statusCode})');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Could not connect to server');
    }
  }

  // ── Download PDF ───────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> downloadPdf({
    required String fileId,
    required String fileName,
    required Function(double) onProgress,
  }) async {
    try {
      final token = await AuthService.getToken();
      final url = Uri.parse(
          '${AppConstants.baseUrl}${AppConstants.downloadEndpoint(fileId)}');

      final request = http.Request('GET', url);
      request.headers['Authorization'] = 'Bearer $token';

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode != 200) {
        return {'success': false, 'message': 'Download failed'};
      }

      final total = streamedResponse.contentLength ?? 0;
      int received = 0;
      final List<int> bytes = [];

      await for (final chunk in streamedResponse.stream) {
        bytes.addAll(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }

      // Save file
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$fileName';
      final savedFile = File(savePath);
      await savedFile.writeAsBytes(bytes);

      return {'success': true, 'path': savePath};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ── Delete PDF ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> deletePdf(String fileId) async {
    final headers = await _authHeader();
    final url =
        Uri.parse('${AppConstants.baseUrl}${AppConstants.deleteEndpoint(fileId)}');

    final response = await http.delete(url, headers: headers);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true};
    }
    return {'success': false, 'message': body['message'] ?? 'Delete failed'};
  }
}
