import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import 'retailer_sidebar_item.dart';

class RetailerMainSidebar extends StatelessWidget {
  final String selectedPage;
  final ValueChanged<String> onPageChanged;

  const RetailerMainSidebar({
    super.key,
    required this.selectedPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E1E2C), const Color(0xFF2D2D44)] 
            : [Colors.blue.shade900, Colors.blue.shade800],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.store, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text("AZT Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white12, height: 1),
          
          SidebarItem(icon: Icons.dashboard_outlined, text: 'Dashboard', isSelected: selectedPage == 'dashboard', onTap: () => onPageChanged('dashboard')),
          SidebarItem(icon: Icons.search, text: "Browse Wholesalers", isSelected: selectedPage == 'browse_products', onTap: () => onPageChanged('browse_products')),
          SidebarItem(icon: Icons.shopping_cart_outlined, text: "My Purchases", isSelected: selectedPage == 'my_purchases', onTap: () => onPageChanged('my_purchases')),
          SidebarItem(icon: Icons.inventory_2_outlined, text: "My Inventory", isSelected: selectedPage == 'my_inventory', onTap: () => onPageChanged('my_inventory')),
          SidebarItem(icon: Icons.list_alt, text: "My Listings", isSelected: selectedPage == 'listings', onTap: () => onPageChanged('listings')),
          SidebarItem(icon: Icons.assignment_outlined, text: "Customer Orders", isSelected: selectedPage == 'customer_orders', onTap: () => onPageChanged('customer_orders')),
          SidebarItem(icon: Icons.people_outline, text: "My Customers", isSelected: selectedPage == 'customers', onTap: () => onPageChanged('customers')),
          
          const Spacer(),
          const Divider(color: Colors.white12),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => context.read<AuthCubit>().logout(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}