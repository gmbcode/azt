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
          
          child: Scaffold(
            // Scaffold background is now controlled by AppTheme
            body: Row(
              children: [
                MainSidebar(
                  selectedPage: _currentPage,
                  onPageChanged: _onPageChanged,
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      switch (_currentPage) {
                        case 'inventory':
                          return const InventoryPage();
                        case 'listings':
                          return const ListingsPage();
                        case 'orders':
                          return const OrdersPage();
                        case 'retailers':
                          return const RetailersPage();
                        case 'dashboard':
                        default:
                          return const wholeSalerDashboardpage();
                      }
                    },
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