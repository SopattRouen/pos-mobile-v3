Map<String, String> buildSelectionMap({
  required dynamic apiData,
  required String dataKey,
}) {
  final dataSetUp = apiData?[dataKey];

  if (dataSetUp == null || dataSetUp is! List) {
    return {};
  }

  Map<String, String> result = {};

  for (var item in dataSetUp) {
    if (item is Map<String, dynamic>) {
      final id = item['id']?.toString();
      final name = item['name']?.toString() ?? '';

      if (id != null && name.isNotEmpty) {
        result[id] = name;
      }
    }
  }

  return result;
}