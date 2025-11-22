import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E1E2C), const Color(0xFF2D2D44)] 
            : [Colors.indigo.shade900, Colors.indigo.shade700],
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
                const Icon(Icons.storefront, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text("Wholesaler Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Divider(color: Colors.white24, height: 1),
          
          SidebarItem(icon: Icons.dashboard_outlined, text: 'Dashboard', isSelected: selectedPage == 'dashboard', onTap: () => onPageChanged('dashboard')),
          SidebarItem(icon: Icons.inventory_2_outlined, text: "Inventory", isSelected: selectedPage == 'inventory', onTap: () => onPageChanged('inventory')),
          SidebarItem(icon: Icons.list_alt, text: "My Listings", isSelected: selectedPage == 'listings', onTap: () => onPageChanged('listings')),
          SidebarItem(icon: Icons.shopping_bag_outlined, text: "Orders", isSelected: selectedPage == 'orders', onTap: () => onPageChanged('orders')),
          SidebarItem(icon: Icons.people_outline, text: "Retailers", isSelected: selectedPage == 'retailers', onTap: () => onPageChanged('retailers')),
          
          const Spacer(),
          const Divider(color: Colors.white24),
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