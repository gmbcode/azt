

import 'package:azt/features/home/presentation/pages/wholesaler/wholesaler_dashboardpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/cubits/auth_cubit.dart';

class WholesalerHomePage extends StatefulWidget {
  const WholesalerHomePage({super.key});

  @override
  State<WholesalerHomePage> createState() => _WholesalerHomePageState();
}

class _WholesalerHomePageState extends State<WholesalerHomePage> {
  // Track current page if dashboard has multiple sections
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Wholesaler Hub"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Logout button - always visible
          IconButton(
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final authCubit = context.read<AuthCubit>();
                        authCubit.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      // Wrap the dashboard in a theme to ensure proper styling
      body: Theme(
        data: ThemeData(
          primarySwatch: Colors.orange,
          scaffoldBackgroundColor: Colors.grey[200],
          // Table theme for visibility
          dataTableTheme: DataTableThemeData(
            headingRowColor: WidgetStateProperty.all(Colors.orange.shade100),
            dataRowColor: WidgetStateProperty.all(Colors.white),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            titleLarge: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            bodyMedium: TextStyle(color: Colors.black87),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        // Use Navigator to prevent the dashboard from replacing the scaffold
        child: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const wholeSalerDashboardpage(),
            );
          },
        ),
      ),
    );
  }
}