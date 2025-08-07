// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// =======================>> Providers Components
import 'package:calendar/providers/local/product/detail_product_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/entity/enum/e_variable.dart';
import 'package:calendar/shared/entity/helper/colors.dart';


class DetailProduct extends StatefulWidget {
  const DetailProduct({super.key, required this.id});
  final String id;

  @override
  State<DetailProduct> createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to format currency
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)} ៛';
  }

  // Helper method to format date
  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailProductProvider(id: widget.id),
      child: Consumer<DetailProductProvider>(
        builder: (context, provider, child) {
          // Get product data from first sale item (if available)
          final productData =
              provider.groupedTransactions.isNotEmpty &&
                      provider
                          .groupedTransactions[0]['transactions']
                          .isNotEmpty &&
                      provider.groupedTransactions[0]['transactions'][0]['details'] !=
                          null &&
                      provider
                          .groupedTransactions[0]['transactions'][0]['details']
                          .isNotEmpty
                  ? provider
                      .groupedTransactions[0]['transactions'][0]['details'][0]['product']
                  : null;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(productData?['name'] ?? 'Product Details'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: () {
                      context.push('/product-update/${widget.id}');
                    },
                    icon: Icon(Icons.edit_outlined, color: HColors.darkgrey),
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [Tab(text: 'ទូទៅ'), Tab(text: 'ការលក់')],
                labelColor: Colors.blueAccent,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'KantumruyPro',
                  fontWeight: FontWeight.w400,
                ),
                unselectedLabelColor: HColors.darkgrey,
                indicatorColor: Colors.blueAccent,
                dividerHeight: 1,
                dividerColor: HColors.darkgrey.withOpacity(0.5),
              ),
            ),
            body:
                provider.isLoading
                    ? Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                          Text(
                            'សូមរងចាំ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                    : provider.error != null
                    ? Center(child: Text('Something went wrong'))
                    : SafeArea(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // First Tab - Product Details
                          Column(
                            children: [
                              // Product Image Section
                              Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: EdgeInsets.all(40),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Product Image
                                    Container(
                                      width: 120,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: HColors.darkgrey.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        image:
                                            productData?['image'] != null
                                                ? DecorationImage(
                                                  image: NetworkImage(
                                                    mainUrlFile +
                                                        productData['image'],
                                                  ),
                                                  fit: BoxFit.cover,
                                                )
                                                : null,
                                      ),
                                      child:
                                          productData?['image'] == null
                                              ? Center(
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  size: 42,
                                                  color: HColors.darkgrey,
                                                ),
                                              )
                                              : null,
                                    ),
                                  ],
                                ),
                              ),

                              // Product Details Card
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      // Product Code
                                      _buildDetailRow(
                                        icon: Icons.tag,
                                        text: productData?['code'] ?? 'N/A',
                                        hasArrow: true,
                                      ),

                                      // Product Name
                                      _buildDetailRow(
                                        icon: Icons.edit,
                                        text: productData?['name'] ?? 'N/A',
                                        hasArrow: true,
                                      ),

                                      // Category
                                      _buildDetailRow(
                                        icon: Icons.category,
                                        text:
                                            productData?['type']?['name'] ??
                                            'N/A',
                                        hasArrow: true,
                                      ),

                                      // Price (from first sale detail)
                                      _buildDetailRow(
                                        icon: Icons.local_offer,
                                        text:
                                            provider
                                                        .groupedTransactions
                                                        .isNotEmpty &&
                                                    provider
                                                        .groupedTransactions[0]['transactions']
                                                        .isNotEmpty
                                                ? _formatCurrency(
                                                  (provider.groupedTransactions[0]['transactions'][0]['details'][0]['unit_price']
                                                          as num)
                                                      .toDouble(),
                                                )
                                                : 'N/A',
                                        hasArrow: true,
                                      ),

                                      // Date (from first sale)
                                      _buildDetailRow(
                                        icon: Icons.calendar_today,
                                        text:
                                            provider
                                                        .groupedTransactions
                                                        .isNotEmpty &&
                                                    provider
                                                        .groupedTransactions[0]['transactions']
                                                        .isNotEmpty
                                                ? _formatDate(
                                                  provider
                                                      .groupedTransactions[0]['transactions'][0]['ordered_at'],
                                                )
                                                : 'N/A',
                                        hasArrow: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Second Tab - Sales History
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: RefreshIndicator(
                              key: GlobalKey<RefreshIndicatorState>(),
                              color: Colors.blue[800],
                              backgroundColor: Colors.white,
                              onRefresh:
                                  () async =>
                                      await provider.getHome(id: widget.id),
                              child:
                                  provider.isLoading
                                      ? Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                            Text(
                                              'សូមរងចាំ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : provider.error != null
                                      ? Center(
                                        child: Text('Something went wrong'),
                                      )
                                      : SafeArea(
                                        child: Column(
                                          children: [
                                            // Total Sales Section
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(20),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFFE5E5E5),
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ការលក់សរុប',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: HColors.darkgrey,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    NumberFormat(
                                                      "#,##0 ៛",
                                                    ).format(
                                                      provider.totalSales,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily:
                                                          'KantumruyPro',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      // color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Sales History List
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  provider
                                                      .groupedTransactions
                                                      .length,
                                              itemBuilder: (context, index) {
                                                final group =
                                                    provider
                                                        .groupedTransactions[index];
                                                return Column(
                                                  children: [
                                                    _buildDateHeader(
                                                      group['date'],
                                                    ),
                                                    ...group['transactions'].asMap().entries.map((
                                                      entry,
                                                    ) {
                                                      final transaction =
                                                          entry.value;
                                                      final String avatarUrl =
                                                          transaction['cashier']['avatar'] !=
                                                                  null
                                                              ? 'https://pos-v2-file.uat.camcyber.com/${transaction['cashier']['avatar']}'
                                                              : '';
                                                      return _buildSalesItem(
                                                        transaction['receipt_number'] ??
                                                            'N/A',
                                                        NumberFormat(
                                                          "#,##0 ៛",
                                                        ).format(
                                                          transaction['total_price'] ??
                                                              0.0,
                                                        ),
                                                        avatarUrl,
                                                        transaction['id'],
                                                        provider,
                                                        transaction['cashier']?['name'] ??
                                                            'Unknown', // Pass cashierName
                                                      );
                                                    }).toList(),
                                                  ],
                                                );
                                              },
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }

  // // Helper method to build grouped sales
  // List<Widget> _buildGroupedSales(
  //   List<Map<String, dynamic>> groupedTransactions,
  // ) {
  //   List<Widget> widgets = [];

  //   for (var group in groupedTransactions) {
  //     final date = group['date'] as String;
  //     final sales = group['transactions'] as List<dynamic>;
  //     widgets.add(_buildDateHeader(date));

  //     for (var sale in sales) {
  //       widgets.add(
  //         _buildSalesItem(
  //           sale['receipt_number'] ?? 'N/A',
  //           _formatCurrency((sale['total_price'] as num?)?.toDouble() ?? 0.0),
  //           sale['cashier']?['id'] == 1, // Assuming cashier ID 1 is user1
  //           sale['cashier']?['name'] ?? 'Unknown',
  //         ),
  //       );
  //     }

  //     widgets.add(SizedBox(height: 16));
  //   }

  //   return widgets;
  // }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required bool hasArrow,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: HColors.darkgrey),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF0F2F5),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 14,
          color: HColors.darkgrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSalesItem(
    String order,
    String amount,
    String avatarUrl,
    int id,
    DetailProductProvider provider,
    String cashierName, // Added cashierName parameter
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: [
          // Transaction icon
          SizedBox(
            width: 40,
            height: 40,
            child: const Icon(
              Icons.receipt_long,
              color: HColors.darkgrey,
              size: 20,
            ),
          ),
          // Transaction ID and Cashier Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: HColors.darkgrey,
                  ),
                ),
                Text(
                  cashierName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HColors.darkgrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: HColors.green,
            ),
          ),
          const SizedBox(width: 8),
          // User avatar
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child:
                  avatarUrl.isNotEmpty
                      ? Image.network(
                        avatarUrl,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF9800),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.white,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE5E5E5),
                            ),
                            child: const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF9800),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
