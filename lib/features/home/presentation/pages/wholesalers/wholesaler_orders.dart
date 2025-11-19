// lib/pages/orders.dart

import 'package:flutter/material.dart';


import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_order_filter_chips.dart';
import '../../wholesaler_widgets/wholesaler_order_search_bar.dart';
import '../../wholesaler_widgets/wholesaler_order_table.dart';
import 'wholesaler_retailers.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background for the whole page
      body: Row(
        children: [
          // 1. The Sidebar
          const MainSidebar(selectedPage: 'orders'),

          // 2. The Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                // This white container holds the content, like in the image
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Header
                    const Text(
                      "Orders",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Filter Chips (NEW)
                    const OrderFilterChips(),
                    const SizedBox(height: 20),

                    // Search Bar
                    const OrderSearchBar(),
                    const SizedBox(height: 20),

                    // Order Table
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // The OrderTable widget itself is scrollable
                          child: const OrderTable(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bulk Actions & Pagination (NEW)
                    _buildBulkActions(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the bottom "Bulk Actions" row
  Widget _buildBulkActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(value: false, onChanged: (val) {}), // Dummy checkbox
            const Text('Delete Selected'),
            const SizedBox(width: 20),
            Icon(Icons.upload_file, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
            const Text('Export to CSV'),
          ],
        ),
        
        // Pagination
        Row(
          children: [
            IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: () {}),
            const Text('1'),
            IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
          ],
        )
      ],
    );
  }
}