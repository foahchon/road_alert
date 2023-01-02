import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiBaseService {
  final String baseUrl;

  ApiBaseService({required this.baseUrl});

  Future<dynamic> get(String url) async {
    dynamic responseJson;

    try {
      var uri = Uri.parse('$baseUrl$url');
      final response = await http.get(uri);

      responseJson = _getJsonResponse(response);
    } on SocketException {
      throw FetchDataException('No internet connection');
    }

    return responseJson;
  }

  dynamic _getJsonResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;

      case 400:
        throw BadRequestException(response.body.toString());

      case 401:
      case 403:
        throw UnauthorizedException(response.body.toString());

      case 500:
      default:
        throw FetchDataException(
          'Error occured during communication with server. Status code: ${response.statusCode}',
        );
    }
  }
}

class AppException implements Exception {
  final String message;
  final String prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() {
    return '$prefix: $message';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message)
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException(message) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException(message) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, "Invalid Input: ");
}
