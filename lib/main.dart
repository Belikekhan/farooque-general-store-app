import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_colors.dart';

import 'injection_container.dart' as di;
import 'data/sources/local/hive_service.dart';

import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/cart/cart_event.dart';
import 'presentation/blocs/order/order_bloc.dart';

import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/cart/cart_screen.dart';
import 'presentation/screens/orders/orders_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/product/product_detail_screen.dart';
import 'data/models/product_model.dart';
import 'data/repositories/product_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await di.init();
  await di.sl<HiveService>().init();
  await di.sl<ProductRepository>().seedProductsIfEmpty();

  runApp(const FarooqueApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return _MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.search,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.orders,
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as ProductModel?;
        if (product == null) return const Scaffold(body: Center(child: Text('Product Not Found')));
        return ProductDetailScreen(product: product);
      },
    ),
  ],
);

class FarooqueApp extends StatelessWidget {
  const FarooqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<CartBloc>()..add(LoadCart())),
        BlocProvider(create: (_) => di.sl<OrderBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Farooque Kirana',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}

class _MainLayout extends StatelessWidget {
  final Widget child;

  const _MainLayout({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          int cartCount = 0;
          if (state is CartLoaded) {
            cartCount = state.items.length;
          }
          return _buildBottomNav(context, cartCount);
        },
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int cartCount) {
    final location = GoRouterState.of(context).matchedLocation;
    
    int currentIndex = _calculateSelectedIndex(location);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go(AppRoutes.home);
            break;
          case 1:
            context.go(AppRoutes.search);
            break;
          case 2:
            context.go(AppRoutes.cart);
            break;
          case 3:
            context.go(AppRoutes.orders);
            break;
          case 4:
            context.go(AppRoutes.profile);
            break;
        }
      },
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryGreen.withOpacity(0.1),
      destinations: [
        const NavigationDestination(
          icon: Icon(Iconsax.home, color: AppColors.textMuted),
          selectedIcon: Icon(Iconsax.home, color: AppColors.primaryGreen),
          label: 'Home',
        ),
        const NavigationDestination(
          icon: Icon(Iconsax.search_normal, color: AppColors.textMuted),
          selectedIcon: Icon(Iconsax.search_normal, color: AppColors.primaryGreen),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text(cartCount.toString()),
            backgroundColor: AppColors.errorRed,
            child: const Icon(Iconsax.bag_2, color: AppColors.textMuted),
          ),
          selectedIcon: Badge(
            isLabelVisible: cartCount > 0,
            label: Text(cartCount.toString()),
            backgroundColor: AppColors.errorRed,
            child: const Icon(Iconsax.bag_2, color: AppColors.primaryGreen),
          ),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Iconsax.receipt, color: AppColors.textMuted),
          selectedIcon: Icon(Iconsax.receipt, color: AppColors.primaryGreen),
          label: 'Orders',
        ),
        const NavigationDestination(
          icon: Icon(Iconsax.user, color: AppColors.textMuted),
          selectedIcon: Icon(Iconsax.user, color: AppColors.primaryGreen),
          label: 'Profile',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location.startsWith(AppRoutes.home)) return 0;
    if (location.startsWith(AppRoutes.search)) return 1;
    if (location.startsWith(AppRoutes.cart)) return 2;
    if (location.startsWith(AppRoutes.orders)) return 3;
    if (location.startsWith(AppRoutes.profile)) return 4;
    return 0;
  }
}
