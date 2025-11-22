import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Architecture
import '../../../../customer/data/repos/customer_repo.dart';
import '../../../../customer/presentation/cubits/customer_cubit.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';

// Widgets
import '../../customer_widgets/customer_drawer.dart';

// Pages
import '../../customer_widgets/customer_theme.dart';
import 'customer_dashboard_page.dart';
import 'customer_browse_products_page.dart';
import 'customer_cart_page.dart';
import 'customer_orders_page.dart';
import 'customer_product_for_you_page.dart';
import 'customer_profile_page.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  String _currentPage = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigate(String page) {
    if (page == 'logout') {
      context.read<AuthCubit>().logout();
      return;
    }
    setState(() => _currentPage = page);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = '';
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) uid = authState.user.uid;

    return RepositoryProvider(
      create: (context) => CustomerRepo(),
      child: BlocProvider(
        create: (context) => CustomerCubit(context.read<CustomerRepo>(), uid),
        child: Theme(
          data: CustomerTheme.theme,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth > 800;
          
              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                
                drawer: !isDesktop 
                  ? CustomerDrawer(currentPage: _currentPage, onPageChanged: _navigate)
                  : null,
                  
                appBar: !isDesktop
                  ? AppBar(
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      title: Text(_getPageTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      actions: [
                        _CartBadgeIcon(onTap: () => setState(() => _currentPage = 'cart'))
                      ],
                    )
                  : null,
          
                body: Row(
                  children: [
                    if (isDesktop)
                      CustomerDrawer(currentPage: _currentPage, onPageChanged: _navigate),
                    
                    Expanded(
                      child: Column(
                        children: [
                          if (isDesktop)
                            Container(
                              height: 80,
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_getPageTitle(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  _CartBadgeIcon(onTap: () => setState(() => _currentPage = 'cart')),
                                ],
                              ),
                            ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _getPageWidget(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 'browse': return 'Browse Products';
      case 'products_for_you': return 'For You'; // NEW TITLE
      case 'cart': return 'Shopping Cart';
      case 'orders': return 'Order History';
      case 'profile': return 'My Profile';
      case 'dashboard': return 'Dashboard';
      default: return '';
    }
  }

  Widget _getPageWidget() {
    switch (_currentPage) {
      case 'browse': return const CustomerBrowseProductsPage(key: ValueKey('browse'));
      case 'products_for_you': return const CustomerProductsForYouPage(key: ValueKey('products_for_you')); // NEW PAGE
      case 'cart': return const CustomerCartPage(key: ValueKey('cart'));
      case 'orders': return const CustomerOrdersPage(key: ValueKey('orders'));
      case 'profile': return const CustomerProfilePage(key: ValueKey('profile'));
      case 'dashboard': 
      default: return CustomerDashboardPage(onNavigate: _navigate, key: const ValueKey('dashboard'));
    }
  }
}

class _CartBadgeIcon extends StatelessWidget {
  final VoidCallback onTap;
  const _CartBadgeIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        int count = 0;
        if (state is CustomerLoaded) {
          count = state.cart.length;
        }
        return IconButton(
          onPressed: onTap,
          icon: Badge(
            label: Text(count.toString()),
            isLabelVisible: count > 0,
            child: const Icon(Icons.shopping_cart_outlined, size: 28),
          ),
        );
      },
    );
  }
}