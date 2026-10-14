class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? date;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.date,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic dataJson)? fromDataJson,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromDataJson != null
          ? fromDataJson(json['data'])
          : json['data'] as T?,
      date: json['date'] as String?,
    );
  }
}

class PageResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool last;
  final bool first;

  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    this.last = false,
    this.first = true,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> itemJson) fromItemJson,
  ) {
    final rawList = json['content'] as List<dynamic>? ?? [];
    return PageResponse<T>(
      content: rawList
          .map((item) => fromItemJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      size: json['size'] as int? ?? 10,
      number: json['number'] as int? ?? 0,
      last: json['last'] as bool? ?? false,
      first: json['first'] as bool? ?? true,
    );
  }
}
