import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No Internet connection. Showing cached data.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Failed to load local cached data.'});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// Exceptions (Thrown by data sources, caught by repositories)
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  NetworkException({this.message = 'Network connection failed'});
}

class CacheException implements Exception {
  final String message;
  CacheException({this.message = 'Cache operation failed'});
}

class AuthException implements Exception {
  final String message;
  AuthException({required this.message});
}
