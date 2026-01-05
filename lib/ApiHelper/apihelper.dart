import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static const String baseUrl =
      "https://c1e2ed272a7c.ngrok-free.app/api/";

  // ---------------------- COMMON HEADERS ----------------------
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    return {
      "Accept": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  // ---------------------- GET ----------------------
  Future<http.Response> httpGet(String path) async {
    return await http.get(
      Uri.parse(baseUrl + path),
      headers: await _headers(),
    );
  }

  // ---------------------- POST ----------------------
  Future<http.Response> httpPost(String path, Map data) async {
    return await http.post(
      Uri.parse(baseUrl + path),
      headers: {
        ...await _headers(),
        "Content-Type": "application/json",
      },
      body: json.encode(data),
    );
  }

  // ---------------------- PUT ----------------------
  Future<http.Response> httpPut(String path, Map data) async {
    return await http.put(
      Uri.parse(baseUrl + path),
      headers: {
        ...await _headers(),
        "Content-Type": "application/json",
      },
      body: json.encode(data),
    );
  }

  // ---------------------- DELETE ----------------------
  Future<http.Response> httpDelete(String path) async {
    return await http.delete(
      Uri.parse(baseUrl + path),
      headers: await _headers(),
    );
  }

  // =====================================================
  // 🔥 FILE UPLOAD (PDF) — FINAL & WORKING
  // =====================================================
  Future<void> uploadFile({
    required String endpoint,
    required String filePath,
    required Map<String, String> fields,
  }) async {
    final uri = Uri.parse(baseUrl + endpoint);

    final request = http.MultipartRequest('POST', uri);

    // 🔑 Auth headers (DO NOT set Content-Type here)
    request.headers.addAll(await _headers());

    // Add text fields
    request.fields.addAll(fields);

    // Add file (Laravel expects "file")
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        filePath,
      ),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      final resp = await response.stream.bytesToString();
      throw Exception(
        'Upload failed (${response.statusCode}) → $resp',
      );
    }
  }
}
