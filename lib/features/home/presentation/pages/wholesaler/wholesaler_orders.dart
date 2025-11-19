// lib/pages/orders.dart

import 'package:flutter/material.dart';

import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_order_filter_chips.dart';
import '../../wholesaler_widgets/wholesaler_order_search_bar.dart';
import '../../wholesaler_widgets/wholesaler_order_table.dart';



class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // STATE VARIABLES
  List<OrderModel> _currentOrders = []; // The list shown in the table
  String _selectedFilter = 'All';
  String _searchTerm = '';
  // Map to hold selection state: {orderId: isSelected}
  Map<String, bool> _selectionMap = {}; 

  @override
  void initState() {
    super.initState();
    // Initialize state with global data
    _currentOrders.addAll(allOrders); 
    _selectionMap = {for (var order in allOrders) order.id: false};
  }

  // --- LOGIC FUNCTIONS ---

  void _applyFiltersAndSearch() {
    List<OrderModel> filteredList = allOrders;

    // 1. Apply Filter
    if (_selectedFilter != 'All') {
      filteredList = filteredList.where((order) {
        return order.orderStatus == _selectedFilter;
      }).toList();
    }
    
    // 2. Apply Search
    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      filteredList = filteredList.where((order) {
        return order.id.toLowerCase().contains(term) ||
               order.customerId.toLowerCase().contains(term);
      }).toList();
    }
    
    setState(() {
      _currentOrders = filteredList;
    });
  }

  void _updateFilter(String newFilter) {
    setState(() {
      _selectedFilter = newFilter;
      _applyFiltersAndSearch();
    });
  }

  void _updateSearchTerm(String newTerm) {
    // Debouncing logic could be added here for performance
    setState(() {
      _searchTerm = newTerm;
      _applyFiltersAndSearch();
    });
  }

  // FIX 2: Corrected function signature
  void _onOrderSelectionChanged(String orderId, bool isSelected) {
    setState(() {
      _selectionMap[orderId] = isSelected;
    });
  }

  void _onSelectAll(bool isSelected) {
    setState(() {
      // Apply selection only to the currently visible orders
      for (var order in _currentOrders) {
        _selectionMap[order.id] = isSelected;
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      // Get the IDs of the selected orders
      final selectedIds = _selectionMap.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toSet();
      
      // Remove selected orders from the global list (allOrders)
      allOrders.removeWhere((order) => selectedIds.contains(order.id));
      
      // Re-initialize selection map and apply filters to refresh the view
      _selectionMap = {for (var order in allOrders) order.id: false};
      _applyFiltersAndSearch(); // Recalculate _currentOrders based on new allOrders list

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedIds.length} orders deleted.')),
      );
    });
  }
  
  // Helper widget for the bottom "Bulk Actions" row
  Widget _buildBulkActions(bool hasSelected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Delete Selected Button
            TextButton.icon(
              icon: Icon(Icons.delete, size: 18, color: hasSelected ? Colors.red : Colors.grey),
              label: Text(
                'Delete Selected',
                style: TextStyle(color: hasSelected ? Colors.red : Colors.grey),
              ),
              onPressed: hasSelected ? _deleteSelected : null, // **Delete Logic**
            ),
            const SizedBox(width: 20),
            // Export Button (Placeholder)
            TextButton.icon(
              icon: Icon(Icons.upload_file, size: 16, color: Colors.grey[700]),
              label: Text('Export to CSV', style: TextStyle(color: Colors.grey[700])),
              onPressed: () { /* Export logic */ },
            ),
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

  @override
  Widget build(BuildContext context) {
    final bool hasSelected = _currentOrders.any((order) => _selectionMap[order.id] == true);
    final bool allSelected = _currentOrders.isNotEmpty && _currentOrders.every((order) => _selectionMap[order.id] == true);

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      body: Row(
        children: [
          const MainSidebar(selectedPage: 'orders'),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Orders", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Filter Chips - Pass callbacks and state
                    OrderFilterChips(
                      selectedFilter: _selectedFilter,
                      onFilterSelected: _updateFilter,
                    ),
                    const SizedBox(height: 20),

                    // Search Bar - Pass callback
                    OrderSearchBar(onSearch: _updateSearchTerm),
                    const SizedBox(height: 20),

                    // Order Table - Pass filtered list, selection map, and callbacks
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: OrderTable(
                            orders: _currentOrders,
                            selectionMap: _selectionMap,
                            onOrderSelectionChanged: _onOrderSelectionChanged,
                            onSelectAll: _onSelectAll,
                            allSelected: allSelected,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bulk Actions & Pagination - Pass state for button enablement
                    _buildBulkActions(hasSelected),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}