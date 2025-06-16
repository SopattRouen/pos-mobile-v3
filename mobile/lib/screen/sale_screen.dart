import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/providers/local/sale_provider.dart';
import 'package:calendar/shared/component/bottom_appbar.dart';
import 'package:calendar/shared/skeleton/sale_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _refreshData(SaleProvider provider) async {
    return await provider.getHome();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SaleProvider()..getHome(),
      child: Consumer<SaleProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'ការលក់',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.more_horiz, color: HColors.darkgrey),
                ),
              ],
              centerTitle: true,
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
                        ? SaleSkeleton()
                        : provider.error != null
                        ? Center(child: Text('Something went wrong'))
                        : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SafeArea(
                            child: Column(
                              children: [
                                // Header with balance
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
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        NumberFormat(
                                          "#,##0 ៛",
                                        ).format(provider.totalSales),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Transaction list
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                      provider.groupedTransactions.length,
                                  itemBuilder: (context, index) {
                                    final group =
                                        provider.groupedTransactions[index];
                                    return Column(
                                      children: [
                                        _buildDateSection(group['date']),
                                        ...group['transactions'].asMap().entries.map((
                                          entry,
                                        ) {
                                          final transaction = entry.value;
                                          final String avatarUrl =
                                              transaction['cashier']['avatar'] !=
                                                      null
                                                  ? 'https://pos-v2-file.uat.camcyber.com/${transaction['cashier']['avatar']}'
                                                  : '';
                                          return _buildTransactionItem(
                                            transaction['receipt_number'],
                                            NumberFormat("#,##0 ៛").format(
                                              transaction['total_price'],
                                            ),
                                            avatarUrl,
                                            transaction['id'], // Pass the transaction ID
                                            provider, // Pass the provider
                                          );
                                        }).toList(),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSection(String date) {
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

  Widget _buildTransactionItem(
    String transactionId,
    String amount,
    String avatarUrl,
    int id,
    SaleProvider provider,
  ) {
    return Dismissible(
      key: Key(id.toString()), // Unique key for each transaction
      direction: DismissDirection.endToStart, // Swipe left to delete
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('លុបការវិក្ក័យបត្រ'),
                    content: const Text('តើអ្នកប្រាកដថាចង់លុបមែនទេ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('បិត'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'បាទ/ចាស',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        // Call deleteSale when confirmed
        await provider.deleteSale(id);
        if (provider.error != null) {
          // Show error if deletion fails
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(provider.error!)));
          // Optionally restore the item if deletion fails
          provider.getHome(); // Refresh data to restore state
        } else {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sale deleted successfully')),
          );
        }
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
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
            // Transaction ID
            Text(
              transactionId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: HColors.darkgrey,
              ),
            ),
            const Spacer(),
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
      ),
    );
  }
}
