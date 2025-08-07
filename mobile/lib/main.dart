// =======================>> Flutter Core
import 'package:calendar/screen/s1-account/profile/update_password_screen.dart';
import 'package:calendar/screen/s1-account/profile/update_profile_screen.dart';
import 'package:calendar/screen/s3-cashier/c2-sale/c_sale_screen.dart';
import 'package:flutter/material.dart';

// =======================>> Third-Party Packages
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// =======================>> App Routes
import 'package:calendar/app_routes.dart';

// =======================>> Middleware
import 'package:calendar/middleware/auth_middleware.dart';
import 'package:calendar/middleware/network_middleware.dart';

// =======================>> Services & Utilities
import 'package:calendar/services/network_service.dart';
import 'package:calendar/utils/dio.client.dart';

// =======================>> Providers - Global
import 'package:calendar/providers/global/auth_provider.dart';
import 'package:calendar/providers/global/network_provider.dart';
import 'package:calendar/providers/global/setting_provider.dart';

// =======================>> Providers - Local
import 'package:calendar/providers/local/home_provider.dart';
import 'package:calendar/providers/local/order_provider.dart';
import 'package:calendar/providers/local/product/create_product_provider.dart';
import 'package:calendar/providers/local/product_provider.dart';
import 'package:calendar/providers/local/product_type_provider.dart';
import 'package:calendar/providers/local/sale_provider.dart';

// =======================>> Shared Helpers & Components
import 'package:calendar/shared/entity/helper/colors.dart';

// =======================>> Screens - Account
import 'package:calendar/screen/s1-account/login_screen.dart';
import 'package:calendar/screen/s1-account/profile_screen_2.dart';

// =======================>> Screens - Admin
import 'package:calendar/screen/s2-admin/a1-home/home_screen.dart';
import 'package:calendar/screen/s2-admin/a2-product/product/create_product_screen.dart';
import 'package:calendar/screen/s2-admin/a2-product/product/detail_product.dart';
import 'package:calendar/screen/s2-admin/a2-product/product/update_product_screen.dart';
import 'package:calendar/screen/s2-admin/a2-product/product_screen.dart';
import 'package:calendar/screen/s2-admin/a2-product/product_type/create_product_type_screen.dart';
import 'package:calendar/screen/s2-admin/a2-product/product_type/update_product_type_screen.dart';
import 'package:calendar/screen/s2-admin/a2-product/product_type_screen.dart';
import 'package:calendar/screen/s2-admin/a3-sale/sale_screen.dart';

// =======================>> Screens - Cashier
import 'package:calendar/screen/s3-cashier/c1-order/order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  await dotenv.load(fileName: '.env.$flavor');

  // Validate required variables
  final requiredVars = ['APP_NAME', 'API_URL', 'API_KEY'];
  for (var variable in requiredVars) {
    if (!dotenv.env.containsKey(variable)) {
      throw Exception('$variable is not set in .env.$flavor');
    }
  }

  final networkService = NetworkService();
  final networkProvider = NetworkProvider(networkService: networkService);
  await networkProvider.initialize();

  runApp(
    // ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CreateProductProvider()),
        ChangeNotifierProvider(create: (_) => ProductTypeProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),

        ChangeNotifierProvider.value(value: networkProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    DioClient.setupInterceptors(context);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      builder: (context, child) {
        // return NetworkAwareWidget(
        //   showBanner: true,
        //   bannerDuration: const Duration(seconds: 4),
        //   child: child!,
        // );
        return NetworkMiddleware(child: child!);
      },
      theme: ThemeData(
        fontFamily: 'KantumruyPro',
        primaryColor: const Color(0xFF002458),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF002458),
          secondary: HColors.blue,
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontFamily: 'KantumruyPro',
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: HColors.blue,
          unselectedItemColor: HColors.darkgrey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          elevation: 0,
        ),
      ),
    );
  }
}

// Abstract base class for common layout functionality
abstract class BaseMainLayout extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRoleChanged;

  const BaseMainLayout({required this.child, this.onRoleChanged, super.key});
}

// Admin Main Layout
class AdminMainLayout extends BaseMainLayout {
  const AdminMainLayout({required super.child, super.onRoleChanged, super.key});

  @override
  State<AdminMainLayout> createState() => _AdminMainLayoutState();
}

class _AdminMainLayoutState extends State<AdminMainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              _showAddRequestBottomSheet(context);
              return;
            }

            setState(() => _currentIndex = index);

            switch (index) {
              case 0:
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.sale);
                break;
              case 3:
                context.go(AppRoutes.product);
                break;
              case 4:
                context.go(AppRoutes.profile);
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home, 0),
              activeIcon: _buildNavIcon(Icons.home, 0, active: true),
              label: 'ទំព័រដើម',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.shopping_cart, 1),
              activeIcon: _buildNavIcon(Icons.shopping_cart, 1, active: true),
              label: 'ការលក់',
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () => _showAddRequestBottomSheet(context),
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: HColors.blue,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 28.0,
                    color: HColors.yellow,
                  ),
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.category_rounded, 3),
              activeIcon: _buildNavIcon(
                Icons.category_rounded,
                3,
                active: true,
              ),
              label: 'ផលិតផល',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 4),
              activeIcon: _buildNavIcon(Icons.person, 4, active: true),
              label: 'គណនី',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRequestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.0)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetOption(
              icon: Icons.category_rounded,
              label: 'ផលិតផល',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.createProduct);
              },
            ),
            _buildBottomSheetOption(
              icon: Icons.category_rounded,
              label: 'ប្រភេទផលិតផល',
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.createProductType);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, size: 24.0, color: HColors.darkgrey),
              ),
              const SizedBox(width: 12.0),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      child: Icon(
        icon,
        size: 28.0,
        color:
            active && _currentIndex == index
                ? Theme.of(context).colorScheme.secondary
                : HColors.darkgrey,
      ),
    );
  }
}

// Cashier Main Layout
class CashierMainLayout extends BaseMainLayout {
  const CashierMainLayout({
    required super.child,
    super.onRoleChanged,
    super.key,
  });

  @override
  State<CashierMainLayout> createState() => _CashierMainLayoutState();
}

class _CashierMainLayoutState extends State<CashierMainLayout> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentPath = GoRouterState.of(context).uri.path;
      // print('CashierMainLayout: Current path = $currentPath, isCashierRoute = ${_isCashierRoute(currentPath)}');
      if (!_isCashierRoute(currentPath)) {
        // print('CashierMainLayout: Redirecting to ${AppRoutes.order}');
        context.go(AppRoutes.order);
        setState(() => _currentIndex = 0);
      }
    });
  }

  bool _isCashierRoute(String path) {
    return [
      AppRoutes.order,
      AppRoutes.cashierSale,
      AppRoutes.profile,
    ].contains(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);

            switch (index) {
              case 0:
                context.go(AppRoutes.order);
                break;
              case 1:
                context.go(AppRoutes.cashierSale);
                break;
              case 2:
                context.go(AppRoutes.profile);
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.point_of_sale_outlined, 0),
              activeIcon: _buildNavIcon(Icons.point_of_sale, 0, active: true),
              label: 'បញ្ជាទិញ',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.shopping_cart, 1),
              activeIcon: _buildNavIcon(Icons.shopping_cart, 1, active: true),
              label: 'ការលក់',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 2),
              activeIcon: _buildNavIcon(Icons.person, 2, active: true),
              label: 'គណនី',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool active = false}) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      child: Icon(
        icon,
        size: 28.0,
        color:
            active && _currentIndex == index
                ? Theme.of(context).colorScheme.secondary
                : HColors.darkgrey,
      ),
    );
  }
}

// MainLayout to handle role-based layout selection
class MainLayout extends StatefulWidget {
  final Widget child;
  final VoidCallback? onRoleChanged;

  const MainLayout({required this.child, this.onRoleChanged, super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = await authProvider.isAdmin();
    // print('MainLayout: Initial isAdmin = $isAdmin');
    setState(() {
      _isAdmin = isAdmin;
      _isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToRoleHome(context);
    });
  }

  Future<void> refreshAdminStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = await authProvider.isAdmin();
    // print('MainLayout: Refresh isAdmin = $isAdmin');
    setState(() {
      _isAdmin = isAdmin;
    });
    _navigateToRoleHome(context);
    if (widget.onRoleChanged != null) {
      widget.onRoleChanged!();
    }
  }

  void _checkAdminStatusIfNeeded() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentAdminStatus = await authProvider.isAdmin();
    if (currentAdminStatus != _isAdmin) {
      // print('MainLayout: Role changed to isAdmin = $currentAdminStatus');
      setState(() {
        _isAdmin = currentAdminStatus;
      });
      _navigateToRoleHome(context);
      if (widget.onRoleChanged != null) {
        widget.onRoleChanged!();
      }
    }
  }

  void _navigateToRoleHome(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    // print('MainLayout: Current path = $currentPath, isAdmin = $_isAdmin');
    if (_isAdmin && !_isAdminRoute(currentPath)) {
      // print('MainLayout: Redirecting to ${AppRoutes.home}');
      context.go(AppRoutes.home);
    } else if (!_isAdmin && !_isCashierRoute(currentPath)) {
      // print('MainLayout: Redirecting to ${AppRoutes.order}');
      context.go(AppRoutes.order);
    }
  }

  bool _isAdminRoute(String path) {
    return [
          AppRoutes.home,
          AppRoutes.sale,
          AppRoutes.product,
          AppRoutes.profile,
          AppRoutes.createProduct,
          AppRoutes.productType,
          AppRoutes.createProductType,
        ].contains(path) ||
        path.startsWith(AppRoutes.productDetail) ||
        path.startsWith(AppRoutes.updateProduct) ||
        path.startsWith(AppRoutes.updateProductType);
  }

  bool _isCashierRoute(String path) {
    return [
      AppRoutes.order,
      AppRoutes.cashierSale,
      AppRoutes.profile,
    ].contains(path);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAdminStatusIfNeeded();
        });

        return _isAdmin
            ? AdminMainLayout(
              onRoleChanged: widget.onRoleChanged,
              child: widget.child,
            )
            : CashierMainLayout(
              onRoleChanged: widget.onRoleChanged,
              child: widget.child,
            );
      },
    );
  }
}

// GoRouter configuration (unchanged from provided code)
final GoRouter _router = GoRouter(
  initialLocation:
      AppRoutes.order, // Default to cashier route; will redirect if admin
  navigatorKey: GlobalKey<NavigatorState>(),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AuthMiddleware(
          child: MainLayout(
            child: navigationShell,
            onRoleChanged: () {
              // Navigation handled in MainLayout
            },
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: AppRoutes.sale,
              builder: (context, state) => const SaleScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: AppRoutes.product,
              builder: (context, state) => const ProductScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen2(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: AppRoutes.order,
              builder: (context, state) => const OrderScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: GlobalKey<NavigatorState>(),
          routes: [
            GoRoute(
              path: AppRoutes.cashierSale,
              builder: (context, state) => const CashierSaleScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.login,
      builder:
          (context, state) =>
              AuthMiddleware(child: const AuthLayout(child: LoginScreen())),
    ),
    GoRoute(
      path: AppRoutes.createProduct,
      builder: (context, state) => CreateProductsScreen(),
    ),
    GoRoute(
      path: AppRoutes.productType,
      builder: (context, state) => ProductTypeScreen(),
    ),
    GoRoute(
      path: AppRoutes.createProductType,
      builder: (context, state) => CreateProductTypeScreen(),
    ),
    GoRoute(
      path: '${AppRoutes.productDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DetailProduct(id: id!);
      },
    ),
    GoRoute(
      path: '${AppRoutes.updateProduct}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return UpdateProductScreen(id: id!);
      },
    ),

    GoRoute(
      path: '${AppRoutes.updateProductType}/:id/:image/:name',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        final image = state.pathParameters['image'];
        final name = state.pathParameters['name'];
        return UpdateProductTypeScreen(id: id!, image: image!, name: name!);
      },
    ),
    GoRoute(
      path: AppRoutes.updateProfile,
      builder: (context, state) => const UpdateProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.updatePassword,
      builder: (context, state) => const UpdatePasswordScreen(),
    ),
  ],
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Error: ${state.error}',
            style: const TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
);

/// Auth Layout with Professional Design
class AuthLayout extends StatelessWidget {
  final Widget child;
  const AuthLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '© ${DateTime.now().year} ${dotenv.env['APP_NAME']}',
                style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
