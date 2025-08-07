// =======================>> Dart Core
import 'dart:ui';

// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-Party Packages
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

// =======================>> Shared Components & Helpers
import 'package:calendar/shared/entity/helper/colors.dart';

class TransactionDetailModal extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final bool isFullScreen;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    this.isFullScreen = false,
  });

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late DraggableScrollableController _sheetController;
  bool _isMinimized = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start from bottom
      end: Offset.zero, // End at original position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    _sheetController = DraggableScrollableController();
    _sheetController.addListener(() {
      setState(() {
        _isMinimized = (_sheetController.size <= 0.4 + 0.01);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime orderedAt =
        DateTime.parse(widget.transaction['ordered_at']).toLocal();
    final String formattedDate = DateFormat('dd-MM-yyyy').format(orderedAt);
    final String formattedTime = DateFormat('hh:mm a').format(orderedAt);
    final List<dynamic> details = widget.transaction['details'] ?? [];

    if (widget.isFullScreen) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'វិក្ក័យប័ត្រ #${widget.transaction['receipt_number']} •',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
        ),
        body: _buildContent(context, formattedDate, formattedTime, details),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Tap Area (dismiss sheet)
          GestureDetector(
            onTap: () {
              _controller.reverse().then((_) => Navigator.of(context).pop());
            },
            // child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          // Bottom Sheet with Slide Animation
          SlideTransition(
            position: _slideAnimation,
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.4,
              minChildSize: 0.4,
              maxChildSize: 0.8,
              snap: true,
              snapSizes: const [0.4, 0.8],
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: _buildContent(
                    context,
                    formattedDate,
                    formattedTime,
                    details,
                    scrollController: scrollController,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String formattedDate,
    String formattedTime,
    List<dynamic> details, {
    ScrollController? scrollController,
  }) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.isFullScreen)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'វិក្ក័យប័ត្រ #${widget.transaction['receipt_number']} •',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              widget.transaction['platform'] == 'Mobile'
                                  ? Icons.phone_android_outlined
                                  : Icons.monitor,
                              color: Colors.black,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 24,
                        ),
                        onPressed: () {
                          _controller.reverse().then(
                            (_) => Navigator.of(context).pop(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipOval(
                            child: Container(
                              color: Colors.grey.shade300,
                              width: 40,
                              height: 40,
                              child:
                                  widget.transaction['cashier']?['avatar'] !=
                                          null
                                      ? Image.network(
                                        'https://pos-v2-file.uat.camcyber.com/${widget.transaction['cashier']['avatar']}',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.person,
                                                  color: Color(0xFF6B7280),
                                                  size: 24,
                                                ),
                                      )
                                      : const Icon(
                                        Icons.person,
                                        color: Color(0xFF6B7280),
                                        size: 24,
                                      ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'អ្នកគិតប្រាក់',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: HColors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.transaction['cashier']?['name'] ??
                                      'Unknown User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '$formattedDate • $formattedTime',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 60),
                        child: Divider(
                          thickness: 1,
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: details.length + 1,
                        itemBuilder: (context, index) {
                          if (index < details.length) {
                            final item = details[index];
                            final product = item['product'] ?? {};
                            final unitPrice =
                                (item['unit_price'] as num?)?.toDouble() ?? 0.0;
                            final qty = (item['qty'] as num?)?.toInt() ?? 1;
                            final totalItemPrice = unitPrice * qty;
                            final productId = product['id']?.toString();

                            return InkWell(
                              onTap:
                                  productId != null
                                      ? () {
                                        context.push(
                                          '/product-detail/$productId',
                                        );
                                      }
                                      : null,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: const Color(
                                                    0xFFF9FAFB,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child:
                                                      product['image'] != null
                                                          ? Image.network(
                                                            'https://pos-v2-file.uat.camcyber.com/${product['image']}',
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) => const Icon(
                                                                  Icons
                                                                      .image_not_supported,
                                                                  color: Color(
                                                                    0xFF9CA3AF,
                                                                  ),
                                                                  size: 24,
                                                                ),
                                                          )
                                                          : const Icon(
                                                            Icons
                                                                .image_not_supported,
                                                            color: Color(
                                                              0xFF9CA3AF,
                                                            ),
                                                            size: 24,
                                                          ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            product['name'] ??
                                                                'Unknown',
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                  height: 1.2,
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 60,
                                                          child: Text(
                                                            '${NumberFormat("#,##0").format(unitPrice)} ៛',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color:
                                                                      HColors
                                                                          .grey,
                                                                ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // qty & Total Price
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '× $qty',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${NumberFormat("#,##0").format(totalItemPrice)} ៛',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: HColors.greenData,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 60,
                                            ),
                                            child: Divider(
                                              thickness: 1,
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'សរុប ៖ ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        color: HColors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${NumberFormat("#,##0").format(widget.transaction['total_price'] ?? 0)} ៛',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: HColors.greenData,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Add your download logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HColors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      child: const Text(
                                        'ទាញយក',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      if (!widget.isFullScreen && _isMinimized)
                        const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Blur effect below the button
        if (!widget.isFullScreen && _isMinimized)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 60,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(color: Colors.white.withOpacity(1.0)),
              ),
            ),
          ),
        // View More Button
        if (!widget.isFullScreen && _isMinimized)
          Positioned(
            bottom: 16,
            right: 16,
            child: TextButton(
              onPressed: () {
                _sheetController.animateTo(
                  0.9,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View More',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: HColors.blue,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: HColors.blue,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class FullScreenTransactionDetail extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const FullScreenTransactionDetail({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return TransactionDetailModal(transaction: transaction, isFullScreen: true);
  }
}
