import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static const String baseUrl =
      "https://18c60e28a489.ngrok-free.app";

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    return {
      "Accept": "application/json",
      if (token != null && token.isNotEmpty)
        "Authorization": "Bearer $token",
    };
  }

  Future<http.Response> httpGet(String path) async {
    return await http.get(
      Uri.parse(baseUrl + path),
      headers: await _headers(),
    );
  }

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

  Future<http.Response> httpDelete(String path) async {
    return await http.delete(
      Uri.parse(baseUrl + path),
      headers: await _headers(),
    );
  }

  Future<void> uploadFile({
    required String endpoint,
    required String filePath,
    required Map<String, String> fields,
  }) async {
    final uri = Uri.parse(baseUrl + endpoint);

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(await _headers());
    request.fields.addAll(fields);

    request.files.add(
      await http.MultipartFile.fromPath('file', filePath),
    );

    final response = await request.send();

    if (response.statusCode != 200) {
      final resp = await response.stream.bytesToString();
      throw Exception(
        'Upload failed (${response.statusCode}) → $resp',
      );
    }
  }

  // 🔑 ADD THIS
  Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id") ?? 0;
  }
}
