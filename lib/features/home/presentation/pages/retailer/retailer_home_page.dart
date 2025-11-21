import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Logic
import '../../../../retailer/data/repos/retailer_repo.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';

// Widgets
import '../../retailer_widgets/retailer_main_sidebar.dart';

// Pages
import 'retailer_dashboard_page.dart';
import 'retailer_browse_products_page.dart';
import 'retailer_my_inventory_page.dart';
import 'retailer_my_purchases_page.dart';
import 'retailer_customer_orders_page.dart';
import 'retailer_customers_page.dart';
import 'retailer_listings_page.dart';

class RetailerHomePage extends StatefulWidget {
  const RetailerHomePage({super.key});

  @override
  State<RetailerHomePage> createState() => _RetailerHomePageState();
}

class _RetailerHomePageState extends State<RetailerHomePage> {
  // State to track which page is currently visible
  String _currentPage = 'dashboard';

  void _onPageChanged(String pageName) {
    setState(() {
      _currentPage = pageName;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get User UID
    String uid = '';
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      uid = authState.user.uid;
    }

    return RepositoryProvider(
      create: (context) => RetailerRepo(),
      child: BlocProvider(
        // Create the Cubit ONCE at the top level of the Retailer Home
        create: (context) => RetailerCubit(context.read<RetailerRepo>(), uid),
        child: Scaffold(
          body: Row(
            children: [
              // Sidebar stays persistent
              RetailerMainSidebar(
                selectedPage: _currentPage,
                onPageChanged: _onPageChanged,
              ),
              
              // Content area swaps widgets based on state
              Expanded(
                child: Builder(
                  builder: (context) {
                    switch (_currentPage) {
                      case 'browse_products':
                        return const RetailerBrowseProductsPage();
                      case 'my_purchases':
                        return const RetailerMyPurchasesPage();
                      case 'my_inventory':
                        return const RetailerMyInventoryPage();
                      case 'listings':
                        return const RetailerListingsPage();
                      case 'customer_orders':
                        return const RetailerCustomerOrdersPage();
                      case 'customers':
                        return const RetailerCustomersPage();
                      case 'dashboard':
                      default:
                        return const RetailerDashboardPage();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}