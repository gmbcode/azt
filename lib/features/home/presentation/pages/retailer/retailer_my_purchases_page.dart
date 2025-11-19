import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azt/features/auth/presentation/cubits/auth_cubit.dart';

import '../../../data/retailer_repo.dart';
import '../../retailer_models/retailer_order_model.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import '../../retailer_widgets/retailer_reusable_order_table.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';
import '../../retailer_widgets/retailer_status_filter_chips.dart';


class RetailerMyPurchasesPage extends StatefulWidget {
  const RetailerMyPurchasesPage({super.key});

  @override
  State<RetailerMyPurchasesPage> createState() => _RetailerMyPurchasesPageState();
}

class _RetailerMyPurchasesPageState extends State<RetailerMyPurchasesPage> {
  // --- STATE ---
  final RetailerRepository _repo = RetailerRepository();
  bool _isLoading = true;

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

  Future<void> _fetchPurchases() async {
    final user = context.read<AuthCubit>().currentUser;
    if (user == null) return;
    
    setState(() => _isLoading = true);

    // FETCH orders where orderBy == my UID
    final purchases = await _repo.getMyPurchases(user.uid);

    if (mounted) {
      setState(() {
        _allPurchases = purchases;
        _filteredPurchases = purchases;
        _isLoading = false;
      });
      _filterAndSearch();
    }
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
                  const SizedBox(height: 24),

                  // --- Table ---
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
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