// lib/widgets/inventory_table.dart

import 'package:flutter/material.dart';

class InventoryTable extends StatelessWidget {
  const InventoryTable({super.key});

  // This is the placeholder data.
  // Your friend will replace this with a real, dynamic list from the backend.
  // The 'imageUrl' is no longer used here, but can be added back for real data.
  final List<Map<String, dynamic>> placeholderData = const [   //dynamic means it can be anything String,number or anything
    {
      'name': 'Apples',
      'category': 'Fruits',
      'price': 100,
      'stockremain': 45,
      'stocksold': 23,
    },
    {
      'name': 'Carrots',
      'category': 'Vegetables',
      'price': 80,
      'stockremain': 75,
      'stocksold': 15,
    },
    {
      'name': 'Organic Bread',
      'category': 'Bakery',
      'price': 50,
      'stockremain': 120,
      'stocksold': 80,
    },
    {
      'name': 'Olive Oil 5L',
      'category': 'Pantry',
      'price': 1500,
      'stockremain': 20,
      'stocksold': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. THE TABLE HEADER
          _buildHeaderRow(),
          
          // 2. THE TABLE DATA ROWS
          // This creates a scrollable list of rows from the placeholder data//it also ensures that the page remains fixed while 
          //while the table becomes scrollable
          Expanded(
            child: ListView.builder(
              itemCount: placeholderData.length,
              itemBuilder: (context, index) {
                return _buildDataRow(placeholderData[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Private helper widget for the header row (No changes here)
  Widget _buildHeaderRow() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF6C757D), // A nice grey color for headers
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA), // Light grey background for header
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('PRODUCT', style: headerStyle)),  //flex ye hota hai ki expanded ki kintni jagah lega 
          Expanded(flex: 2, child: Text('CATEGORY', style: headerStyle)),
          Expanded(flex: 1, child: Text('PRICE', style: headerStyle)),
          Expanded(flex: 2, child: Text('STOCK REMAIN', style: headerStyle)),
          Expanded(flex: 2, child: Text('STOCK SOLD', style: headerStyle)),
          Expanded(flex: 2, child: Center(child: Text('ACTIONS', style: headerStyle))),
        ],
      ),
    );
  }

  // Private helper widget for a single data row
  Widget _buildDataRow(Map<String, dynamic> data) {
    
    // --- THIS IS THE ONLY PART THAT CHANGED ---
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFDEE2E6))),
      ),
      child: Row(
        children: [
          // Product Cell
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // REPLACED Image.network WITH A PLACEHOLDER ICON
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF), // A light grey background
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined, // A fitting placeholder icon
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  data['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Category Cell
          Expanded(flex: 2, child: Text(data['category'])),
          // Price Cell
          Expanded(flex: 1, child: Text('\$${data['price']}')),
          // Stock Remain Cell
          Expanded(flex: 2, child: Text(data['stockremain'].toString())),
          // Stock Sold Cell
          Expanded(flex: 2, child: Text(data['stocksold'].toString())),
          // Actions Cell
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () {
                    // Logic to edit item
                    print('Edit ${data['name']}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    // Logic to delete item
                    print('Delete ${data['name']}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}