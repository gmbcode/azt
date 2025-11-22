import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../theme/app_theme.dart'; 
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';
import '../../../../wholesaler/data/repos/wholesaler_repo.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart'; 
import 'wholesaler_dashboardpage.dart';
import 'wholesaler_inventorypage.dart';
import 'wholesaler_listings.dart';
import 'wholesaler_orders.dart';
import 'wholesaler_retailers.dart';

class WholesalerHomePage extends StatefulWidget {
  const WholesalerHomePage({super.key});

  @override
  State<WholesalerHomePage> createState() => _WholesalerHomePageState();
}

class _WholesalerHomePageState extends State<WholesalerHomePage> {
  String _currentPage = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onPageChanged(String pageName) {
    setState(() => _currentPage = pageName);
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
      create: (context) => WholesalerRepo(),
      child: BlocProvider(
        create: (context) => WholesalerCubit(context.read<WholesalerRepo>(), uid),
        child: Theme(
          data: AppTheme.lightTheme,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isDesktop = constraints.maxWidth > 800;
              
              return Scaffold(
                key: _scaffoldKey,
                appBar: !isDesktop
                  ? AppBar(
                      title: Text(_getTitle()),
                      leading: IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () => context.read<AuthCubit>().logout(),
                        )
                      ],
                    )
                  : null,
                drawer: !isDesktop 
                  ? MainSidebar(selectedPage: _currentPage, onPageChanged: _onPageChanged)
                  : null,
                body: Row(
                  // FIX: This line prevents the Sidebar Spacer() from crashing the app
                  crossAxisAlignment: CrossAxisAlignment.stretch, 
                  children: [
                    if (isDesktop)
                      MainSidebar(selectedPage: _currentPage, onPageChanged: _onPageChanged),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _getPage(),
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentPage) {
      case 'inventory': return 'Inventory';
      case 'listings': return 'Listings';
      case 'orders': return 'Orders';
      case 'retailers': return 'Retailers';
      default: return 'Dashboard';
    }
  }

  Widget _getPage() {
    switch (_currentPage) {
      case 'inventory': return const InventoryPage();
      case 'listings': return const ListingsPage();
      case 'orders': return const OrdersPage();
      case 'retailers': return const RetailersPage();
      case 'dashboard': default: return const wholeSalerDashboardpage();
    }
  }
}