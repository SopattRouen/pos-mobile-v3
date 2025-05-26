import 'package:calendar/screen/product_screen.dart';
import 'package:calendar/screen/sale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:calendar/app_routes.dart';
import 'package:calendar/middleware/auth_middleware.dart';
import 'package:calendar/providers/global/auth_provider.dart';

import 'package:calendar/screen/home_screen.dart';
import 'package:calendar/screen/login_screen.dart';
import 'package:calendar/screen/profile_screen.dart';

import 'package:calendar/utils/dio.client.dart';

import 'package:provider/provider.dart';

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

  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider(), child: const MyApp()),
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
      theme: ThemeData(
        fontFamily: 'Kantumruy',
        primaryColor: const Color(0xFF002458),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF002458),
          secondary: Color(0xFFD4AD38),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
          bodySmall: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF002458),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFD4AD38),
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          showUnselectedLabels: true,
          elevation: 8,
        ),
      ),
    );
  }
}

// Fixed Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.home,
  navigatorKey: GlobalKey<NavigatorState>(),
  routes: [
    ShellRoute(
      navigatorKey: GlobalKey<NavigatorState>(),
      builder:
          (context, state, child) =>
              AuthMiddleware(child: MainLayout(child: child)),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.sale,
          builder: (context, state) => const SaleScreen(),
        ),
        GoRoute(
          path: AppRoutes.product,
          builder: (context, state) => const ProductScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
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
      path: AppRoutes.product,
      builder: (context, state) => const ProductScreen(),
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

/// Main Layout with Enhanced Bottom Navigation Bar
class MainLayout extends StatefulWidget {
  final Widget child;
  const MainLayout({required this.child, super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0:
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.sale);
                break;
              case 2:
                context.go(AppRoutes.product);
                break;
              case 3:
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
              icon: _buildNavIcon(Icons.production_quantity_limits, 1),
              activeIcon: _buildNavIcon(Icons.production_quantity_limits, 1, active: true),
              label: 'ការលក់',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.category_rounded, 2),
              activeIcon: _buildNavIcon(Icons.category_rounded, 2, active: true),
              label: 'ផលិតផល',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person, 3),
              activeIcon: _buildNavIcon(Icons.person, 3, active: true),
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
            active ? Theme.of(context).colorScheme.secondary : Colors.grey[600],
      ),
    );
  }
}

/// Auth Layout with Professional Design
class AuthLayout extends StatelessWidget {
  final Widget child;
  const AuthLayout({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(child: child),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    '© ${DateTime.now().year} ${dotenv.env['APP_NAME']}',
                    style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
