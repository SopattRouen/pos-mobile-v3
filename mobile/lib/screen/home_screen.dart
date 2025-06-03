import 'dart:math';

import 'package:calendar/components/pei_chart.dart';
import 'package:calendar/components/skeleton.dart';
import 'package:calendar/entity/enum/e_variable.dart';
import 'package:calendar/entity/helper/colors.dart';
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:calendar/providers/local/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Future<void> _refreshData(HomeProvider provider) async {
    return await provider.getHome();
  }

  String formatDateToDDMMYY(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeProvider())],
      child: Consumer2<AuthProvider, HomeProvider>(
        builder: (context, authProvider, homeProvider, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: Colors.blue[800],
              backgroundColor: Colors.white,
              onRefresh: () => _refreshData(homeProvider),
              child:
                  homeProvider.isLoading
                      ? const Skeleton()
                      : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            UserProfileHeader(authProvider: authProvider),
                            if (homeProvider.data != null)
                              DashboardContent(
                                dashboardData: homeProvider.data!.data,
                              ),
                          ],
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}

String _getTimeBasedGreeting() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return 'អរុណសួស្ដី';
  } else if (hour >= 12 && hour < 17) {
    return 'សាយយ័ន្តសួស្ដី';
  } else if (hour >= 17 && hour < 21) {
    return 'Good Evening';
  } else {
    return 'Good Night';
  }
}

class DashboardContent extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  const DashboardContent({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryGrid(dashboardData: dashboardData),
     
        CashierList(cashierData: dashboardData['cashierData']['data'] ?? []),
        ProductTypeChart(
          productTypeData: dashboardData['productTypeData'] ?? {},
        ),
          StatisticChat (salesData: dashboardData['salesData'] ?? {},),
      ],
    );
  }
}

class UserProfileHeader extends StatefulWidget {
  final AuthProvider authProvider;

  const UserProfileHeader({super.key, required this.authProvider});

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
  String? userName;
  String? userAvatar;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  final greeting = _getTimeBasedGreeting();
  Future<void> _loadUserData() async {
    try {
      final name = await widget.authProvider.getUserName();
      final avatar = await widget.authProvider.getUserAvatar();
      final role = await widget.authProvider.getUserRole();

      if (mounted) {
        setState(() {
          userName = name ?? 'Unknown User';
          userAvatar = avatar;
          userRole = role ?? 'No Role';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userName = 'Unknown User';
          userRole = 'No Role';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // const SizedBox(width: 12),
          // User Profile
          Expanded(
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 12),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$userName",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userRole ?? 'No Role',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Row(
            children: [
              _IconButton(
                icon: Icons.download,
                onPressed: () {
                  // Add download functionality
                },
              ),
              const SizedBox(width: 8.0),
              _IconButton(
                icon: Icons.notifications,
                onPressed: () {
                  // Add notification functionality
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (userAvatar != null && userAvatar!.isNotEmpty) {
      // If avatar is a full URL
      if (userAvatar!.startsWith('http')) {
        return ClipOval(
          child: Container(
            color: HColors.darkgrey.withOpacity(0.1),
            child: Image.network(
              userAvatar!,
              width: 40.0,
              height: 40.0,

              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => _buildDefaultAvatar(),
            ),
          ),
        );
      } else {
        return ClipOval(
          child: Image.network(
            '$mainUrlFile$userAvatar', // Replace with your domain
            width: 40.0,
            height: 40.0,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
          ),
        );
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: HColors.darkgrey.withOpacity(0.5),
      ),
      child: const Center(
        child: Icon(Icons.person, size: 24.0, color: Colors.white),
      ),
    );
  }
}

class CategoryGrid extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  const CategoryGrid({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final statistic = dashboardData['statistic'] ?? {};

    final statisticItems = [
      {
        'label': 'ផលិតផល',
        'value': statistic['totalProduct']?.toString() ?? '0',
        'icon': Icons.category,
        'color': HColors.bluegrey,
      },
      {
        'label': 'ប្រភេទ',
        'value': statistic['totalProductType']?.toString() ?? '0',
        'icon': Icons.category,
        'color': HColors.green,
      },
      {
        'label': 'អ្នកប្រើប្រាស់',
        'value': statistic['totalUser']?.toString() ?? '0',
        'icon': Icons.groups_2_rounded,
        'color': HColors.darkgrey,
      },
      {
        'label': 'ការលក់',
        'value': statistic['totalOrder']?.toString() ?? '0',
        'icon': Icons.shopping_cart_rounded,
        'color': HColors.blueData,
      },
      // {
      //   'label': 'Total Revenue',
      //   'value':
      //       '\$${(statistic['total'] != null ? (statistic['total'] / 1000).toStringAsFixed(0) : '0')}K',
      //   'icon': Icons.attach_money,
      //   'color': Colors.teal,
      // },
      // {
      //   'label': 'Sales Change',
      //   'value': statistic['saleIncreasePreviousDay']?.toString() ?? '0%',
      //   'icon':
      //       statistic['saleIncreasePreviousDay']?.toString().startsWith('+') ??
      //               false
      //           ? Icons.trending_up
      //           : Icons.trending_down,
      //   'color':
      //       statistic['saleIncreasePreviousDay']?.toString().startsWith('+') ??
      //               false
      //           ? Colors.green
      //           : Colors.red,
      // },
    ];

    return Padding(
      padding: const EdgeInsets.all(15),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: statisticItems.length,
        itemBuilder: (context, index) {
          final item = statisticItems[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: HColors.darkgrey.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: item['color'] as Color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['label']!.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item['value']!.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          // color: item['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class ProductTypeChart extends StatelessWidget {
  final Map<String, dynamic> productTypeData;

  const ProductTypeChart({super.key, required this.productTypeData});

  @override
  Widget build(BuildContext context) {
    final labels = List<String>.from(productTypeData['labels'] ?? []);
    final dataValues = List<String>.from(productTypeData['data'] ?? []);

    if (labels.isEmpty || dataValues.isEmpty) {
      return const Center(child: Text('No product type data available'));
    }

    // Check if all values are zero
    final hasValidData = dataValues.any(
      (value) => double.tryParse(value) != null && double.parse(value) > 0,
    );

    if (!hasValidData) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products by Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Product type data will appear here once available',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Convert productTypeData to List<DonutPieData>
    final List<DonutPieData> chartData = List.generate(
      labels.length,
      (index) => DonutPieData(
        labels[index],
        double.tryParse(dataValues[index]) ?? 0,
        [
          HColors.blue,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
        ][index % 5],
      ),
    );

    // Calculate total value of actual data
    final totalValue = chartData.fold<double>(
      0,
      (sum, item) => sum + item.y,
    );

    // Add dummy section to make actual data occupy 50%
    if (totalValue > 0) {
      chartData.add(
        DonutPieData(
          'total',
          totalValue,
          Colors.grey[300]!, // Neutral color for dummy section
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ស្ថិតិប្រភេទផលិតផល',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 0), // Reduced from 50 to minimize gap
          SizedBox(
            height: 250, // Increased to accommodate chart and legend
            child: DonutPie(data: chartData),
          ),
        ],
      ),
    );
  }
}

class CashierList extends StatelessWidget {
  final List<dynamic> cashierData;

  const CashierList({super.key, required this.cashierData});

  @override
  Widget build(BuildContext context) {
    if (cashierData.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cashier Performance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(
            height: 120,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 50, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No cashier data available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'អ្នកគិតប្រាក់',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          SizedBox(height: 15),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cashierData.length,
            itemBuilder: (context, index) {
              final cashier = cashierData[index];
              final percentage =
                  double.tryParse(
                    cashier['percentageChange']?.toString() ?? '0',
                  ) ??
                  0;
              final avatarPath = cashier['avatar']?.toString() ?? '';
              final roleName =
                  cashier['role'] != null && cashier['role'].isNotEmpty
                      ? cashier['role'][0]['role']['name']?.toString() ??
                          'Unknown Role'
                      : 'Unknown Role';

              return Container(
                decoration: BoxDecoration(
                  color:
                      index % 2 == 0
                          ? HColors.darkgrey.withOpacity(0.05)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ), // Optional: for rounded corners
                ),
                margin: const EdgeInsets.symmetric(
                  vertical: 4.0,
                ), // Optional: spacing between items
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child:
                        avatarPath.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                avatarPath.startsWith('http')
                                    ? avatarPath
                                    : '$mainUrlFile$avatarPath',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                              ),
                            )
                            : const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    cashier['name']?.toString() ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                  subtitle: Text(
                    roleName,
                    style: TextStyle(
                      color: HColors.darkgrey,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '៛${cashier['totalAmount'] ?? 0} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          color: percentage >= 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget for icon button
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _IconButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: HColors.darkgrey.withOpacity(0.1),
        ),
        child: Center(child: Icon(icon, color: HColors.darkgrey, size: 24.0)),
      ),
    );
  }
}

class StatisticChat extends StatefulWidget {
  final Map<String, dynamic> salesData;

  const StatisticChat({super.key, required this.salesData});

  @override
  StatisticChatState createState() => StatisticChatState();
}

class StatisticChatState extends State<StatisticChat> {
  late final TooltipBehavior _tooltip = TooltipBehavior(enable: true);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final labels = List<String>.from(widget.salesData['labels'] ?? []);
    final dataValues = List<dynamic>.from(widget.salesData['data'] ?? []);

    // Convert salesData to List<ChartData>
    final List<ChartData> chartData = List.generate(
      labels.length,
      (index) => ChartData(
        labels[index],
        (dataValues[index] is String
                ? double.tryParse(dataValues[index]) ?? 0
                : dataValues[index]?.toDouble() ?? 0),
      ),
    );

    // Handle empty or no-data cases
    if (labels.isEmpty || dataValues.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales by Day',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sales data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sales data will appear here once available',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Check if all values are zero
    final hasValidData = chartData.any((data) => data.y > 0);

    if (!hasValidData) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales by Day',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No sales data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sales data will appear here once available',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Find the maximum value in the data
    double maxYValue = chartData.isNotEmpty
        ? chartData.map((data) => data.y).reduce(max)
        : 100; // Default value if the data list is empty

    // Ensure a positive interval
    double interval = maxYValue / 10;
    interval = interval > 0 ? interval : 100; // Fallback positive interval

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ស្ថិតិការលក់ប្រចាំសប្តាហ៍',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: const CategoryAxis(
                majorGridLines: MajorGridLines(width: 0), // Disable grid lines on X-axis
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                maximum: maxYValue,
                interval: interval,
                numberFormat: NumberFormat.currency(
                  locale: 'km',
                  symbol: '៛', // Use Cambodian Riel symbol
                  decimalDigits: 0,
                ),
              ),
              tooltipBehavior: _tooltip,
              series: <CartesianSeries<ChartData, String>>[
                ColumnSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  name: 'Sales',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    textStyle: TextStyle(
                      fontFamily: 'Kantumruy Pro',
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                  color: HColors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}