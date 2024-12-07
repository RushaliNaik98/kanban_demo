import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String testToken;

  ApiService({
    required this.baseUrl,
    required this.testToken,
  });

  Future<dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $testToken',
        'Content-Type': 'application/json',
      },
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $testToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $testToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<void> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $testToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete data: ${response.statusCode}');
    }
  }
}
