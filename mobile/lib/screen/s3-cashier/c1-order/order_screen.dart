// =======================>> Flutter Core
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:calendar/providers/local/order_provider.dart';
import 'package:calendar/screen/s3-cashier/c1-order/reciept_screen.dart';
import 'package:calendar/services/order_service.dart';
import 'package:calendar/shared/entity/enum/e_variable.dart';
import 'package:calendar/shared/skeleton/order_skeleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// =======================>> Routing
// import 'package:go_router/go_router.dart';
// import 'package:calendar/app_routes.dart';

// =======================>> Providers Components
import 'package:provider/provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

// ::: Class-p1 > OrderScreen (StatefulWidget)
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

// ::: Class-sp1 > _OrderScreenState (State<OrderScreen>)
class _OrderScreenState extends State<OrderScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  int _selectedTabIndex = 0;

  Future<void> _refreshData(OrderProvider provider) async {
    return await provider.getHome();
  }

  String? userName;
  String? userAvatar;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final authProvider = AuthProvider();
  Future<void> _loadUserData() async {
    try {
      final name = await authProvider.getUserName();
      final avatar = await authProvider.getUserAvatar();
      final role = await authProvider.getUserRole();

      print("🔍 Loading user data - Name: $name, Role: $role,");
      if (mounted) {
        setState(() {
          userName = name ?? 'Unknown User';
          userAvatar = avatar;
          userRole = role ?? 'No Role';
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
      if (mounted) {
        setState(() {
          userName = 'Unknown User';
          userRole = 'No Role';
          isLoading = false;
        });
      }
    }
  }

  void showBottomSwitchRole() async {
    final roles = await authProvider.getAllRoles();
    final currentRole = await authProvider.getCurrentRole();
    final currentRoleId = currentRole?['id'].toString();

    if (roles == null || roles.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('No roles available')),
      );
      return;
    }

    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: false,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final role = roles[index];
                final roleId = role['id'].toString();
                final isCurrent = roleId == currentRoleId;

                return ListTile(
                  leading: Icon(Icons.person, color: HColors.darkgrey),
                  title: Text(role['name']),
                  trailing:
                      isCurrent
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                  onTap: () async {
                    if (isCurrent) return;

                    Navigator.pop(context); // Close the bottom sheet
                    print("✅ Bottom sheet dismissed");

                    final navigator = Navigator.of(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (ctx) => Center(child: CircularProgressIndicator()),
                    ).then((_) => print("✅ Loading dialog closed"));

                    try {
                      await authProvider.switchRoleApi(
                        defRoleId: currentRoleId ?? '',
                        swRoleId: role['id'].toString(),
                      );

                      navigator.pop(); // Dismiss dialog
                      print("✅ Loading dialog dismissed");

                      // Always refresh user data after switch attempt to sync with the latest token
                      await _loadUserData();

                      final updatedRole = await authProvider.getCurrentRole();
                      final message =
                          roleId == updatedRole?['id'].toString()
                              ? 'Switched to ${role['name']}'
                              : '${role['name']} is already the current role';
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                      print("✅ SnackBar shown: $message");
                      print(
                        "🔍 Updated current role: ${updatedRole?['name']} (ID: ${updatedRole?['id']})",
                      );
                    } catch (e) {
                      navigator.pop(); // Dismiss dialog
                      print("✅ Loading dialog dismissed on error");

                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        SnackBar(content: Text('Failed to switch role: $e')),
                      );
                      print("❌ Error SnackBar shown: $e");
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        // Extract categories from the data structure
        final List<String> categories = ['All'];
        final List<Map<String, dynamic>> products = [];

        if (provider.productData != null &&
            provider.productData?['data'] is List) {
          final dataList = provider.productData!['data'] as List;

          // Extract categories and products
          for (var categoryData in dataList) {
            final categoryName = categoryData['name'] as String?;
            if (categoryName != null && !categories.contains(categoryName)) {
              categories.add(categoryName);
            }

            // Extract products from each category
            if (categoryData['products'] is List) {
              final categoryProducts = categoryData['products'] as List;
              for (var productData in categoryProducts) {
                products.add({
                  'id': productData['id'],
                  'category': categoryName ?? 'Unknown',
                  'code': productData['code'] ?? '',
                  'name': productData['name'] ?? '',
                  'price':
                      productData['unit_price'] != null
                          ? '${productData['unit_price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛'
                          : '0 ៛',
                  'image': productData['image'] ?? '',
                  'unit_price': productData['unit_price'] ?? 0,
                });
              }
            }
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(2),
              child: Stack(
                children: [
                  Positioned(
                    top: -2,
                    left: -15,
                    child: Image.asset(
                      'assets/images/Kbach.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Image.asset(
                    'assets/logo/posmobile1.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            title: Text(
              "ប្រព័ន្ធគ្រប់គ្រងការលក់",
              style: TextStyle(fontSize: 18),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: showBottomSwitchRole,
                  child: _buildAvatar(),
                ),
              ),
            ],
            bottom: CustomHeader(),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: Colors.blue[800],
              backgroundColor: Colors.white,
              onRefresh: () => _refreshData(provider),
              child:
                  provider.isLoading
                      ? const OrderSkeleton() // Replace with OrderSkeleton
                      : provider.error != null
                      ? Center(child: Text('Something went wrong'))
                      : SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category tabs
                            SizedBox(
                              height: 50,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List.generate(categories.length, (
                                  index,
                                ) {
                                  final bool isSelected =
                                      _selectedTabIndex == index;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: ChoiceChip(
                                      label: Text(
                                        categories[index],
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? Color(0xFF1A73E8)
                                                  : Color(0xFF5F6368),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTabIndex = index;
                                        });
                                      },
                                      selectedColor: Color(0xFFE8F0FE),
                                      backgroundColor: Colors.white,
                                      // This removes the default check icon
                                      showCheckmark: false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color:
                                              isSelected
                                                  ? Colors.transparent
                                                  : Color(0xFFDDDDDD),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            // Product list
                            if (_filteredProducts(products, categories).isEmpty)
                              Center(
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('គ្មានទិន្នន័យ'),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.95,
                                      mainAxisSpacing: 0.6,
                                    ),
                                itemCount:
                                    _filteredProducts(
                                      products,
                                      categories,
                                    ).length,
                                itemBuilder: (context, index) {
                                  final product =
                                      _filteredProducts(
                                        products,
                                        categories,
                                      )[index];
                                  return InkWell(
                                    // onTap: () {
                                    //   context.push(
                                    //     '/product-detail/${product['id']}',
                                    //   );
                                    // },
                                    child: ProductItem(
                                      product: product,
                                      category:
                                          '${product['category']} | ${product['code']}',
                                      name: product['name'],
                                      price: product['price'],
                                      image: product['image'],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
            ),
          ),
          floatingActionButton:
              Provider.of<OrderProvider>(context, listen: false).cartItemCount >
                      0
                  ? FloatingActionButton(
                    backgroundColor: HColors.blue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    onPressed: () {
                      final provider = Provider.of<OrderProvider>(
                        context,
                        listen: false,
                      );
                      _showCartBottomSheet(context, provider);
                    },
                    child: Consumer<OrderProvider>(
                      builder: (context, provider, child) {
                        return Stack(
                          children: [
                            if (provider.cartItemCount > 0)
                              IconButton(
                                onPressed: () {
                                  // Navigate to cart screen
                                  _showCartBottomSheet(context, provider);
                                },
                                icon: Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            if (provider.cartItemCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${provider.cartItemCount}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  )
                  : null,
        );
      },
    );
  }

  void _showCartBottomSheet(BuildContext context, OrderProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Consumer<OrderProvider>(
            builder:
                (context, provider, child) => Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'ទំនិញក្នុងកន្ត្រក់',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                                provider.cartItems.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            size: 64,
                                            color: HColors.darkgrey,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            'កន្ត្រក់ទំនិញទទេ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              // color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: provider.cartItems.length,
                                      itemBuilder: (context, index) {
                                        final item = provider.cartItems[index];
                                        final TextEditingController
                                        quantityController =
                                            TextEditingController(
                                              text: item.quantity.toString(),
                                            );
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.network(
                                                  'https://pos-v2-file.uat.camcyber.com/${item.image}',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.contain,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        width: 50,
                                                        height: 50,
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                          Icons.error,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${item.category} | ${item.code}',
                                                      style: const TextStyle(
                                                        color: HColors.darkgrey,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(item.unitPrice * item.quantity).toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛',
                                                      style: const TextStyle(
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      provider.removeFromCart(
                                                        item.id,
                                                      );
                                                    },
                                                    icon:
                                                        item.quantity == 1
                                                            ? Icon(
                                                              CupertinoIcons
                                                                  .delete,
                                                              color: Colors.red,
                                                            )
                                                            : const Icon(
                                                              CupertinoIcons
                                                                  .minus_circle,
                                                              color: Colors.red,
                                                            ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        35, // Adjust width to fit input field
                                                    child: TextField(
                                                      controller:
                                                          quantityController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      onSubmitted: (value) {
                                                        final newQuantity =
                                                            int.tryParse(
                                                              value,
                                                            ) ??
                                                            1;
                                                        provider.updateQuantity(
                                                          item.id,
                                                          newQuantity,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      provider.addToCart({
                                                        'id': item.id,
                                                        'name': item.name,
                                                        'code': item.code,
                                                        'category':
                                                            item.category,
                                                        'unit_price':
                                                            item.unitPrice,
                                                        'image': item.image,
                                                      });
                                                    },
                                                    icon: const Icon(
                                                      Icons
                                                          .add_circle_outline_outlined,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                          ),
                          if (provider.cartItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'សរុប',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${provider.cartTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            provider.clearCart();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('សម្អាត'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final provider =
                                                Provider.of<OrderProvider>(
                                                  context,
                                                  listen: false,
                                                );
                                            final cartSummary =
                                                provider.getCartSummary();
                                            final cartItems =
                                                cartSummary['items']
                                                    as List<
                                                      Map<String, dynamic>
                                                    >;

                                            if (cartItems.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'កន្ត្រក់ទំនិញទទេ',
                                                  ), // "Cart is empty"
                                                  backgroundColor: const Color(
                                                    0xFFFF9999,
                                                  ), // Pastel red
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            print(
                                              'Cart items: $cartItems',
                                            ); // Debug

                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder:
                                                  (context) => const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          // color: Color(
                                                          //   0xFF99FF99,
                                                          // ), // Pastel green
                                                        ),
                                                  ),
                                            );

                                            try {
                                              final service = OrderService();
                                              final response = await service
                                                  .orderProduct(
                                                    cart: cartItems,
                                                  );
                                              Navigator.pop(
                                                context,
                                              ); // Close loading dialog
                                              Navigator.pop(
                                                context,
                                              ); // Close bottom sheet

                                              // Navigate to RecieptScreen with order data
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) => RecieptScreen(
                                                        orderId:
                                                            response['order_id']
                                                                ?.toString() ??
                                                            'N/A',
                                                        cartItems: cartItems,
                                                        totalAmount:
                                                            provider.cartTotal,
                                                        orderResponse: response,
                                                      ),
                                                  transitionsBuilder: (
                                                    context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child,
                                                  ) {
                                                    const begin = Offset(
                                                      0.0,
                                                      1.0,
                                                    ); // Start from bottom
                                                    const end =
                                                        Offset
                                                            .zero; // End at top
                                                    const curve =
                                                        Curves.easeInOut;

                                                    final tween = Tween(
                                                      begin: begin,
                                                      end: end,
                                                    ).chain(
                                                      CurveTween(curve: curve),
                                                    );
                                                    final offsetAnimation =
                                                        animation.drive(tween);

                                                    return SlideTransition(
                                                      position: offsetAnimation,
                                                      child: child,
                                                    );
                                                  },
                                                  transitionDuration:
                                                      const Duration(
                                                        milliseconds: 300,
                                                      ), // Smooth duration
                                                ),
                                              );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'បញ្ជាទិញជោគជ័យ!',
                                                  ), // "Order placed successfully!"
                                                  // backgroundColor: const Color(
                                                  //   0xFF99FF99,
                                                  // ), // Pastel green
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              );
                                              provider.clearCart();
                                            } catch (e) {
                                              Navigator.pop(
                                                context,
                                              ); // Close loading dialog
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'បញ្ជាទិញបរាជ័យ: $e',
                                                  ), // "Failed to place order"
                                                  // backgroundColor: const Color(
                                                  //   0xFFFF9999,
                                                  // ), // Pastel red
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: HColors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('បញ្ជាទិញ'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  List<Map<String, dynamic>> _filteredProducts(
    List<Map<String, dynamic>> products,
    List<String> categories,
  ) {
    if (_selectedTabIndex == 0) return products;
    final selectedCategory = categories[_selectedTabIndex];
    return products
        .where(
          (product) =>
              product['category'] == selectedCategory ||
              (selectedCategory == 'Food' &&
                  product['category'].startsWith('Food')),
        )
        .toList();
  }

  Widget _buildAvatar() {
    Widget avatarImage;

    if (userAvatar != null && userAvatar!.isNotEmpty) {
      if (userAvatar!.startsWith('http')) {
        avatarImage = Image.network(
          userAvatar!,
          width: 25.0,
          height: 25.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      } else {
        avatarImage = Image.network(
          '$mainUrlFile$userAvatar',
          width: 25.0,
          height: 25.0,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    } else {
      avatarImage = _buildDefaultAvatar();
    }

    return Stack(
      children: [
        ClipOval(
          child: Container(
            width: 36.0,
            height: 36.0,
            color: Colors.grey.withOpacity(0.1),
            child: avatarImage,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.withOpacity(0.5),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 24.0, color: Colors.white),
      ),
    );
  }
}

// ::: Class-c1 > ProductItem (StatelessWidget)
class ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final String category;
  final String name;
  final String price;
  final String image;

  const ProductItem({
    super.key,
    required this.product,
    required this.category,
    required this.name,
    required this.price,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        constraints: BoxConstraints(
          minHeight: 0, // Remove minimum height constraints
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image
                Container(
                  height:
                      constraints.maxWidth *
                      0.7, // Dynamic height based on width
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://pos-v2-file.uat.camcyber.com/$image',
                      ),
                      fit: BoxFit.fitHeight,
                      onError:
                          (exception, stackTrace) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, color: Colors.red),
                          ),
                    ),
                  ),
                ),

                // Detail Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Name and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              price,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 4),

                      // Quantity Control
                      Consumer<OrderProvider>(
                        builder: (context, provider, child) {
                          final quantity = provider.getProductQuantity(
                            product['id'],
                          );
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: HColors.darkgrey.withOpacity(0.2),
                              ),
                            ),
                            constraints: BoxConstraints(
                              maxHeight: 36, // Limit maximum height
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (quantity > 0) ...[
                                  _AnimatedIconButton(
                                    onPressed: () {
                                      provider.removeFromCart(product['id']);
                                    },
                                    icon: Icon(
                                      quantity == 1
                                          ? CupertinoIcons.delete
                                          : CupertinoIcons.minus,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                _AnimatedIconButton(
                                  onPressed: () {
                                    provider.addToCart(product);
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    color: HColors.darkgrey,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ::: Class-c2 > _AnimatedIconButton (StatefulWidget)
// Helper widget for animated icon buttons
class _AnimatedIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;

  const _AnimatedIconButton({required this.onPressed, required this.icon});

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
}

// ::: Class-sc2 > _AnimatedIconButtonState (State<_AnimatedIconButton>)
class _AnimatedIconButtonState extends State<_AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.icon),
    );
  }
}
