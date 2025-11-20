import 'package:flutter/material.dart';
import 'wholesaler_sidebar_item.dart';

class MainSidebar extends StatelessWidget {
  final String selectedPage;
  final ValueChanged<String> onPageChanged;

  const MainSidebar({
    super.key,
    required this.selectedPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Automatically switches: Deep Blue (Light) / Dark Grey (Dark)
    final sidebarColor = Theme.of(context).appBarTheme.backgroundColor; 

    return Container(
      width: 250,
      color: sidebarColor, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            color: sidebarColor,
            child: const Row(
              children: [
                Icon(Icons.storefront, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  "Wholesaler\nHub",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 20),

          SidebarItem(icon: Icons.dashboard, text: 'Dashboard', isSelected: selectedPage == 'dashboard', onTap: () => onPageChanged('dashboard')),
          SidebarItem(icon: Icons.inventory_2, text: "Inventory", isSelected: selectedPage == 'inventory', onTap: () => onPageChanged('inventory')),
          SidebarItem(icon: Icons.list_alt, text: "My Listings", isSelected: selectedPage == 'listings', onTap: () => onPageChanged('listings')),
          SidebarItem(icon: Icons.shopping_bag, text: "Orders", isSelected: selectedPage == 'orders', onTap: () => onPageChanged('orders')),
          SidebarItem(icon: Icons.group, text: "Retailers", isSelected: selectedPage == 'retailers', onTap: () => onPageChanged('retailers')),
        ],
      ),
    );
  }
}