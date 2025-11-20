// lib/widgets/inventory_table.dart

import 'package:flutter/material.dart';

import '../wholesaler_models/inventory_item_model.dart';

class InventoryTable extends StatelessWidget {
  final List<InventoryItemModel> inventory;
  final ValueChanged<String> onDelete; // Callback for delete button

  const InventoryTable({
    super.key,
    required this.inventory,
    required this.onDelete,
  });

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
          Expanded(
            child: ListView.builder(
              itemCount: inventory.length,
              itemBuilder: (context, index) {
                return _buildDataRow(inventory[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF6C757D),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('PRODUCT', style: headerStyle)),
          Expanded(flex: 2, child: Text('CATEGORY', style: headerStyle)),
          Expanded(flex: 1, child: Text('PRICE', style: headerStyle)),
          Expanded(flex: 2, child: Text('STOCK REMAIN', style: headerStyle)),
          Expanded(flex: 2, child: Text('STOCK SOLD', style: headerStyle)),
          Expanded(flex: 2, child: Center(child: Text('ACTIONS', style: headerStyle))),
        ],
      ),
    );
  }

  Widget _buildDataRow(InventoryItemModel item) {
    
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9ECEF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF6C757D),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible( // Use Flexible to prevent text overflow
                  child: Text(
                    item.name, 
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Category Cell
          Expanded(flex: 2, child: Text(item.category)),
          // Price Cell
          Expanded(flex: 1, child: Text('\$${item.price.toStringAsFixed(0)}')),
          // Stock Remain Cell
          Expanded(flex: 2, child: Text(item.stockRemain.toString())),
          // Stock Sold Cell
          Expanded(flex: 2, child: Text(item.stocksold.toString())),
          // Actions Cell
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implement Edit Logic
                    print('Edit ${item.name}');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => onDelete(item.id), // **DELETE LOGIC**
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}