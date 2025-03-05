import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  // Helper method to handle common response logic
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic) fromJson) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success: Parse the response body
      final data = jsonDecode(response.body);
      return ApiResponse.completed(fromJson(data));
    } else {
      // Error: Return an error response
      return ApiResponse.error('Request failed with status: ${response.statusCode}');
    }
  }

  // GET request
Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic) fromJson) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    
    if (response.statusCode == 404) { // Handle not found
      return ApiResponse.error('Resource not found');
    }
    
    if (response.body.isEmpty) { // Handle empty response
      return ApiResponse.error('Empty response from server');
    }
    
    return _handleResponse(response, fromJson);
  } catch (e) {
    print('GET Error: $e');
    return ApiResponse.error('Error during GET request: $e');
  }
}

  // POST request
  Future<ApiResponse<T>> post<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error during POST request: $e');
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error during PUT request: $e');
    }
  }


Future<ApiResponse<T>> postMultipart<T>({
    required String endpoint,
    required Map<String, String> fields,
    required Map<String, File> files,
    required T Function(dynamic) parser,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      var request = http.MultipartRequest('POST', url);

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      files.forEach((key, value) async {
        request.files.add(await http.MultipartFile.fromPath(key, value.path));
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.completed(parser(json.decode(responseBody)));
      } else {
        return ApiResponse.error('Failed to upload: ${response.reasonPhrase}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  // DELETE request
  Future<ApiResponse<void>> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return ApiResponse.completed(null);
      } else {
        return ApiResponse.error('Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Error during DELETE request: $e');
    }
  }

  // PATCH request
  Future<ApiResponse<T>> patch<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Error during PATCH request: $e');
    }
  }
Future<ApiResponse<T>> putMultipart<T>({
  required String endpoint,
  required Map<String, String> fields,
  required Map<String, File> files,
  required T Function(dynamic) parser,
}) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      var request = http.MultipartRequest('PUT', url);

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      files.forEach((key, value) async {
        request.files.add(await http.MultipartFile.fromPath(key, value.path));
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.completed(parser(json.decode(responseBody)));
      } else {
        return ApiResponse.error('Failed to upload: ${response.reasonPhrase}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: ${e.toString()}');
    }
}
  Future<ApiResponse<dynamic>> sendMultipart(http.MultipartRequest request) async {
  try {
    final response = await request.send();
    final body = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return ApiResponse.completed(json.decode(body));
    }
    return ApiResponse.error('Failed: ${response.statusCode}');
  } catch (e) {
    return ApiResponse.error('Exception: $e');
  }
}
}

class ApiResponse<T> {
  Status status;
  T? data;
  String? message;

  ApiResponse.initial(this.message) : status = Status.INITIAL;

  ApiResponse.loading(this.message) : status = Status.LOADING;

  ApiResponse.completed(this.data) : status = Status.COMPLETED;

  ApiResponse.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { INITIAL, LOADING, COMPLETED, ERROR }