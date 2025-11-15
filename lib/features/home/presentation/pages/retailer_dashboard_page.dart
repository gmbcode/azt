import 'package:flutter/material.dart';
// Import the models we need for the hardcoded data
import '../models/order_model.dart';
import '../models/payment_status_model.dart';
// Import the widgets
import '../widgets/retailer_main_sidebar.dart';
import '../widgets/summary_card.dart';
import '../widgets/reusable_order_table.dart';
import '../widgets/responsive_layout.dart';

class RetailerDashboardPage extends StatefulWidget {
  const RetailerDashboardPage({super.key});

  @override
  State<RetailerDashboardPage> createState() => _RetailerDashboardPageState();
}

class _RetailerDashboardPageState extends State<RetailerDashboardPage> {
  // --- STATE ---
  // We will now hardcode the data as requested.
  // The _fetchDashboardData method is no longer needed for this.

  // 1. Hardcoded data for Summary Cards
  // These are the stats for the RETAILER
  final String _myRevenue = '\$12,340';
  final String _pendingOrders = '15';
  final String _lowStockItems = '8';
  final String _newCustomers = '3';

  // 2. Hardcoded data for the "Recent Orders" table
  final List<OrderModel> _recentOrders = [
    OrderModel(
      id: 'ord987',
      deliveryaddress: '123 Fake St',
      items: [],
      orderbyid: 'customerid_1', // This is the 'Customer' column
      orderfromid: 'my_retailer_id', // This is the retailer
      ordertime: '2025-11-14T09:00:00Z',
      paymentstatus: PaymentStatusModel(method: 'online', status: 'paid'),
      status: 'delivered', // This is the 'Status' column
      total: 100.00,
      trackinghistory: [],
    ),
    OrderModel(
      id: 'ord988',
      deliveryaddress: '456 Main Ave',
      items: [],
      orderbyid: 'customerid_2',
      orderfromid: 'my_retailer_id',
      ordertime: '2025-11-13T14:30:00Z',
      paymentstatus: PaymentStatusModel(method: 'online', status: 'paid'),
      status: 'processing',
      total: 1500.00,
      trackinghistory: [],
    ),
    OrderModel(
      id: 'ord989',
      deliveryaddress: '789 Other Blvd',
      items: [],
      orderbyid: 'customerid_1', // Same customer, different order
      orderfromid: 'my_retailer_id',
      ordertime: '2025-11-12T11:15:00Z',
      paymentstatus: PaymentStatusModel(method: 'offline', status: 'pending'),
      status: 'pending',
      total: 75.50,
      trackinghistory: [],
    ),
  ];

  // We still need state for the table selection
  Set<String> _selectedOrderIds = {};


  // --- Table Selection Logic (unchanged) ---
  void _onSelectAll(bool? selected) {
    setState(() {
      _selectedOrderIds = (selected ?? false)
          ? _recentOrders.map((o) => o.id).toSet()
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


  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobile(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[200], // Page background
      appBar: mobile ? AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ) : null,
      drawer: mobile ? const Drawer(
        child: RetailerMainSidebar(selectedPage: 'dashboard'),
      ) : null,
      body: Row(
        children: [
          // --- Sidebar (Desktop only) ---
          if (!mobile)
            const RetailerMainSidebar(selectedPage: 'dashboard'),

          // --- Main Content ---
          Expanded(
            child: SingleChildScrollView(
              // The main padding for the whole content area
              padding: EdgeInsets.all(mobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header (Desktop only, mobile uses AppBar) ---
                  if (!mobile)
                    const Text(
                      'Dashboard',
                      // Using the theme's style for the header
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  if (!mobile)
                    const SizedBox(height: 16),

                  // --- Summary Cards Layout ---
                  mobile 
                    ? Column(
                        children: [
                          SummaryCard(
                            title: 'My Revenue',
                            value: _myRevenue,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 16),
                          SummaryCard(
                            title: 'Pending Orders',
                            value: _pendingOrders,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          SummaryCard(
                            title: 'Low Stock Items',
                            value: _lowStockItems,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          SummaryCard(
                            title: 'New Customers',
                            value: _newCustomers,
                            color: Colors.purple,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'My Revenue',
                              value: _myRevenue,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SummaryCard(
                              title: 'Pending Orders',
                              value: _pendingOrders,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SummaryCard(
                              title: 'Low Stock Items',
                              value: _lowStockItems,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: SummaryCard(
                              title: 'New Customers',
                              value: _newCustomers,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),

                  const SizedBox(height: 20),

                  // --- Recent Orders ---
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // The ReusableOrderTable (wrapped for horizontal scrolling on mobile)
                  mobile 
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 800, // Fixed width for table on mobile
                          child: ReusableOrderTable(
                            orders: _recentOrders,
                            selectedOrderIds: _selectedOrderIds,
                            onSelectAll: _onSelectAll,
                            onSelectRow: _onSelectRow,
                            showCustomerIdColumn: true,
                            customerColumnTitle: "Customer",
                          ),
                        ),
                      )
                    : ReusableOrderTable(
                        orders: _recentOrders,
                        selectedOrderIds: _selectedOrderIds,
                        onSelectAll: _onSelectAll,
                        onSelectRow: _onSelectRow,
                        showCustomerIdColumn: true,
                        customerColumnTitle: "Customer",
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