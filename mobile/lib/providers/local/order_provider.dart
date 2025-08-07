import 'package:flutter/material.dart';
import 'package:calendar/services/order_service.dart';

class CartItem {
  final int id;
  final String name;
  final String code;
  final String category;
  final int unitPrice;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.unitPrice,
    required this.image,
    this.quantity = 1,
  });

  double get totalPrice => unitPrice.toDouble() * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(), // Convert int id to String for API
      'name': name,
      'code': code,
      'category': category,
      'unit_price': unitPrice,
      'image': image,
      'quantity': quantity,
      'total_price': totalPrice,
    };
  }
}

class OrderProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _productData;
  Map<String, dynamic>? _productType;
  List<CartItem> _cartItems = [];

  final OrderService _service = OrderService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get productData => _productData;
  Map<String, dynamic>? get productType => _productType;
  List<CartItem> get cartItems => _cartItems;
  int get cartItemCount =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  OrderProvider() {
    getHome();
  }

  Future<void> getHome() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getData();
      _productData = response;
    } catch (e) {
      _error = "Invalid Credential.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCart(Map<String, dynamic> product) {
    final existingIndex = _cartItems.indexWhere(
      (item) =>
          item.id ==
          (product['id'] is int
              ? product['id']
              : int.parse(product['id'].toString())),
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(
        CartItem(
          id:
              product['id'] is int
                  ? product['id']
                  : int.parse(product['id'].toString()),
          name: product['name'] as String,
          code: product['code'] as String,
          category: product['category'] as String,
          unitPrice:
              product['unit_price'] is int
                  ? product['unit_price']
                  : int.parse(product['unit_price'].toString()),
          image: product['image'] as String,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    final existingIndex = _cartItems.indexWhere((item) => item.id == productId);

    if (existingIndex != -1) {
      if (_cartItems[existingIndex].quantity > 1) {
        _cartItems[existingIndex].quantity--;
      } else {
        _cartItems.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void updateQuantity(int productId, int newQuantity) {
    final existingIndex = _cartItems.indexWhere((item) => item.id == productId);

    if (existingIndex != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(existingIndex);
      } else {
        _cartItems[existingIndex].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  int getProductQuantity(int productId) {
    final existingIndex = _cartItems.indexWhere((item) => item.id == productId);
    return existingIndex != -1 ? _cartItems[existingIndex].quantity : 0;
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Map<String, dynamic> getCartSummary() {
    return {
      'items': _cartItems.map((item) => item.toJson()).toList(),
      'total_quantity': cartItemCount,
      'total_amount': cartTotal,
    };
  }
}
