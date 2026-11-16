import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../error/failures.dart';

class ApiClient {
  final http.Client client;

  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await client
          .get(Uri.parse(url), headers: headers ?? {'Content-Type': 'application/json'})
          .timeout(ApiConstants.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException(message: 'No internet connection available.');
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out. Please try again.');
    } on FormatException {
      throw ServerException(message: 'Bad response format from server.');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> post(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await client
          .post(
            Uri.parse(url),
            headers: headers ?? {'Content-Type': 'application/json'},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);

      return _processResponse(response);
    } on SocketException {
      throw NetworkException(message: 'No internet connection.');
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out.');
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw ServerException(message: 'Request failed: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw ServerException(message: 'Unauthorized access.', statusCode: 401);
    } else if (response.statusCode == 404) {
      throw ServerException(message: 'Resource not found.', statusCode: 404);
    } else if (response.statusCode >= 500) {
      throw ServerException(
        message: 'Internal server error (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    } else {
      throw ServerException(
        message: 'Server error with code: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
