/// Opakowanie Proxy z backendu (status, message, source itp.)
class ProxyResponseDto<T> {
  final T? data;
  final int? status; // 0 = OK
  final String? message;
  final String? source;
  final String? sourceStatusCode;
  final String? requestId;

  const ProxyResponseDto({
    required this.data,
    required this.status,
    required this.message,
    required this.source,
    required this.sourceStatusCode,
    required this.requestId,
  });
  
}