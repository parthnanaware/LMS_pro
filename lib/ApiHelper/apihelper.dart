import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  // CHANGE ONLY THIS WHEN NGROK CHANGES
  static const String baseUrl = "https://0fef2e6c7c31.ngrok-free.app/api/";

  // ---------------------- COMMON HEADERS ----------------------
  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
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
      headers: await _headers(),
      body: json.encode(data),
    );
  }

  // ---------------------- PUT ----------------------
  Future<http.Response> httpPut(String path, Map data) async {
    return await http.put(
      Uri.parse(baseUrl + path),
      headers: await _headers(),
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
}
