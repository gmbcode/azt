// lib/pages/retailers.dart

import 'package:flutter/material.dart';

// --- Import all the required widgets ---

import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_retailer_filter_tab.dart';
import '../../wholesaler_widgets/wholesaler_retailer_grid.dart';
import '../../wholesaler_widgets/wholesaler_retailer_search_bar.dart';
import 'wholesaler_orders.dart';

class RetailersPage extends StatelessWidget {
  const RetailersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: Row(
        children: [
          // 1. The Sidebar (Unchanged, as requested)
          const MainSidebar(selectedPage: 'retailers'),

          // 2. The Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                // This white container holds all the content
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Title and Search Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Retailers",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const RetailerSearchBar(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Tabs
                    const RetailerFilterTabs(),

                    // Divider Line
                    const Divider(height: 21, color: Color.fromARGB(255, 230, 230, 230)),

                    // Retailer Grid (takes up the remaining space)
                    const Expanded(
                      child: RetailerGrid(),
                    ),

                    // Pagination Controls (copied from OrdersPage logic)
                    _buildPaginationControls(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the bottom pagination controls
  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: () {}),
        const Text('1'),
        IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
      ],
    );
  }
}