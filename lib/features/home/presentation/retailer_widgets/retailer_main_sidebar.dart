import 'package:flutter/material.dart';
import 'retailer_sidebar_item.dart';

class RetailerMainSidebar extends StatelessWidget {
  final String selectedPage;
  final ValueChanged<String> onPageChanged; // Changed from internal navigation to callback

  const RetailerMainSidebar({
    super.key,
    required this.selectedPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Theme Aware Color
    final sidebarColor = Theme.of(context).appBarTheme.backgroundColor ?? const Color.fromARGB(255, 2, 18, 37);

    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Row(
              children: [
                Icon(Icons.store, color: Colors.white, size: 32),
                SizedBox(width: 10),
                Text("Retailer Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          // Use onPageChanged callback instead of Navigator
          SidebarItem(icon: Icons.dashboard, text: 'Dashboard', isSelected: selectedPage == 'dashboard', onTap: () => onPageChanged('dashboard')),
          SidebarItem(icon: Icons.search, text: "Browse Products", isSelected: selectedPage == 'browse_products', onTap: () => onPageChanged('browse_products')),
          SidebarItem(icon: Icons.shopping_cart, text: "My Purchases", isSelected: selectedPage == 'my_purchases', onTap: () => onPageChanged('my_purchases')),
          SidebarItem(icon: Icons.inventory, text: "My Inventory", isSelected: selectedPage == 'my_inventory', onTap: () => onPageChanged('my_inventory')),
          SidebarItem(icon: Icons.list_alt, text: "My Listings", isSelected: selectedPage == 'listings', onTap: () => onPageChanged('listings')),
          SidebarItem(icon: Icons.assignment, text: "Customer Orders", isSelected: selectedPage == 'customer_orders', onTap: () => onPageChanged('customer_orders')),
          SidebarItem(icon: Icons.group, text: "My Customers", isSelected: selectedPage == 'customers', onTap: () => onPageChanged('customers')),
        ],
      ),
    );
  }
}