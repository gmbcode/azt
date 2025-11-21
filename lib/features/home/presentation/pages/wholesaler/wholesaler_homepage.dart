import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// THEME IMPORT
import '../../../../../../theme/app_theme.dart'; 

// Logic
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../auth/presentation/cubits/auth_states.dart';
import '../../../../wholesaler/data/repos/wholesaler_repo.dart';

// Widgets & Pages
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

  void _onPageChanged(String pageName) {
    setState(() {
      _currentPage = pageName;
    });
  }

  // Helper to convert page name to a readable title for the AppBar
  String _getPageTitle(String pageName) {
    switch (pageName) {
      case 'browse_products': return 'Browse Products';
      case 'my_purchases': return 'My Purchases';
      case 'my_inventory': return 'My Inventory';
      case 'listings': return 'My Listings';
      case 'customer_orders': return 'Customer Orders';
      case 'customers': return 'My Customers';
      case 'retailers': return 'Retailers';
      case 'orders': return 'Orders';
      case 'inventory': return 'Inventory';
      case 'dashboard':
      default: return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = '';
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      uid = authState.user.uid;
    }

    return RepositoryProvider(
      create: (context) => WholesalerRepo(),
      child: BlocProvider(
        create: (context) => WholesalerCubit(context.read<WholesalerRepo>(), uid),
        
        
        child: Theme(
          data: AppTheme.lightTheme, // Use 'AppTheme.darkTheme' here if you prefer the dark version
          
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Check if screen width is above a mobile threshold
              final isDesktop = constraints.maxWidth > 800; 
              
              Widget currentContent;
              switch (_currentPage) {
                case 'inventory':
                  currentContent = const InventoryPage();
                  break;
                case 'listings':
                  currentContent = const ListingsPage();
                  break;
                case 'orders':
                  currentContent = const OrdersPage();
                  break;
                case 'retailers':
                  currentContent = const RetailersPage();
                  break;
                case 'dashboard':
                default:
                  currentContent = const wholeSalerDashboardpage();
                  break;
              }
              
              if (isDesktop) {
                // Desktop Layout (Row with fixed sidebar)
                return Scaffold( // Wrapped in Scaffold for safety, but main structure is Row
                  body: Row(
                    children: [
                      MainSidebar(
                        selectedPage: _currentPage,
                        onPageChanged: _onPageChanged,
                      ),
                      Expanded(child: currentContent),
                    ],
                  ),
                );
              } else {
                // Mobile Layout (Scaffold with Drawer)
                return Scaffold(
                  appBar: AppBar(
                    title: Text(_getPageTitle(_currentPage)), // Display current page name
                  ),
                  drawer: Drawer(
                    child: MainSidebar(
                      selectedPage: _currentPage,
                      onPageChanged: (pageName) {
                        _onPageChanged(pageName);
                        Navigator.of(context).pop(); // Close drawer after selection
                      },
                    ),
                  ),
                  body: currentContent,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}