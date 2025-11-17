// lib/pages/inventorypage.dart

import 'package:flutter/material.dart';

// Import your new widgets


// Import the other pages for navigation
import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_searchbar_inventory.dart';
import '../../wholesaler_widgets/wholesaler_table_inventory.dart';
import 'wholesaler_dashboardpage.dart';
import 'wholesaler_orders.dart';
import 'wholesaler_retailers.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // A controller to get the text from the search bar
  final TextEditingController _searchController = TextEditingController();

  // Function to show the "Add Product" popup
  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddProductDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 1. Your sidebar (no change)
          const MainSidebar(selectedPage: 'inventory'),

          // 2. This is your main content area
          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA), // Main background color
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- PAGE TITLE ---
                  const Text(
                    "Inventory",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212529),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- SEARCH BAR AND BUTTON ROW ---
                  Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            //
                            // THIS IS WHERE YOUR FRIEND WILL ADD SEARCH LOGIC
                            // print('Searching for: $value');
                            //
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // "Add New Product" Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Add New Product',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange, // Match inspiration
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _showAddProductDialog, // <-- CALLS THE POPUP
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- THE NEW INVENTORY TABLE ---
                  // Expanded makes the table fill the remaining space
                  const Expanded(
                    child: InventoryTable(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}