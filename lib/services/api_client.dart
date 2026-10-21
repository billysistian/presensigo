import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

const String baseUrl = "https://payroll.gomega.co.id/api";
const String storageUrl = "https://payroll.gomega.co.id";

class ApiClient {
  // POST biasa (JSON)
  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> body) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      return {"success": false, "message": data["message"] ?? "Request failed"};
    }
  }

  // ✅ GET biasa dengan token opsional
  static Future<dynamic> get(String endpoint, {String? token}) async {
    token ??= await AuthService.getToken();
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      return {"success": false, "message": data["message"] ?? "Request failed"};
    }
  }

  // POST multipart (upload file)
  static Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    List<Map<String, dynamic>>? files,
  }) async {
    final token = await AuthService.getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl$endpoint"),
    );

    if (fields != null) request.fields.addAll(fields);

    if (files != null) {
      for (var f in files) {
        final fieldName = f['field'] ?? 'file';
        final file = f['file'] as File;
        request.files
            .add(await http.MultipartFile.fromPath(fieldName, file.path));
      }
    }

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    return await request.send();
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    final token = await AuthService.getToken();
    final url = Uri.parse("$baseUrl$endpoint");

    final response = await http.delete(
      url,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      return {"success": false, "message": data["message"] ?? "Request failed"};
    }
  }
}
