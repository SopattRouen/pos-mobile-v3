class ResponseStructure<T> {
  final int? statusCode;
  final int success;
  final String message; // Change from Message object to simple String
  final T data;

  ResponseStructure({
    this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ResponseStructure.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) dataFromJson,
  }) {
    return ResponseStructure<T>(
      statusCode: json['status_code'] as int?,
      success: json['success'] ?? 1, // Add fallback if field missing
      message: json['message'] as String,
      data: dataFromJson(json['dashboard'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) dataToJson,
  }) {
    final Map<String, dynamic> result = {
      'success': success,
      'message': message,
      'dashboard': dataToJson(data),
    };
    if (statusCode != null) result['status_code'] = statusCode;
    return result;
  }
}
