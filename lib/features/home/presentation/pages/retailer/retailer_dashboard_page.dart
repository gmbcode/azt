import 'package:flutter/material.dart';
// Should already be there, but verify:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';
import '../../cubits/retailer_cubit.dart';
import '../../cubits/retailer_states.dart';
import '../../retailer_models/retailer_order_model.dart';
import '../../retailer_models/retailer_payment_status_model.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import '../../retailer_widgets/retailer_reusable_order_table.dart';
import '../../retailer_widgets/retailer_summary_card.dart';


class RetailerDashboardPage extends StatefulWidget {
  const RetailerDashboardPage({super.key});

  @override
  State<RetailerDashboardPage> createState() => _RetailerDashboardPageState();
}

class _RetailerDashboardPageState extends State<RetailerDashboardPage> {
  // --- STATE ---
  // Summary card stats (calculated from fetched data)
  String _myRevenue = '\$0';
  String _pendingOrders = '0';
  String _lowStockItems = '0';
  String _newCustomers = '0';

  // Recent orders from RTDB
  List<OrderModel> _recentOrders = [];

  // We still need state for the table selection
  Set<String> _selectedOrderIds = {};

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  void _fetchDashboardData() {
    // Fetch customer orders from RTDB
    context.read<RetailerCubit>().fetchCustomerOrders();
    // We could also fetch inventory to calculate low stock items
    // context.read<RetailerCubit>().fetchInventory();
  }


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
    return BlocListener<RetailerCubit, RetailerState>(
      listener: (context, state) {
        if (state is RetailerCustomerOrdersLoaded) {
          setState(() {
            _recentOrders = state.orders.map((order) => OrderModel(
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

            // Calculate summary stats from orders
            final revenue = _recentOrders.fold<double>(0, (sum, order) => sum + order.total);
            _myRevenue = '\$${revenue.toStringAsFixed(2)}';
            _pendingOrders = _recentOrders.where((o) => o.status.toLowerCase() == 'pending').length.toString();
            // For now, we'll keep these as placeholder values
            _lowStockItems = '0';
            _newCustomers = _recentOrders.map((o) => o.orderbyid).toSet().length.toString();
          });
        } else if (state is RetailerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[200], // Page background
        body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'dashboard'),

          // --- Main Content ---
          Expanded(
            child: SingleChildScrollView(
              // The main padding for the whole content area
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  const Text(
                    'Dashboard',
                    // Using the theme's style for the header
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  // --- FIX 1: Reduced space ---
                  const SizedBox(height: 16), // Was 24

                  // --- Summary Cards Layout (Single Row) ---
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'My Revenue',
                          value: _myRevenue,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 20), // Spacing between cards
                      Expanded(
                        child: SummaryCard(
                          title: 'Pending Orders',
                          value: _pendingOrders,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 20), // Spacing between cards
                      Expanded(
                        child: SummaryCard(
                          title: 'Low Stock Items',
                          value: _lowStockItems,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 20), // Spacing between cards
                      Expanded(
                        child: SummaryCard(
                          title: 'New Customers',
                          value: _newCustomers,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  // --- FIX 2: Reduced space ---
                  const SizedBox(height: 20), // Was 24

                  // --- Recent Orders ---
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // The ReusableOrderTable
                  ReusableOrderTable(
                    orders: _recentOrders, // Pass the hardcoded data
                    selectedOrderIds: _selectedOrderIds,
                    onSelectAll: _onSelectAll,
                    onSelectRow: _onSelectRow,
                    showCustomerIdColumn: true,
                    customerColumnTitle: "Customer", // Rename column
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