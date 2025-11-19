import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/retailer_cubit.dart';
import '../../cubits/retailer_states.dart';
import '../../retailer_models/retailer_inventory_item_model.dart';
import '../../retailer_widgets/retailer_add_inventory_dialog.dart';
import '../../retailer_widgets/retailer_inventory_table.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';


class RetailerMyInventoryPage extends StatefulWidget {
  const RetailerMyInventoryPage({super.key});

  @override
  State<RetailerMyInventoryPage> createState() => _RetailerMyInventoryPageState();
}

class _RetailerMyInventoryPageState extends State<RetailerMyInventoryPage> {
  // --- STATE ---
  List<RetailerInventoryItemModel> _allItems = [];
  List<RetailerInventoryItemModel> _filteredItems = [];
  String _searchQuery = '';
  // (State logic is unchanged)

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  void _fetchInventory() {
    // Fetch inventory from RTDB using the Cubit
    context.read<RetailerCubit>().fetchInventory();
  }

  void _filterAndSearch() {
    setState(() {
      _filteredItems = _allItems.where((item) {
        return _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query; 
    _filterAndSearch();
  }

  void _onEditItem(RetailerInventoryItemModel item) {
    print("Editing: ${item.name}");
    // TODO: Implement Edit Dialog
  }

  void _onDeleteItem(RetailerInventoryItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<RetailerCubit>().deleteInventoryItem(item.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _onAddNewItem() {
    showDialog(
      context: context,
      builder: (context) {
        return AddInventoryDialog(
          onSave: (newItem) {
            setState(() {
              _allItems.add(newItem);
              _filterAndSearch();
            });
            print("Added new item: ${newItem.name}");
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RetailerCubit, RetailerState>(
      listener: (context, state) {
        if (state is RetailerInventoryLoaded) {
          setState(() {
            _allItems = state.items.map((item) => RetailerInventoryItemModel(
              id: item.id,
              category: item.category,
              description: item.description,
              imageUrl: item.imageUrl,
              name: item.name,
              price: item.price,
              stockremain: item.stockremain,
              stocksold: item.stocksold,
            )).toList();
            _filterAndSearch();
          });
        } else if (state is RetailerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'my_inventory'),

          // --- Main Content ---
          //
          // --- THIS IS THE LAYOUT FIX ---
          //
          Expanded(
            // We use a Column to lay out the header and the table
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header & Actions (This is the top white box) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'My Inventory',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            ElevatedButton.icon(
                              onPressed: _onAddNewItem, // This now works!
                              icon: const Icon(Icons.add),
                              label: const Text('Add New Item'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ReusableSearchBar(
                          hintText: 'Search by Product Name, Category...',
                          onChanged: _onSearchChanged,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Space between boxes

                  // --- Inventory Table (This is the bottom white box) ---
                  //
                  // This Expanded widget forces the container
                  // and table to fill ALL remaining empty space.
                  //
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // The InventoryTable widget is now the direct child.
                      // This container gives it the fixed height it needs
                      // for its internal vertical scrolling to work.
                      child: InventoryTable(
                        items: _filteredItems,
                        onEdit: _onEditItem,
                        onDelete: _onDeleteItem, // This now works!
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}