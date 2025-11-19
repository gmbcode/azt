import 'package:azt/features/home/presentation/wholesaler_widgets/wholesaler_sidebar_item.dart';
import 'package:flutter/material.dart';

import '../pages/wholesaler/wholesaler_dashboardpage.dart';
import '../pages/wholesaler/wholesaler_inventorypage.dart';
import '../pages/wholesaler/wholesaler_orders.dart';
import '../pages/wholesaler/wholesaler_retailers.dart';



class MainSidebar extends StatelessWidget {
  final String selectedPage;

  const MainSidebar({
    super.key,
    required this.selectedPage,
  });

  @override
  Widget build(BuildContext context) {
    // This is the navigation logic
    void navigateTo(Widget page) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }

    return Container(
      width: 250,
      color: const Color.fromARGB(255, 2, 18, 37),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Header
          Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: const Color.fromARGB(255, 2, 18, 37),
            child: const Icon(Icons.business, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),

          // Dashboard Item
          SidebarItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            isSelected: selectedPage == 'dashboard',
            onTap: selectedPage == 'dashboard'
                ? null // Disable tap if already selected
                : () => navigateTo(const wholeSalerDashboardpage()),
          ),

          // Inventory Item
          SidebarItem(
            icon: Icons.inventory_2,
            text: "Inventory",
            isSelected: selectedPage == 'inventory',
            onTap: selectedPage == 'inventory'
                ? null // Disable tap if already selected
                : () => navigateTo(const InventoryPage()),
          ),

          // Orders Item
          SidebarItem(
            icon: Icons.shopping_bag,
            text: "Orders",
            isSelected: selectedPage == 'orders',
            onTap: selectedPage == 'orders'
                ? null // Disable tap if already selected
                : () => navigateTo(const OrdersPage()),
          ),

          // Retailers Item
          SidebarItem(
            icon: Icons.group,
            text: "Retailers",
            isSelected: selectedPage == 'retailers',
            onTap: selectedPage == 'retailers'
                ? null // Disable tap if already selected
                : () => navigateTo(const RetailersPage()),
          ),
        ],
      ),
    );
  }
}
