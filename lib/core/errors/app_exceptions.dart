class AppException implements Exception {
  final String message;
  final int? statusCode;
  AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message';
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class ApiException extends AppException {
  ApiException(super.message, {super.statusCode});
}

class RateLimitException extends ApiException {
  RateLimitException()
    : super('API rate limit exceeded. Please try again later.');
}
