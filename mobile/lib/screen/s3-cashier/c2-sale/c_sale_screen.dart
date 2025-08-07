// =======================>> Flutter Core
import 'package:calendar/screen/s3-cashier/c2-sale/detail_sale_screen.dart';
import 'package:calendar/shared/component/show_bottom_sheet.dart';
import 'package:calendar/shared/skeleton/c_sale_skeleton.dart';
import 'package:flutter/material.dart';

// =======================>> Third-Party Packages
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// =======================>> Providers
import 'package:calendar/providers/local/sale_provider.dart';

// =======================>> Shared Components & Helpers
import 'package:calendar/shared/entity/helper/colors.dart';

class CashierSaleScreen extends StatefulWidget {
  const CashierSaleScreen({super.key});

  @override
  State<CashierSaleScreen> createState() => _CashierSaleScreenState();
}

class _CashierSaleScreenState extends State<CashierSaleScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isFilterRowVisible = false;
  String? _searchQuery;
  String? _platform;
  String? _startDate;
  String? _endDate;
  int _sortValue = 1;

  Future<void> _refreshData(SaleProvider provider) async {
    await provider.getDataCashier(
      from: _startDate,
      to: _endDate,
      platform: _platform,
      key: _searchQuery, // This should now work
      sort: _sortValue == 2 ? 'total_price' : 'ordered_at',
      order: 'DESC',
    );
  }

  void _setDateRange(int value) {
    final now = DateTime.now();
    String? start;
    String? end;

    switch (value) {
      case 1: // All
        start = null;
        end = null;
        break;
      case 2: // Today
        start = DateFormat('yyyy-MM-dd').format(now);
        end = start;
        break;
      case 3: // This Week
        start = DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(Duration(days: now.weekday - 1)));
        end = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 4: // This Month
        start = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(now.year, now.month, 1));
        end = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 5: // Last 3 Months
        start = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(now.year, now.month - 3, 1));
        end = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 6: // Last 6 Months
        start = DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime(now.year, now.month - 6, 1));
        end = DateFormat('yyyy-MM-dd').format(now);
        break;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _refreshData(Provider.of<SaleProvider>(context, listen: false));
  }

  void _showTransactionDetails(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    showCustomBottomSheet(
      context: context,
      builder: (context) => TransactionDetailModal(transaction: transaction),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.black.withOpacity(0.0),
      useRootNavigator: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? HColors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? HColors.blue : HColors.grey.withOpacity(0.4),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? HColors.blue : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isActive ? HColors.blue : HColors.darkgrey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
                if (_isFilterRowVisible) {
                  setState(() {
                    _isFilterRowVisible = false;
                    // Reset all filters to default values
                    _platform = null;
                    _searchQuery = null;
                    _startDate = null;
                    _endDate = null;
                    _sortValue = 1;
                  });
                  // Refresh data with cleared filters
                  _refreshData(provider);
                }
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: HColors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: HColors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          height: 50,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_outlined,
                                color: HColors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'ស្វែងរក',
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: HColors.darkgrey,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: HColors.darkgrey,
                                    fontSize: 16,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery =
                                          value.isEmpty ? null : value;
                                    });
                                    _refreshData(provider);
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isFilterRowVisible = !_isFilterRowVisible;
                                  });
                                },
                                child: Icon(
                                  _isFilterRowVisible
                                      ? Icons.filter_list_off
                                      : Icons.filter_list_sharp,
                                  color: HColors.grey,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: _isFilterRowVisible,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showCustomBottomSheet(
                                        context: context,
                                        builder:
                                            (context) => SortOptionsSheet(
                                              headerTitle: 'តម្រៀបដោយ',
                                              options: [
                                                SortOption(
                                                  label: 'កាលបរិច្ឆេទ',
                                                  icon:
                                                      Icons
                                                          .calendar_today_outlined,
                                                  value: 1,
                                                ),
                                                SortOption(
                                                  label: 'តម្លៃលក់(រៀល)',
                                                  icon: Icons.money_outlined,
                                                  value: 2,
                                                ),
                                              ],
                                              initialSelectedValue: _sortValue,
                                              onOptionSelected: (value) {
                                                setState(() {
                                                  _sortValue = value;
                                                });
                                                _refreshData(provider);
                                              },
                                            ),
                                        useRootNavigator: true,
                                      );
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: HColors.grey.withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.swap_vert,
                                        color: HColors.grey,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterButton(
                                    _platform == null
                                        ? 'ឧបករណ៍'
                                        : _platform == 'Web'
                                        ? 'តាមរយៈកុំព្យូទ័រ'
                                        : 'តាមរយៈទូរស័ព្ទ',
                                    () {
                                      showCustomBottomSheet(
                                        context: context,
                                        builder:
                                            (context) => SortOptionsSheet(
                                              headerTitle: 'ឧបករណ៍',
                                              options: [
                                                SortOption(
                                                  label: 'ទាំងអស់',
                                                  icon: Icons.devices,
                                                  value: 1,
                                                ),
                                                SortOption(
                                                  label: 'តាមរយៈកុំព្យូទ័រ',
                                                  icon: Icons.monitor,
                                                  value: 2,
                                                ),
                                                SortOption(
                                                  label: 'តាមរយៈទូរស័ព្ទ',
                                                  icon: Icons.phone_android,
                                                  value: 3,
                                                ),
                                              ],
                                              initialSelectedValue:
                                                  _platform == null
                                                      ? 1
                                                      : _platform == 'Web'
                                                      ? 2
                                                      : 3,
                                              onOptionSelected: (value) {
                                                setState(() {
                                                  _platform =
                                                      value == 1
                                                          ? null
                                                          : value == 2
                                                          ? 'Web'
                                                          : 'Mobile';
                                                });
                                                _refreshData(provider);
                                              },
                                            ),
                                        useRootNavigator: true,
                                      );
                                    },
                                    isActive:
                                        _platform !=
                                        null, // This will highlight when a specific platform is selected
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterButton('កាលបរិច្ឆេទ', () {
                                    showCustomBottomSheet(
                                      context: context,
                                      builder:
                                          (context) => SortOptionsSheet(
                                            headerTitle: 'កាលបរិច្ឆេទ',
                                            options: [
                                              SortOption(
                                                label: 'ទាំងអស់',
                                                icon: Icons.event,
                                                value: 1,
                                              ),
                                              SortOption(
                                                label: 'ថ្ងៃនេះ',
                                                icon: Icons.today,
                                                value: 2,
                                              ),
                                              SortOption(
                                                label: 'សប្តាហ៍នេះ',
                                                icon: Icons.today,
                                                value: 3,
                                              ),
                                              SortOption(
                                                label: 'ខែនេះ',
                                                icon: Icons.today,
                                                value: 4,
                                              ),
                                              SortOption(
                                                label: '3 ខែមុន',
                                                icon: Icons.today,
                                                value: 5,
                                              ),
                                              SortOption(
                                                label: '6 ខែមុន',
                                                icon: Icons.today,
                                                value: 6,
                                              ),
                                            ],
                                            initialSelectedValue:
                                                _startDate == null ? 1 : 2,
                                            onOptionSelected: _setDateRange,
                                          ),
                                      useRootNavigator: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      color: Colors.blue[800],
                      backgroundColor: Colors.white,
                      onRefresh: () => _refreshData(provider),
                      child:
                          provider.isLoading
                              ? const CSaleSkeleton()
                              : provider.error != null
                              ? const Center(
                                child: Text('Something went wrong'),
                              )
                              : provider.groupedTransactions.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: provider.groupedTransactions.length,
                                itemBuilder: (context, index) {
                                  final group =
                                      provider.groupedTransactions[index];
                                  return Column(
                                    children: [
                                      _buildDateHeader(group['date']),
                                      ...group['transactions']
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final transaction = entry.value;
                                            final DateTime orderedAt =
                                                DateTime.parse(
                                                  transaction['ordered_at'],
                                                ).toLocal();
                                            final String formattedDate =
                                                DateFormat(
                                                  'dd-MM-yyyy',
                                                ).format(orderedAt);
                                            final String formattedTime =
                                                DateFormat(
                                                  'hh:mm a',
                                                ).format(orderedAt);
                                            return _buildTransactionItem(
                                              '#${transaction['receipt_number']}',
                                              formattedDate,
                                              formattedTime,
                                              NumberFormat("#,##0 ៛").format(
                                                transaction['total_price'],
                                              ),
                                              transaction['platform'],
                                              transaction['id'],
                                              transaction,
                                              provider,
                                            );
                                          })
                                          .toList(),
                                    ],
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: HColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'គ្មានវិក្ក័យបត្រទេ',
            style: TextStyle(
              fontSize: 16,
              color: HColors.darkgrey.withOpacity(0.7),
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
    String date,
    String time,
    String amount,
    String platform,
    int id,
    Map<String, dynamic> fullTransaction,
    SaleProvider provider,
  ) {
    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('លុបការវិក្ក័យបត្រ'),
                    content: const Text('តើអ្នកប្រាកដថាចង់លុបមែនទេ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('បិទ'),
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
        await provider.deleteSale(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('បានលុប $transactionId')));
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          _showTransactionDetails(context, fullTransaction);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: HColors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$date • $time',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: HColors.greenData,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      platform == 'Mobile'
                          ? Icons.phone_android_outlined
                          : Icons.monitor,
                      color: HColors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 40),
                child: Divider(
                  thickness: 1,
                  color: Color(0xFFE5E5E5),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SortOption {
  final String label;
  final IconData icon;
  final int value;

  SortOption({required this.label, required this.icon, required this.value});
}

class SortOptionsSheet extends StatefulWidget {
  final String headerTitle;
  final List<SortOption> options;
  final int initialSelectedValue;
  final Function(int) onOptionSelected;

  const SortOptionsSheet({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.initialSelectedValue,
    required this.onOptionSelected,
  });

  @override
  State<SortOptionsSheet> createState() => _SortOptionsSheetState();
}

class _SortOptionsSheetState extends State<SortOptionsSheet> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.headerTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.options.map((option) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(option.icon, color: HColors.darkgrey),
              title: Text(option.label),
              trailing:
                  _selectedValue == option.value
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
              onTap: () {
                setState(() {
                  _selectedValue = option.value;
                });
                widget.onOptionSelected(_selectedValue);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}
