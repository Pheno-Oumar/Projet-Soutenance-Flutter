class Failure {
  final String message;
  final int? statusCode;
  final dynamic error;

  const Failure({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}
