// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:intl/intl.dart';

// =======================>> Local Services
import 'package:calendar/services/product_service.dart';


class DetailProductProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _detailProduct;
  List<dynamic> _saleData = [];
  List<Map<String, dynamic>> _groupedTransactions = [];
  double _totalSales = 0.0;

  // Services
  final ProductService _service = ProductService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get detailProduct => _detailProduct;
  List<dynamic> get saleData => _saleData;
  List<Map<String, dynamic>> get groupedTransactions => _groupedTransactions;
  double get totalSales => _totalSales;

  // Initialize
  DetailProductProvider({required String id}) {
    getHome(id: id);
  }

  // Functions
  Future<void> getHome({required String id}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getDetailProduct(id: id);
      _detailProduct = response;
      _saleData = (response['data'] as List<dynamic>?) ?? [];
      _processSaleData();
    } catch (e) {
      _error = "Failed to load product details.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processSaleData() {
    _totalSales = 0.0;
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var transaction in _saleData) {
      final transactionMap = transaction as Map<String, dynamic>;
      final totalPrice =
          (transactionMap['total_price'] as num?)?.toDouble() ?? 0.0;
      _totalSales += totalPrice;

      final orderedAt = transactionMap['ordered_at'];
      if (orderedAt is! String) {
        continue; // Skip if ordered_at is not a String
      }

      try {
        String date = DateFormat('MMMM d').format(DateTime.parse(orderedAt));
        if (!groupedByDate.containsKey(date)) {
          groupedByDate[date] = [];
        }
        groupedByDate[date]!.add(transactionMap);
      } catch (e) {
        // Skip transactions with invalid date formats
        continue;
      }
    }

    _groupedTransactions = groupedByDate.entries
        .map((entry) => {'date': entry.key, 'transactions': entry.value})
        .toList()
      ..sort(
        (a, b) => DateFormat('MMMM d')
            .parse(b['date'] as String)
            .compareTo(DateFormat('MMMM d').parse(a['date'] as String)),
      );
  }
}