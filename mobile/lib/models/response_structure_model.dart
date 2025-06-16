class ResponseStructure<T> {
  final int? statusCode;
  final int success;
  final String? message;
  final T data;

  ResponseStructure({
    this.statusCode,
    required this.success,
    this.message,
    required this.data,
  });

  factory ResponseStructure.fromJson(
    Map<String, dynamic>? json, {
    required T Function(dynamic) dataFromJson,
  }) {
    // If json is null, provide default values
    json ??= <String, dynamic>{};

    // Check for 'data' or 'dashboard' key, fallback to empty map if neither exists
    final dataJson = json['data'] ?? json['dashboard'] ?? <String, dynamic>{};

    return ResponseStructure<T>(
      statusCode: json['status_code'] is int ? json['status_code'] as int? : null,
      success: json['success'] is int ? json['success'] as int : 1,
      message: json['message']?.toString(),
      data: dataFromJson(dataJson),
    );
  }

  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) dataToJson,
  }) {
    final Map<String, dynamic> result = {
      'success': success,
      'data': dataToJson(data),
    };
    if (statusCode != null) result['status_code'] = statusCode;
    if (message != null) result['message'] = message;
    return result;
  }
}