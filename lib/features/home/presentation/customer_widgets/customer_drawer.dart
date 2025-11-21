import 'package:flutter/material.dart';

class CustomerDrawer extends StatelessWidget {
  final String currentPage;
  final ValueChanged<String> onPageChanged;

  const CustomerDrawer({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Use a gradient background for a "Premium" feel
    return Container(
      width: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1E1E2C), const Color(0xFF2D2D44)] 
            : [primaryColor, primaryColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          // Logo / Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 32),
                SizedBox(width: 10),
                Text(
                  "ShopHub",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white24),
          
          // Menu Items
          _buildNavItem("Dashboard", Icons.dashboard_outlined, 'dashboard'),
          _buildNavItem("Browse Products", Icons.search, 'browse'),
          _buildNavItem("My Cart", Icons.shopping_cart_outlined, 'cart'),
          _buildNavItem("My Orders", Icons.local_shipping_outlined, 'orders'),
          _buildNavItem("My Profile", Icons.person_outline, 'profile'),
          
          const Spacer(),
          const Divider(color: Colors.white24),
          _buildNavItem("Logout", Icons.logout, 'logout', isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, IconData icon, String pageKey, {bool isLogout = false}) {
    final bool isSelected = currentPage == pageKey;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        leading: Icon(icon, color: isSelected || isLogout ? Colors.orange : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected || isLogout ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white.withOpacity(0.1),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
        onTap: () => onPageChanged(pageKey),
      ),
    );
  }
}