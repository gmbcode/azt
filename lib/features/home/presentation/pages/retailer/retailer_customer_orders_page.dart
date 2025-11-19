import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';

import '../../../data/retailer_repo.dart';
import '../../retailer_models/retailer_order_model.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import '../../retailer_widgets/retailer_reusable_order_table.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';
import '../../retailer_widgets/retailer_status_filter_chips.dart';

class RetailerCustomerOrdersPage extends StatefulWidget {
  const RetailerCustomerOrdersPage({super.key});

  @override
  State<RetailerCustomerOrdersPage> createState() => _RetailerCustomerOrdersPageState();
}

class _RetailerCustomerOrdersPageState extends State<RetailerCustomerOrdersPage> {
  // --- STATE ---
  final RetailerRepository _repo = RetailerRepository();
  bool _isLoading = true;

  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  Set<String> _selectedOrderIds = {};
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All', 'Pending', 'Confirmed', 'Processing', 'Delivered', 'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;
    
    setState(() => _isLoading = true);

    // FETCH orders where orderFromId == my UID
    final orders = await _repo.getIncomingOrders(user.uid);

    if (mounted) {
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
      // Re-apply filters if needed
      _filterAndSearch();
    }
  }

  void _filterAndSearch() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final bool matchesStatus = _selectedStatus == 'All' ||
            order.status.toLowerCase() == _selectedStatus.toLowerCase();

        final bool matchesSearch = _searchQuery.isEmpty ||
            order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            order.orderbyid.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  void _onStatusSelected(String status) {
    setState(() { _selectedStatus = status; });
    _filterAndSearch();
  }

  void _onSearchChanged(String query) {
    setState(() { _searchQuery = query; });
    _filterAndSearch();
  }

  void _onSelectAll(bool? selected) {
    setState(() {
      _selectedOrderIds = (selected ?? false)
          ? _filteredOrders.map((o) => o.id).toSet()
          : {};
    });
  }

  void _onSelectRow(String orderId, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selectedOrderIds.add(orderId);
      } else {
        _selectedOrderIds.remove(orderId);
      }
    });
  }

  // NOTE: This function handles UI updates only for now. 
  // You'll need to add an `updateOrderStatus` method to RetailerRepository to persist changes.
  void _updateSelectedOrdersStatus(String newStatus) {
    setState(() {
      _allOrders = _allOrders.map((order) {
        if (_selectedOrderIds.contains(order.id)) {
          // NOTE: OrderModel is usually immutable. 
          // Ideally, clone it or refetch data after API update.
          print("Updating ${order.id} to $newStatus");
        }
        return order;
      }).toList();
      
      _selectedOrderIds.clear(); 
    });
    _filterAndSearch(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          const RetailerMainSidebar(selectedPage: 'customer_orders'),

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
                        const Text(
                          'Customer Orders',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ReusableSearchBar(
                          hintText: 'Search by Order ID, Customer ID...',
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 16),
                        StatusFilterChips(
                          filters: _filters,
                          selectedFilter: _selectedStatus,
                          onSelected: _onStatusSelected,
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
                      child: Column(
                        children: [
                          Expanded(
                            child: ReusableOrderTable(
                              orders: _filteredOrders,
                              selectedOrderIds: _selectedOrderIds,
                              onSelectAll: _onSelectAll,
                              onSelectRow: _onSelectRow,
                              showCustomerIdColumn: true,
                              customerColumnTitle: "Customer ID", 
                            ),
                          ),
                          
                          if (_selectedOrderIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Row(
                                children: [
                                  Text(
                                    '${_selectedOrderIds.length} selected',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () => _updateSelectedOrdersStatus('confirmed'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    child: const Text('Confirm'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _updateSelectedOrdersStatus('processing'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                                    child: const Text('Process'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () => _updateSelectedOrdersStatus('delivered'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text('Mark as Delivered'),
                                  ),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}