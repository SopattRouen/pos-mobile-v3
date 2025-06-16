import 'package:flutter/material.dart';
import 'package:calendar/services/sale_service.dart';
import 'package:intl/intl.dart';

class SaleProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _saleData;
  List<Map<String, dynamic>> _groupedTransactions = [];
  double _totalSales = 0.0;

  final SaleService _saleService = SaleService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get saleData => _saleData;
  List<Map<String, dynamic>> get groupedTransactions => _groupedTransactions;
  double get totalSales => _totalSales;

  Future<void> getHome({
    String? from,
    String? to,
    String? cashier,
    String? platform,
    String? sort,
    String? order,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _saleService.getData(
        from: from,
        to: to,
        cashier: cashier,
        platform: platform,
        sort: sort,
        order: order,
      );
      _saleData = response;
      _processSaleData();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processSaleData() {
    if (_saleData == null || _saleData!['data'] == null) return;

    _totalSales = 0.0;
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    final transactions = _saleData!['data'] as List<dynamic>;
    for (var transaction in transactions) {
      final transactionMap = transaction as Map<String, dynamic>;
      final totalPrice =
          (transactionMap['total_price'] as num?)?.toDouble() ?? 0.0;
      _totalSales += totalPrice;

      final orderedAt = transactionMap['ordered_at'];
      if (orderedAt is! String) {
        continue; // Skip if ordered_at is not a String
      }

      try {
        String date = DateFormat(
          'MMMM d',
        ).format(DateTime.parse(orderedAt).toLocal());

        if (!groupedByDate.containsKey(date)) {
          groupedByDate[date] = [];
        }
        groupedByDate[date]!.add(transactionMap);
      } catch (e) {
        // Skip transactions with invalid date formats
        continue;
      }
    }

    _groupedTransactions =
        groupedByDate.entries.map((entry) {
            return {'date': entry.key, 'transactions': entry.value};
          }).toList()
          ..sort(
            (a, b) => DateFormat('MMMM d')
                .parse(b['date'] as String)
                .compareTo(DateFormat('MMMM d').parse(a['date'] as String)),
          );
  }

  Future<void> deleteSale(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _saleService.deleteSale(id);
      // Update saleData by removing the deleted sale
      if (_saleData != null && _saleData!['data'] is List) {
        _saleData!['data'] =
            (_saleData!['data'] as List)
                .where((transaction) => transaction['id'] != id)
                .toList();
        _processSaleData(); // Reprocess to update groupedTransactions and totalSales
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete sale: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
