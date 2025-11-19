// lib/pages/retailer_customer_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/retailer_cubit.dart';
import '../../cubits/retailer_states.dart';
import '../../retailer_models/retailer_order_model.dart';
import '../../retailer_models/retailer_payment_status_model.dart';
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
  List<OrderModel> _allOrders = [];
  List<OrderModel> _filteredOrders = [];
  Set<String> _selectedOrderIds = {};
  String _selectedStatus = 'All';
  String _searchQuery = '';

  // These are the statuses the RETAILER controls
  final List<String> _filters = [
    'All', 'Pending', 'Confirmed', 'Processing', 'Delivered', 'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    context.read<RetailerCubit>().fetchCustomerOrders();
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

  void _updateSelectedOrdersStatus(String newStatus) {
    // This just updates the hardcoded data for now
    setState(() {
      // Update all items in the main list
      _allOrders = _allOrders.map((order) {
        if (_selectedOrderIds.contains(order.id)) {
          // In a real app, you'd create a new OrderModel with the
          // new status, but for this, we can't (they are final).
          // For demo purposes, we'll just clear selection.
          // A real update would re-fetch from Firebase.
          print("Updating ${order.id} to $newStatus");
        }
        return order;
      }).toList();
      
      _selectedOrderIds.clear(); // Clear selection
    });
    _filterAndSearch(); // Re-filter the list
    
    print("Updating ${_selectedOrderIds.length} orders to $newStatus");
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<RetailerCubit, RetailerState>(
      listener: (context, state) {
        if (state is RetailerCustomerOrdersLoaded) {
          setState(() {
            _allOrders = state.orders.map((order) => OrderModel(
              id: order.id,
              deliveryaddress: order.deliveryAddress,
              items: [],
              orderbyid: order.orderById,
              orderfromid: order.orderFromId,
              ordertime: order.orderTime,
              paymentstatus: PaymentStatusModel(
                method: order.paymentStatus.method,
                status: order.paymentStatus.status,
              ),
              status: order.status,
              total: order.total,
              trackinghistory: [],
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
          const RetailerMainSidebar(selectedPage: 'customer_orders'),

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
                  // --- Header & Filters (This is the top white box) ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      // We add the title *inside* this box
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

                  // --- Orders Table (This is the bottom white box) ---
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
                      // We use a Column + Expanded to contain the table
                      // AND the action bar below it.
                      child: Column(
                        children: [
                          Expanded(
                            // This container gives the table a fixed height
                            // for its internal scrolling to work.
                            child: ReusableOrderTable(
                              orders: _filteredOrders,
                              selectedOrderIds: _selectedOrderIds,
                              onSelectAll: _onSelectAll,
                              onSelectRow: _onSelectRow,
                              showCustomerIdColumn: true,
                              customerColumnTitle: "Customer ID", 
                            ),
                          ),
                          
                          // --- Action Bar for Selected Orders ---
                          // This bar will now "stick" to the bottom
                          // of the white box, thanks to the Column.
                          if (_selectedOrderIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0), // Space from table
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
      ),
    );
  }
}