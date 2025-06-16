class PaginationStructure<T> {
  final int limit;
  final int page;
  final int totalPage;
  final int total;
  final List<T> results;

  PaginationStructure({
    required this.limit,
    required this.page,
    required this.totalPage,
    required this.total,
    required this.results,
  });

  factory PaginationStructure.fromJson(
    Map<String, dynamic>? json, {
    required T Function(Map<String, dynamic>) resultFromJson,
  }) {
    // If json is null, provide default values
    json ??= <String, dynamic>{};

    // Check for pagination data, default to json root if not nested
    final paginationJson = json['pagination'] as Map<String, dynamic>? ?? json;

    // Safely parse fields with fallbacks
    final limit = paginationJson['limit'] is int
        ? paginationJson['limit'] as int
        : int.tryParse(paginationJson['limit']?.toString() ?? '') ?? 0;
    final page = paginationJson['page'] is int
        ? paginationJson['page'] as int
        : int.tryParse(paginationJson['page']?.toString() ?? '') ?? 1;
    final totalPage = paginationJson['totalPage'] is int
        ? paginationJson['totalPage'] as int
        : int.tryParse(paginationJson['totalPage']?.toString() ?? '') ?? 0;
    final total = paginationJson['total'] is int
        ? paginationJson['total'] as int
        : int.tryParse(paginationJson['total']?.toString() ?? '') ?? 0;

    // Check for 'data' or 'results' key, default to empty list if neither exists
    final resultsJson = json['data'] as List<dynamic>? ??
                       json['results'] as List<dynamic>? ??
                       <dynamic>[];

    // Parse results, handling null or invalid items
    final results = resultsJson
        .where((item) => item is Map<String, dynamic>)
        .map((item) => resultFromJson(item as Map<String, dynamic>))
        .toList();

    return PaginationStructure<T>(
      limit: limit,
      page: page,
      totalPage: totalPage,
      total: total,
      results: results,
    );
  }

  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(T) resultToJson,
  }) {
    return {
      'pagination': {
        'limit': limit,
        'page': page,
        'totalPage': totalPage,
        'total': total,
      },
      'data': results.map((item) => resultToJson(item)).toList(),
    };
  }
}
// Example usage with a sample Result class:
/*
class EventResult {
  final int id;
  final DateTime startDatetime;
  final DateTime endDatetime;

  EventResult({
    required this.id,
    required this.startDatetime,
    required this.endDatetime,
  });

  factory EventResult.fromJson(Map<String, dynamic> json) {
    return EventResult(
      id: json['id'] as int,
      startDatetime: DateTime.parse(json['start_datetime'] as String),
      endDatetime: DateTime.parse(json['end_datetime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_datetime': startDatetime.toIso8601String(),
      'end_datetime': endDatetime.toIso8601String(),
    };
  }
}

void main() {
  // Sample JSON
  String jsonString = '''
  {
    "limit": 50,
    "offset": 1,
    "total": 12,
    "results": [
      {
        "id": 11,
        "start_datetime": "2025-04-08T00:00:00.000Z",
        "end_datetime": "2025-04-10T00:00:00.000Z"
      }
    ]
  }
  ''';

  // Parse JSON with specific type
  final pagination = PaginationStructure<EventResult>.fromJson(
    jsonDecode(jsonString),
    resultFromJson: (json) => EventResult.fromJson(json),
  );

  // Access values with type safety
  print(pagination.limit);         // 50
  print(pagination.offset);        // 1
  print(pagination.total);         // 12
  print(pagination.results[0].id); // 11
  print(pagination.results[0].startDatetime); // 2025-04-08...

  // Convert back to JSON
  final json = pagination.toJson(
    resultToJson: (result) => result.toJson(),
  );
  print(jsonEncode(json));
}
*/
