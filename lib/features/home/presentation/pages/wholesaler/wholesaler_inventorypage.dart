// lib/pages/inventorypage.dart

import 'package:flutter/material.dart';
import 'dart:math';

import '../../dummydata/inventory_data.dart';
import '../../wholesaler_models/inventory_item_model.dart';
import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_add_product_dialog.dart';
import '../../wholesaler_widgets/wholesaler_inventory_table.dart'; 




class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  
  late List<InventoryItemModel> _currentInventory;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    // Initialize the list shown in the UI from the global data list
    _currentInventory = List.from(inventoryList); 
  }

  // --- LOGIC FUNCTIONS ---

  void _applySearch() {
    final term = _searchTerm.toLowerCase();
    
    // Filter the global list based on the search term
    final filtered = inventoryList.where((item) {
      return item.name.toLowerCase().contains(term) ||
             item.category.toLowerCase().contains(term);
    }).toList();

    setState(() {
      _currentInventory = filtered;
    });
  }

  void _updateSearchTerm(String value) {
    _searchTerm = value;
    _applySearch(); // **SEARCH LOGIC**
  }
  
  void _deleteProduct(String id) {
    setState(() {
      // Remove item from the global data list
      inventoryList.removeWhere((item) => item.id == id);
      
      // Reapply search to update the displayed list
      _applySearch(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product successfully deleted.')),
      );
    });
  }

  void _addProduct(Map<String, dynamic> newProductData) {
    // Generate unique ID using the imported function
    final newId = generateUniqueId(); 
    final newItem = InventoryItemModel(
      id: newId,
      name: newProductData['name'],
      category: newProductData['category'],
      price: newProductData['price'],
      stockRemain: newProductData['stockremain'],
      stocksold: newProductData['stocksold'],
      description: 'New product added via dashboard',
      imageUrl: '',
    );

    setState(() {
      inventoryList.add(newItem); // Add to the global list
      _applySearch(); // Refresh the view
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${newItem.name} to inventory!')),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddProductDialog(onAddProduct: _addProduct); 
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const MainSidebar(selectedPage: 'inventory'),

          Expanded(
            child: Container(
              color: const Color(0xFFF8F9FA), 
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Inventory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                          onChanged: _updateSearchTerm, 
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
                          backgroundColor: Colors.orange, 
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _showAddProductDialog, 
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- THE INVENTORY TABLE ---
                  Expanded(
                    child: InventoryTable(
                      inventory: _currentInventory, // Filtered list
                      onDelete: _deleteProduct,    // Delete callback
                    ),
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