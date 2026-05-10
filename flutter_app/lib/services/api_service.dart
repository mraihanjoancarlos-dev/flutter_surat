// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // URL XAMPP lokal
  // - Emulator Android  → gunakan 10.0.2.2
  // - Device fisik      → gunakan IP komputer kamu (cek dengan ipconfig)
  // Contoh device fisik: 'http://192.168.1.5/surat/api'
  static const String baseUrl = 'http://192.168.1.14/surat/api';
  

  // ── Token Management ─────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> saveAdmin(Map<String, dynamic> admin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin', jsonEncode(admin));
  }

  static Future<Map<String, dynamic>?> getAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('admin');
    if (s == null) return null;
    return jsonDecode(s);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('admin');
  }

  // ── Headers ──────────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _authHeader() async {
    final token = await getToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Login ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // ── Dashboard ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/dashboard.php'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Surat Masuk ──────────────────────────────────────────
  static Future<Map<String, dynamic>> getSuratMasuk({
    int page = 1, int limit = 10, String search = ''
  }) async {
    final uri = Uri.parse(
      '$baseUrl/surat_masuk.php?page=$page&limit=$limit&search=${Uri.encodeComponent(search)}'
    );
    final res = await http.get(uri, headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addSuratMasuk(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/surat_masuk.php'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateSuratMasuk(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/surat_masuk.php'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteSuratMasuk(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/surat_masuk.php?id=$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Surat Masuk + File Upload ─────────────────────────────
  static Future<Map<String, dynamic>> addSuratMasukWithFile(
    Map<String, dynamic> data, File file) async {
    final token = await getToken();
    final req = http.MultipartRequest(
      'POST', Uri.parse('$baseUrl/surat_masuk.php'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    // Tambahkan semua field data
    data.forEach((k, v) => req.fields[k] = v.toString());

    // Tambahkan file PDF
    req.files.add(await http.MultipartFile.fromPath(
      'file_surat', file.path,
      filename: file.path.split('/').last,
    ));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateSuratMasukWithFile(
    Map<String, dynamic> data, File file) async {
    final token = await getToken();
    // PHP tidak support multipart PUT, gunakan POST dengan _method override
    final req = http.MultipartRequest(
      'POST', Uri.parse('$baseUrl/surat_masuk.php'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    req.fields['_method'] = 'PUT';
    data.forEach((k, v) => req.fields[k] = v.toString());

    req.files.add(await http.MultipartFile.fromPath(
      'file_surat', file.path,
      filename: file.path.split('/').last,
    ));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  // ── Surat Keluar ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getSuratKeluar({
    int page = 1, int limit = 10, String search = ''
  }) async {
    final uri = Uri.parse(
      '$baseUrl/surat_keluar.php?page=$page&limit=$limit&search=${Uri.encodeComponent(search)}'
    );
    final res = await http.get(uri, headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> addSuratKeluar(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/surat_keluar.php'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateSuratKeluar(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/surat_keluar.php'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteSuratKeluar(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/surat_keluar.php?id=$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ── Surat Keluar + File Upload ────────────────────────────
  static Future<Map<String, dynamic>> addSuratKeluarWithFile(
    Map<String, dynamic> data, File file) async {
    final token = await getToken();
    final req = http.MultipartRequest(
      'POST', Uri.parse('$baseUrl/surat_keluar.php'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    data.forEach((k, v) => req.fields[k] = v.toString());

    req.files.add(await http.MultipartFile.fromPath(
      'file_surat', file.path,
      filename: file.path.split('/').last,
    ));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateSuratKeluarWithFile(
    Map<String, dynamic> data, File file) async {
    final token = await getToken();
    final req = http.MultipartRequest(
      'POST', Uri.parse('$baseUrl/surat_keluar.php'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    req.fields['_method'] = 'PUT';
    data.forEach((k, v) => req.fields[k] = v.toString());

    req.files.add(await http.MultipartFile.fromPath(
      'file_surat', file.path,
      filename: file.path.split('/').last,
    ));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    return jsonDecode(res.body);
  }
}