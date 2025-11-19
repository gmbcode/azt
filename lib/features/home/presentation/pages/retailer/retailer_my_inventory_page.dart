import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';

import '../../../data/retailer_repo.dart';
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
  final RetailerRepository _repo = RetailerRepository();
  bool _isLoading = true;

  List<RetailerInventoryItemModel> _allItems = [];
  List<RetailerInventoryItemModel> _filteredItems = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    // Get current User ID from Cubit
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    // FETCH FROM API using UID
    final items = await _repo.getMyInventory(user.uid);

    if (mounted) {
      setState(() {
        _allItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
      // Apply any existing search filter
      _filterAndSearch(); 
    }
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
    // TODO: Implement Edit Dialog (similar to Add Dialog but pre-filled)
    print("Editing: ${item.name}");
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
              // API CALL
              final user = context.read<AuthCubit>().currentUser;
              if(user != null) {
                 _repo.deleteInventoryItem(user.uid, item.id).then((_) {
                   _fetchInventory(); // Refresh list from DB
                 });
                 Navigator.of(context).pop();
              }
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
          onSave: (newItem) async {
             final user = context.read<AuthCubit>().currentUser;
             if (user != null) {
               // API CALL
               await _repo.addInventoryItem(user.uid, newItem);
               _fetchInventory(); // Refresh list
             }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'my_inventory'),

          // --- Main Content ---
          Expanded(
            child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
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
                              onPressed: _onAddNewItem,
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
                  const SizedBox(height: 24),

                  // --- Table ---
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InventoryTable(
                        items: _filteredItems,
                        onEdit: _onEditItem,
                        onDelete: _onDeleteItem,
                      ),
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
}