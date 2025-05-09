// model/services/api_client.dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  final String baseUrl;
  String? _authToken;

  ApiClient({required this.baseUrl});

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Improved response handler that properly handles different status codes
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(dynamic) fromJson) {
    try {
      final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        return ApiResponse.completed(fromJson(responseBody));
      } else {
        // Handle specific error status codes
        switch (response.statusCode) {
          case 400:
            return ApiResponse.error(
              responseBody?['message'] ?? 'Bad request', 
              statusCode: 400
            );
          case 401:
            return ApiResponse.error(
              responseBody?['message'] ?? 'Unauthorized', 
              statusCode: 401
            );
          case 403:
            return ApiResponse.error(
              responseBody?['message'] ?? 'Forbidden', 
              statusCode: 403
            );
          case 404:
            return ApiResponse.error(
              responseBody?['message'] ?? 'Resource not found', 
              statusCode: 404
            );
          case 500:
            return ApiResponse.error(
              responseBody?['message'] ?? 'Internal server error', 
              statusCode: 500
            );
          default:
            return ApiResponse.error(
              responseBody?['message'] ?? 'Request failed with status: ${response.statusCode}',
              statusCode: response.statusCode
            );
        }
      }
    } catch (e) {
      // Handle JSON parsing errors
      return ApiResponse.error('Error processing response: $e');
    }
  }

  // GET request
  Future<ApiResponse<T>> get<T>(String endpoint, T Function(dynamic) fromJson) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('Making GET request to: $url'); // Debug log
      print('Headers: $_headers'); // Debug log

      final response = await http.get(
        url,
        headers: _headers,
      );
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      if (response.body.isEmpty && response.statusCode != 204) {
        return ApiResponse.error('Empty response from server', statusCode: response.statusCode);
      }
      
      return _handleResponse(response, fromJson);
    } catch (e) {
      print('GET Error: $e'); // Debug log
      return ApiResponse.error('Error during GET request: $e');
    }
  }

  // POST request
  Future<ApiResponse<T>> post<T>(String endpoint, dynamic data, T Function(dynamic) fromJson) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('Making POST request to: $url'); // Debug log
      print('Headers: $_headers'); // Debug log
      print('Body: ${json.encode(data)}'); // Debug log
      
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(data),
      );
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      return _handleResponse(response, fromJson);
    } catch (e) {
      print('POST Error: $e'); // Debug log
      return ApiResponse.error('Error during POST request: $e');
    }
  }

  // PUT request
  Future<ApiResponse<T>> put<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('Making PUT request to: $url'); // Debug log
      
      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      return _handleResponse(response, fromJson);
    } catch (e) {
      print('PUT Error: $e'); // Debug log
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

      // Add authorization header if available
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      return _handleResponse(response, parser);
    } catch (e) {
      print('POST Multipart Error: $e'); // Debug log
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  Future<ApiResponse<void>> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('Making DELETE request to: $url'); // Debug log
      
      final response = await http.delete(
        url,
        headers: _headers,
      );
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.completed(null);
      } else {
        final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        return ApiResponse.error(
          responseBody?['message'] ?? 'Failed to delete: ${response.statusCode}',
          statusCode: response.statusCode
        );
      }
    } catch (e) {
      print('DELETE Error: $e'); // Debug log
      return ApiResponse.error('Error during DELETE request: $e');
    }
  }

  // PATCH request
  Future<ApiResponse<T>> patch<T>(String endpoint, dynamic body, T Function(dynamic) fromJson) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      print('Making PATCH request to: $url'); // Debug log
      
      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      return _handleResponse(response, fromJson);
    } catch (e) {
      print('PATCH Error: $e'); // Debug log
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

      // Add authorization header if available
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files correctly
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      return _handleResponse(response, parser);
    } catch (e) {
      print('PUT Multipart Error: $e'); // Debug log
      return ApiResponse.error('Network error: ${e.toString()}');
    }
  }
  
  Future<ApiResponse<dynamic>> sendMultipart(http.MultipartRequest request) async {
    try {
      // Add authorization header if available
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('Response Status Code: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.isNotEmpty ? json.decode(response.body) : null;
        return ApiResponse.completed(body);
      }
      
      final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return ApiResponse.error(
        responseBody?['message'] ?? 'Failed: ${response.statusCode}',
        statusCode: response.statusCode
      );
    } catch (e) {
      print('Multipart Error: $e'); // Debug log
      return ApiResponse.error('Exception: $e');
    }
  }
}

class ApiResponse<T> {
  Status status;
  T? data;
  String? message;
  int? statusCode;

  ApiResponse.initial(this.message) : status = Status.INITIAL, statusCode = null;

  ApiResponse.loading(this.message) : status = Status.LOADING, statusCode = null;

  ApiResponse.completed(this.data) : status = Status.COMPLETED, message = null, statusCode = 200;

  ApiResponse.error(this.message, {this.statusCode}) : status = Status.ERROR, data = null;

  bool get isSuccess => status == Status.COMPLETED;
  
  bool get isError => status == Status.ERROR;
  
  bool get isLoading => status == Status.LOADING;

  @override
  String toString() {
    return "Status: $status | StatusCode: $statusCode | Message: $message | Data: $data";
  }
}

enum Status { INITIAL, LOADING, COMPLETED, ERROR }