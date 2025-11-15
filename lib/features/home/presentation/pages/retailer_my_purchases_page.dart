import 'package:flutter/material.dart';
import '../models/order_model.dart';
// We need this for the dummy data
import '../models/payment_status_model.dart'; 
import '../widgets/retailer_main_sidebar.dart';
import '../widgets/reusable_order_table.dart';
import '../widgets/reusable_search_bar.dart';
import '../widgets/status_filter_chips.dart';

class RetailerMyPurchasesPage extends StatefulWidget {
  const RetailerMyPurchasesPage({super.key});

  @override
  State<RetailerMyPurchasesPage> createState() => _RetailerMyPurchasesPageState();
}

class _RetailerMyPurchasesPageState extends State<RetailerMyPurchasesPage> {
  // --- STATE ---
  List<OrderModel> _allPurchases = [];
  List<OrderModel> _filteredPurchases = [];
  Set<String> _selectedPurchaseIds = {};
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All', 'Pending', 'Confirmed', 'Shipped', 'Delivered', 'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  void _fetchPurchases() {
    // --- HARDCODED DATA ADDED ---
    final List<OrderModel> dummyPurchases = [
      OrderModel(
        id: 'WHO-1001', deliveryaddress: 'My Retail Store, 123 Main St', items: [],
        orderbyid: 'my_retailer_id', orderfromid: 'wholesaler_1',
        ordertime: '2025-11-20T09:30:00Z',
        paymentstatus: PaymentStatusModel(method: 'online', status: 'paid'),
        status: 'delivered', total: 450.0, trackinghistory: [],
      ),
      OrderModel(
        id: 'WHO-1002', deliveryaddress: 'My Retail Store, 123 Main St', items: [],
        orderbyid: 'my_retailer_id', orderfromid: 'wholesaler_2',
        ordertime: '2025-11-22T14:00:00Z',
        paymentstatus: PaymentStatusModel(method: 'online', status: 'paid'),
        status: 'shipped', total: 120.0, trackinghistory: [],
      ),
       OrderModel(
        id: 'WHO-1003', deliveryaddress: 'My Retail Store, 123 Main St', items: [],
        orderbyid: 'my_retailer_id', orderfromid: 'wholesaler_1',
        ordertime: '2025-11-25T11:00:00Z',
        paymentstatus: PaymentStatusModel(method: 'offline', status: 'pending'),
        status: 'pending', total: 800.0, trackinghistory: [],
      ),
    ];
    
    setState(() {
      _allPurchases = dummyPurchases;
      _filteredPurchases = _allPurchases;
    });
  }

  void _filterAndSearch() {
    setState(() {
      _filteredPurchases = _allPurchases.where((purchase) {
        final bool matchesStatus = _selectedStatus == 'All' ||
            purchase.status.toLowerCase() == _selectedStatus.toLowerCase();
        final bool matchesSearch = _searchQuery.isEmpty ||
            purchase.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            purchase.orderfromid.toLowerCase().contains(_searchQuery.toLowerCase());
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
      _selectedPurchaseIds = (selected ?? false)
          ? _filteredPurchases.map((o) => o.id).toSet()
          : {};
    });
  }

  void _onSelectRow(String orderId, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selectedPurchaseIds.add(orderId);
      } else {
        _selectedPurchaseIds.remove(orderId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'my_purchases'),

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
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Text(
                          'My Purchases',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        ReusableSearchBar(
                          hintText: 'Search by Order ID, Wholesaler ID...',
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
                  const SizedBox(height: 24), // Space between boxes

                  // --- Purchases Table (This is the bottom white box) ---
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
                      // This container gives the ReusableOrderTable a fixed
                      // height, which allows its internal vertical scrolling
                      // to work without errors.
                      child: ReusableOrderTable(
                        orders: _filteredPurchases,
                        selectedOrderIds: _selectedPurchaseIds,
                        onSelectAll: _onSelectAll,
                        onSelectRow: _onSelectRow,
                        showCustomerIdColumn: true,
                        customerColumnTitle: "Wholesaler ID", 
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