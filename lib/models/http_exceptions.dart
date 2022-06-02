class HttpExceptions implements Exception {
  final String message;
  HttpExceptions({required this.message});

  @override
  String toString() {
    return message;
  }
}
