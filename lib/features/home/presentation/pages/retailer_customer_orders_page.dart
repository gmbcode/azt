// lib/pages/retailer_customer_orders_page.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';
// We need this for the dummy data
import '../models/payment_status_model.dart'; 
import '../widgets/retailer_main_sidebar.dart';
import '../widgets/reusable_order_table.dart';
import '../widgets/reusable_search_bar.dart';
import '../widgets/status_filter_chips.dart';
import '../widgets/responsive_layout.dart';

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
    // --- HARDCODED DATA ADDED ---
    // These are orders from the retailer's *own* customers
    final List<OrderModel> dummyOrders = [
      OrderModel(
        id: 'ord-cust-001',
        deliveryaddress: '123 Customer Lane',
        items: [],
        orderbyid: 'customer_1', // This is the 'Customer ID'
        orderfromid: 'my_retailer_id', // This is me
        ordertime: '2025-11-15T10:00:00Z',
        paymentstatus: PaymentStatusModel(method: 'online', status: 'paid'),
        status: 'pending',
        total: 55.0,
        trackinghistory: [],
      ),
      OrderModel(
        id: 'ord-cust-002',
        deliveryaddress: '456 Client Ave',
        items: [],
        orderbyid: 'customer_2',
        orderfromid: 'my_retailer_id',
        ordertime: '2025-11-14T16:20:00Z',
        paymentstatus: PaymentStatusModel(method: 'online', status: 'paid'),
        status: 'confirmed',
        total: 12.50,
        trackinghistory: [],
      ),
      OrderModel(
        id: 'ord-cust-003',
        deliveryaddress: '789 Shopper St',
        items: [],
        orderbyid: 'customer_3',
        orderfromid: 'my_retailer_id',
        ordertime: '2025-11-13T08:05:00Z',
        paymentstatus: PaymentStatusModel(method: 'offline', status: 'pending'),
        status: 'delivered',
        total: 89.99,
        trackinghistory: [],
      ),
    ];
    
    setState(() {
      _allOrders = dummyOrders;
      _filteredOrders = _allOrders;
    });
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
    final bool mobile = isMobile(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: mobile ? AppBar(
        title: const Text('Customer Orders'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ) : null,
      drawer: mobile ? const Drawer(
        child: RetailerMainSidebar(selectedPage: 'customer_orders'),
      ) : null,
      body: Row(
        children: [
          // --- Sidebar (Desktop only) ---
          if (!mobile)
            const RetailerMainSidebar(selectedPage: 'customer_orders'),

          // --- Main Content ---
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(mobile ? 16 : 24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!mobile)
                          const Text(
                            'Customer Orders',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        if (!mobile)
                          const SizedBox(height: 24),
                        ReusableSearchBar(
                          hintText: 'Search by Order ID, Customer ID...',
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: StatusFilterChips(
                            filters: _filters,
                            selectedFilter: _selectedStatus,
                            onSelected: _onStatusSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: mobile ? 16 : 24),

                  // --- Orders Table (This is the bottom white box) ---
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
                            child: mobile 
                              ? SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: 800,
                                    child: ReusableOrderTable(
                                      orders: _filteredOrders,
                                      selectedOrderIds: _selectedOrderIds,
                                      onSelectAll: _onSelectAll,
                                      onSelectRow: _onSelectRow,
                                      showCustomerIdColumn: true,
                                      customerColumnTitle: "Customer ID", 
                                    ),
                                  ),
                                )
                              : ReusableOrderTable(
                                  orders: _filteredOrders,
                                  selectedOrderIds: _selectedOrderIds,
                                  onSelectAll: _onSelectAll,
                                  onSelectRow: _onSelectRow,
                                  showCustomerIdColumn: true,
                                  customerColumnTitle: "Customer ID", 
                                ),
                          ),
                          
                          // --- Action Bar for Selected Orders ---
                          if (_selectedOrderIds.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: mobile 
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        '${_selectedOrderIds.length} selected',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _updateSelectedOrdersStatus('confirmed'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                        child: const Text('Confirm'),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _updateSelectedOrdersStatus('processing'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
                                        child: const Text('Process'),
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () => _updateSelectedOrdersStatus('delivered'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        child: const Text('Mark as Delivered'),
                                      ),
                                    ],
                                  )
                                : Row(
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