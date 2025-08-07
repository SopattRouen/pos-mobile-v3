// =======================>> Dart Core
import 'dart:math';
import 'dart:math' as math;

// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// =======================>> Providers Components
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:calendar/providers/local/home_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/entity/enum/e_variable.dart';
import 'package:calendar/shared/entity/helper/colors.dart';
import 'package:calendar/shared/skeleton/home_skeleton.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
    return Consumer2<AuthProvider, HomeProvider>(
      builder: (context, authProvider, homeProvider, child) {
        return ScaffoldMessenger(
          key: _scaffoldMessengerKey,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                color: Colors.blue[800],
                backgroundColor: Colors.white,
                onRefresh: () => _refreshData(homeProvider),
                child:
                    homeProvider.isLoading
                        ? const HomeSkeleton()
                        : homeProvider.error != null
                        ? Center(child: Text('Something went wrong'))
                        : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              UserProfileHeader(
                                authProvider: authProvider,
                                scaffoldMessengerKey: _scaffoldMessengerKey,
                              ),
                              if (homeProvider.data != null)
                                DashboardContent(
                                  dashboardData: homeProvider.data!.data,
                                ),
                            ],
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
        StatisticChat(salesData: dashboardData['salesData'] ?? {}),
      ],
    );
  }
}

class UserProfileHeader extends StatefulWidget {
  final AuthProvider authProvider;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const UserProfileHeader({
    super.key,
    required this.authProvider,
    required this.scaffoldMessengerKey,
  });

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

  Future<void> _loadUserData() async {
    try {
      final name = await widget.authProvider.getUserName();
      final avatar = await widget.authProvider.getUserAvatar();
      final role = await widget.authProvider.getUserRole();

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
    final roles = await widget.authProvider.getAllRoles();
    final currentRole = await widget.authProvider.getCurrentRole();
    final currentRoleId = currentRole?['id'].toString();

    if (roles == null || roles.isEmpty) {
      widget.scaffoldMessengerKey.currentState?.showSnackBar(
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
                    // print("✅ Bottom sheet dismissed");

                    final navigator = Navigator.of(context);
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (ctx) => Center(child: CircularProgressIndicator()),
                    ).then((_) => print("✅ Loading dialog closed"));

                    try {
                      await widget.authProvider.switchRoleApi(
                        defRoleId: currentRoleId ?? '',
                        swRoleId: role['id'].toString(),
                      );

                      navigator.pop(); // Dismiss dialog
                      // print("✅ Loading dialog dismissed");

                      // Always refresh user data after switch attempt to sync with the latest token
                      await _loadUserData();

                      // final updatedRole =
                      //     await widget.authProvider.getCurrentRole();
                      // final message =
                      //     roleId == updatedRole?['id'].toString()
                      //         ? 'Switched to ${role['name']}'
                      //         : '${role['name']} is already the current role';
                      // widget.scaffoldMessengerKey.currentState?.showSnackBar(
                      //   SnackBar(content: Text(message)),
                      // );
                      // print("✅ SnackBar shown: $message");
                      // print(
                      //   "🔍 Updated current role: ${updatedRole?['name']} (ID: ${updatedRole?['id']})",
                      // );
                    } catch (e) {
                      navigator.pop(); // Dismiss dialog
                      // print("✅ Loading dialog dismissed on error");

                      // widget.scaffoldMessengerKey.currentState?.showSnackBar(
                      //   SnackBar(content: Text('Failed to switch role: $e')),
                      // );
                      // print("❌ Error SnackBar shown: $e");
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
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,

      // leadingWidth: 150,
      leading: Padding(
        padding: const EdgeInsets.all(2),
        child: Stack(
          // alignment: Alignment.centerLeft,
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
      title: Text("ប្រព័ន្ធគ្រប់គ្រងការលក់", style: TextStyle(fontSize: 18)),
      centerTitle: true,

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: showBottomSwitchRole,
            child: Row(children: [_buildAvatar()]),
          ),
        ),
      ],
    );
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

  // String _getTimeBasedGreeting() {
  //   final hour = DateTime.now().hour;

  //   if (hour >= 5 && hour < 12) {
  //     return 'អរុណសួស្ដី,';
  //   } else if (hour >= 12 && hour < 17) {
  //     return 'សាយយ័ន្តសួស្ដី,';
  //   } else if (hour >= 17 && hour < 21) {
  //     return 'សាយយ័ន្តសួស្ដី,';
  //   } else {
  //     return 'រាត្រីសួរស្ដី,';
  //   }
  // }
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
                              color: HColors.darkgrey,
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

    // Convert productTypeData to chart data
    final List<MapEntry<String, double>> chartData = List.generate(
      labels.length,
      (index) =>
          MapEntry(labels[index], double.tryParse(dataValues[index]) ?? 0),
    );

    // Calculate total value
    final totalValue = chartData.fold<double>(
      0,
      (sum, item) => sum + item.value,
    );

    final colors = [HColors.blue, Colors.green, Colors.teal, Colors.purple];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ស្ថិតិប្រភេទផលិតផល',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: 25),
          SizedBox(
            child: Column(
              children: [
                // Half circle showing combined data as segments
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background half circle
                      CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 28.0,
                        percent: 1.0,
                        progressColor: Colors.grey[200]!,
                        backgroundColor: Colors.transparent,
                        circularStrokeCap: CircularStrokeCap.butt,
                        startAngle: 180.0,
                        arcType: ArcType.HALF,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${totalValue.toInt()} ទាំងអស់',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 25),
                            // Legend with dots
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              alignment: WrapAlignment.center,
                              children: List.generate(chartData.length, (
                                index,
                              ) {
                                final item = chartData[index];

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: colors[index % colors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${item.key} (${item.value.toInt()})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      // Segments for each product type
                      ...(() {
                        double cumulativePercent = 0;
                        return chartData.map((item) {
                          final itemPercent =
                              totalValue > 0 ? (item.value / totalValue) : 0;
                          final segmentStart = cumulativePercent;
                          cumulativePercent += itemPercent;

                          final index = chartData.indexOf(item);

                          return Transform.rotate(
                            angle:
                                segmentStart *
                                math.pi, // Rotate based on cumulative percentage
                            child: CircularPercentIndicator(
                              radius: 100.0,
                              lineWidth: 28.0,
                              percent: itemPercent.toDouble(),
                              progressColor: colors[index % colors.length],
                              backgroundColor: Colors.transparent,
                              circularStrokeCap: CircularStrokeCap.butt,
                              startAngle: 180.0,
                              arcType: ArcType.HALF,
                            ),
                          );
                        }).toList();
                      })(),
                      // Center text showing total
                      // Positioned(
                      //   bottom: 15,
                      //   child:
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class HalfCircleSegmentPainter extends CustomPainter {
//   final List<MapEntry<String, double>> data;
//   final List<Color> colors;
//   final double totalValue;

//   HalfCircleSegmentPainter({
//     required this.data,
//     required this.colors,
//     required this.totalValue,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height);
//     final radius = size.width / 2 - 10;
//     final strokeWidth = 20.0;

//     double startAngle = math.pi; // Start from left (180 degrees)

//     for (int i = 0; i < data.length; i++) {
//       final item = data[i];
//       final sweepAngle =
//           (item.value / totalValue) * math.pi; // Half circle is π radians

//       final paint =
//           Paint()
//             ..color = colors[i % colors.length]
//             ..style = PaintingStyle.stroke
//             ..strokeWidth = strokeWidth
//             ..strokeCap = StrokeCap.round;

//       final rect = Rect.fromCircle(center: center, radius: radius);

//       canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

//       startAngle += sweepAngle;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: HColors.darkgrey.withOpacity(0.1),
          ),
          child: Center(child: Icon(icon, color: HColors.darkgrey, size: 24.0)),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
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
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
    double maxYValue =
        chartData.isNotEmpty
            ? chartData.map((data) => data.y).reduce(max)
            : 100; // Default value if the data list is empty

    // Ensure a positive interval
    double interval = maxYValue / 10;
    interval = interval > 0 ? interval : 100; // Fallback positive interval

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                majorGridLines: MajorGridLines(
                  width: 0,
                ), // Disable grid lines on X-axis
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
