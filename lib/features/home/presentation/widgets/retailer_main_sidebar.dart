import 'package:flutter/material.dart';

// Import your custom sidebar item
import './sidebar_item.dart';

// --- IMPORTANT ---
// You MUST create these page files inside a 'pages' folder
import '../pages/retailer_dashboard_page.dart';
import '../pages/retailer_browse_products_page.dart';
import '../pages/retailer_my_purchases_page.dart';
import '../pages/retailer_my_inventory_page.dart';
import '../pages/retailer_customer_orders_page.dart';
import '../pages/retailer_customers_page.dart';

class RetailerMainSidebar extends StatelessWidget {
  final String selectedPage;

  const RetailerMainSidebar({
    super.key,
    required this.selectedPage,
  });

  @override
  Widget build(BuildContext context) {
    void navigateTo(Widget page) {
      Navigator.pushReplacement(
        context,
        // Using a simple fade transition
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => page,
          transitionDuration: Duration.zero,
        ),
      );
    }

    return Container(
      width: 250,
      color: const Color.fromARGB(255, 2, 18, 37),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            color: const Color.fromARGB(255, 2, 18, 37),
            // Changed icon to reflect a "store"
            child: const Icon(Icons.storefront, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),

          // Dashboard
          SidebarItem(
            icon: Icons.dashboard,
            text: 'Dashboard',
            isSelected: selectedPage == 'dashboard',
            onTap: selectedPage == 'dashboard'
                ? null
                : () => navigateTo(const RetailerDashboardPage()),
          ),

          // Browse Products (Store)
          SidebarItem(
            icon: Icons.store,
            text: "Browse Products",
            isSelected: selectedPage == 'browse_products',
            onTap: selectedPage == 'browse_products'
                ? null
                : () => navigateTo(const RetailerBrowseProductsPage()),
          ),

          // My Purchases (from Wholesaler)
          SidebarItem(
            icon: Icons.receipt_long,
            text: "My Purchases",
            isSelected: selectedPage == 'my_purchases',
            onTap: selectedPage == 'my_purchases'
                ? null
                : () => navigateTo(const RetailerMyPurchasesPage()),
          ),

          // My Inventory (for my Customers)
          SidebarItem(
            icon: Icons.inventory_2,
            text: "My Inventory",
            isSelected: selectedPage == 'my_inventory',
            onTap: selectedPage == 'my_inventory'
                ? null
                : () => navigateTo(const RetailerMyInventoryPage()),
          ),

          // Customer Orders
          SidebarItem(
            icon: Icons.shopping_bag,
            text: "Customer Orders",
            isSelected: selectedPage == 'customer_orders',
            onTap: selectedPage == 'customer_orders'
                ? null
                : () => navigateTo(const RetailerCustomerOrdersPage()),
          ),

          // Customers
          SidebarItem(
            icon: Icons.group,
            text: "Customers",
            isSelected: selectedPage == 'customers',
            onTap: selectedPage == 'customers'
                ? null
                : () => navigateTo(const RetailerCustomersPage()),
          ),
        ],
      ),
    );
  }
}