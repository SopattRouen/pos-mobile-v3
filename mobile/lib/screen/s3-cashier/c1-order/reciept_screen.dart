import 'package:calendar/providers/local/order_provider.dart';
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/entity/helper/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecieptScreen extends StatefulWidget {
  final String? orderId;
  final List<Map<String, dynamic>>? cartItems;
  final double? totalAmount;
  final Map<String, dynamic>? orderResponse;

  const RecieptScreen({
    super.key,
    this.orderId,
    this.cartItems,
    this.totalAmount,
    this.orderResponse,
  });

  @override
  State<RecieptScreen> createState() => _RecieptScreenState();
}

class _RecieptScreenState extends State<RecieptScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            title: const Text('វិក្ក័យបត្រ'),
            bottom: CustomHeader(),
          ),
          body: SafeArea(
            child: TicketCard(
              title: "បញ្ជាទិញបានជោគជ័យ",
              orderId: widget.orderId,
              cartItems: widget.cartItems,
              totalAmount: widget.totalAmount,
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child:
                  isLoading
                      ? null
                      : ElevatedButton(
                        onPressed: () {
                          homeProvider.getHome();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HColors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'រួចរាល់',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
            ),
          ),
        );
      },
    );
  }
}

class TicketCard extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final bool? isMockLocation;
  final String? address;
  final String title;
  final String? orderId;
  final List<Map<String, dynamic>>? cartItems;
  final double? totalAmount;

  const TicketCard({
    super.key,
    this.latitude,
    this.longitude,
    this.isMockLocation,
    this.address,
    required this.title,
    this.orderId,
    this.cartItems,
    this.totalAmount,
  });

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  bool isClick = false;
  bool isClickImage = false;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now().toUtc().add(const Duration(hours: 7));
    final formattedDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(date);

    return Scaffold(
      backgroundColor: HColors.darkgrey.withOpacity(0.1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                const Icon(Icons.check_circle, size: 70, color: HColors.green),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: HColors.blue,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'KantumruyPro',
                  ),
                ),
                if (widget.isMockLocation == true) ...[
                  const SizedBox(height: 10),
                  const Text(
                    "Warning: Mock location detected. Location may not be accurate.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                      fontFamily: 'KantumruyPro',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Cart Items Section
                      if (widget.cartItems != null &&
                          widget.cartItems!.isNotEmpty) ...[
                        // const Text(
                        //   "បញ្ជីទំនិញ",
                        //   style: TextStyle(
                        //     fontSize: 16,
                        //     fontWeight: FontWeight.w500,
                        //     color: HColors.blue,
                        //     fontFamily: 'KantumruyPro',
                        //   ),
                        // ),
                        // const SizedBox(height: 10),

                        // Items List
                        ...widget.cartItems!
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name and code
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'x${item['quantity'] ?? 1}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'KantumruyPro',
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        item['name'] ??
                                                            'Unknown Product',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'KantumruyPro',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    '${NumberFormat('#,##0').format(item['total_price'] ?? 0)}៛',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily:
                                                          'KantumruyPro',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // if (item['code'] != null) ...[
                                              //   const SizedBox(height: 2),
                                              //   Text(
                                              //     'កូដ: ${item['code']}',
                                              //     style: const TextStyle(
                                              //       fontSize: 12,
                                              //       color: HColors.darkgrey,
                                              //       fontFamily: 'Kantumruy Pro',
                                              //     ),
                                              //   ),
                                              // ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // const SizedBox(height: 4),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.end,
                                    //   children: [

                                    //   ],
                                    // ),
                                    // Unit price and total
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'តម្លៃ: ${NumberFormat('#,##0').format(item['unit_price'] ?? 0)}៛',
                                    //       style: const TextStyle(
                                    //         fontSize: 12,
                                    //         color: HColors.darkgrey,
                                    //         fontFamily: 'Kantumruy Pro',
                                    //       ),
                                    //     ),
                                    // Text(
                                    //   '${NumberFormat('#,##0').format(item['total_price'] ?? 0)}៛',
                                    //   style: const TextStyle(
                                    //     fontSize: 14,
                                    //     fontWeight: FontWeight.w500,
                                    //     fontFamily: 'KantumruyPro',
                                    //   ),
                                    // ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),

                        const SizedBox(height: 15),
                        CustomPaint(
                          painter: DashedLinePainter(),
                          child: Container(),
                        ),
                        const SizedBox(height: 15),
                      ],

                      // Total Amount Section
                      if (widget.cartItems != null &&
                          widget.cartItems!.isNotEmpty) ...[
                        // Calculate total from cart items
                        Builder(
                          builder: (context) {
                            double calculatedTotal = 0;
                            int totalItems = 0;

                            for (var item in widget.cartItems!) {
                              calculatedTotal +=
                                  (item['total_price'] ?? 0).toDouble();
                              totalItems += (item['quantity'] ?? 1) as int;
                            }

                            return Column(
                              children: [
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     const Text(
                                //       "ចំនួនទំនិញសរុប",
                                //       style: TextStyle(
                                //         fontSize: 14,
                                //         color: HColors.darkgrey,
                                //         fontFamily: 'Kantumruy Pro',
                                //       ),
                                //     ),
                                //     Text(
                                //       '$totalItems មុខ',
                                //       style: const TextStyle(
                                //         fontSize: 14,
                                //         fontWeight: FontWeight.w500,
                                //         fontFamily: 'Kantumruy Pro',
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "សរុប",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: HColors.blue,
                                        fontFamily: 'KantumruyPro',
                                      ),
                                    ),
                                    Text(
                                      '${NumberFormat('#,##0').format(calculatedTotal)}៛',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: HColors.blue,
                                        fontFamily: 'KantumruyPro',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        // const SizedBox(height: 15),
                        // CustomPaint(
                        //   painter: DashedLinePainter(),
                        //   child: Container(),
                        // ),
                        const SizedBox(height: 15),
                      ],

                      // Date and Time Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "កាលបរិច្ឆេទ",
                            style: TextStyle(
                              fontSize: 12,
                              color: HColors.darkgrey,
                              fontFamily: 'Kantumruy Pro',
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 10,
                              color: HColors.darkgrey,
                              fontFamily: 'Kantumruy Pro',
                            ),
                          ),
                        ],
                      ),

                      // // Payment Status (if available in orderResponse)
                      // if (widget.orderResponse != null && widget.orderResponse!['payment_status'] != null) ...[
                      //   const SizedBox(height: 15),
                      //   CustomPaint(
                      //     painter: DashedLinePainter(),
                      //     child: Container(),
                      //   ),
                      //   const SizedBox(height: 15),
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       const Text(
                      //         "ស្ថានភាពការទូទាត់",
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           color: HColors.darkgrey,
                      //           fontFamily: 'Kantumruy Pro',
                      //         ),
                      //       ),
                      //       Text(
                      //         widget.orderResponse!['payment_status'] ?? 'បានជោគជ័យ',
                      //         style: const TextStyle(
                      //           fontSize: 12,
                      //           color: HColors.green,
                      //           fontWeight: FontWeight.bold,
                      //           fontFamily: 'Kantumruy Pro',
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ],
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      splashColor: HColors.darkgrey,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          HColors.darkgrey.withOpacity(0.1),
                        ),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.download),
                    ),
                    IconButton(
                      splashColor: HColors.darkgrey,
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          HColors.darkgrey.withOpacity(0.1),
                        ),
                      ),
                      onPressed: () {},
                      icon: Icon(Icons.share),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InvoiceTextWidget extends StatelessWidget {
  final String text;
  final IconData? icons;
  final VoidCallback? onTap;
  final IconData leadIcon;

  const InvoiceTextWidget({
    super.key,
    required this.text,
    this.icons,
    this.onTap,
    required this.leadIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Row(
                children: [
                  Icon(leadIcon, color: HColors.darkgrey),
                  const SizedBox(width: 5),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Kantumruy Pro',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        if (icons != null) InkWell(onTap: onTap, child: Icon(icons, size: 18)),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
