import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/data/repos/retailer_repo.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import 'retailer_dashboard_page.dart';
import 'retailer_browse_products_page.dart';
import 'retailer_my_inventory_page.dart';
import 'retailer_my_purchases_page.dart';
import 'retailer_customer_orders_page.dart';
import 'retailer_customers_page.dart';
import 'retailer_listings_page.dart';
import 'retailer_cart_page.dart';

class RetailerHomePage extends StatefulWidget {
  const RetailerHomePage({super.key});
  @override
  State<RetailerHomePage> createState() => _RetailerHomePageState();
}

class _RetailerHomePageState extends State<RetailerHomePage> {
  String _currentPage = 'dashboard';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onPageChanged(String pageName) {
    setState(() => _currentPage = pageName);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    String uid = '';
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) uid = authState.user.uid;

    return RepositoryProvider(
      create: (context) => RetailerRepo(),
      child: BlocProvider(
        create: (context) => RetailerCubit(context.read<RetailerRepo>(), uid),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth > 800;
            return Scaffold(
              key: _scaffoldKey,
              appBar: !isDesktop
                  ? AppBar(
                      title: Text(_getTitle()),
                      leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
                      actions: [
                        if (_currentPage == 'browse_products')
                          IconButton(
                            icon: const Icon(Icons.shopping_cart),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<RetailerCubit>(), child: const RetailerCartPage()))),
                          )
                      ],
                    )
                  : null,
              drawer: !isDesktop ? RetailerMainSidebar(selectedPage: _currentPage, onPageChanged: _onPageChanged) : null,
              body: Row(
                // FIX: This prevents layout crash due to Sidebar Spacer
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isDesktop) RetailerMainSidebar(selectedPage: _currentPage, onPageChanged: _onPageChanged),
                  Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _getPage())),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentPage) {
      case 'browse_products': return 'Browse';
      case 'my_purchases': return 'Purchases';
      case 'my_inventory': return 'Inventory';
      default: return 'Retailer Hub';
    }
  }

  Widget _getPage() {
    switch (_currentPage) {
      case 'browse_products': return const RetailerBrowseProductsPage();
      case 'my_purchases': return const RetailerMyPurchasesPage();
      case 'my_inventory': return const RetailerMyInventoryPage();
      case 'listings': return const RetailerListingsPage();
      case 'customer_orders': return const RetailerCustomerOrdersPage();
      case 'customers': return const RetailerCustomersPage();
      default: return const RetailerDashboardPage();
    }
  }
}