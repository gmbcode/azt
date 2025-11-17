// lib/pages/retailer_customers_page.dart

import 'package:flutter/material.dart';

import '../../retailer_models/retailer_customer_model.dart';
import '../../retailer_widgets/retailer_customer_card.dart';
import '../../retailer_widgets/retailer_main_sidebar.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';
import '../../retailer_widgets/retailer_status_filter_chips.dart';

class RetailerCustomersPage extends StatefulWidget {
  const RetailerCustomersPage({super.key});

  @override
  State<RetailerCustomersPage> createState() => _RetailerCustomersPageState();
}

class _RetailerCustomersPageState extends State<RetailerCustomersPage> {
  // --- STATE ---
  List<CustomerModel> _allCustomers = [];
  List<CustomerModel> _filteredCustomers = [];
  String _searchQuery = '';
  // For the "All Customers" / "New Signups" tabs
  String _selectedTab = 'All Customers'; 
  final List<String> _tabs = ['All Customers', 'New Signups'];

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _fetchCustomers() {
    // --- HARDCODED DATA ADDED ---
    final List<CustomerModel> dummyCustomers = [
       CustomerModel(
        id: 'cust1', email: 'john@example.com', username: 'John Smith',
        usertype: 'consumer', address: '123 Main St, NY',
      ),
      CustomerModel(
        id: 'cust2', email: 'daily@market.com', username: 'The Daily Market',
        usertype: 'consumer', address: '456 Oak Rd, CA',
      ),
      CustomerModel(
        id: 'cust3', email: 'green@earth.com', username: 'Green Earth Organics',
        usertype: 'consumer', address: '789 Pine Ln, TX',
      ),
       CustomerModel(
        id: 'cust4', email: 'lira@example.com', username: 'Lirath Angels',
        usertype: 'consumer', address: '202 Birch Ct',
      ),
       CustomerModel(
        id: 'cust5', email: 'angeles@ca.com', username: 'Angeles CA',
        usertype: 'consumer', address: '999 Maple Dr',
      ),
    ];

    setState(() {
      _allCustomers = dummyCustomers;
      _filteredCustomers = _allCustomers;
    });
  }

  void _runFilters() {
    // This now filters by BOTH search and tab
    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        // Tab Filter
        // TODO: Add real logic for "New Signups"
        final bool matchesTab = _selectedTab == 'All Customers' || 
                                (_selectedTab == 'New Signups' && customer.username.contains("Lirath")); // Example filter

        // Search Filter
        final bool matchesSearch = _searchQuery.isEmpty ||
            customer.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            customer.email.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesTab && matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _runFilters();
  }

  void _onTabSelected(String tab) {
    _selectedTab = tab;
    _runFilters();
  }

  void _onViewProfile(CustomerModel customer) {
    // TODO: Implement navigation to a customer profile page
    print("Viewing profile for: ${customer.username}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Row(
        children: [
          // --- Sidebar ---
          const RetailerMainSidebar(selectedPage: 'customers'),

          // --- Main Content ---
          //
          // --- THIS IS THE LAYLayout FIX ---
          //
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header & Filters (This is the top white box) ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        const Text(
                          'My Customers',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        // Search Bar
                        ReusableSearchBar(
                          hintText: 'Search by username, email...',
                          onChanged: _onSearchChanged,
                        ),
                        const SizedBox(height: 16),
                        // Filter Tabs
                        StatusFilterChips(
                          filters: _tabs,
                          selectedFilter: _selectedTab,
                          onSelected: _onTabSelected,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Customer Grid (This is the bottom box) ---
                  //
                  // This Expanded widget forces the grid to fill
                  // all the remaining empty space.
                  //
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(0), // Padding is handled by the page
                      // GridView.builder automatically scrolls,
                      // so we don't need a SingleChildScrollView.
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280, // A good width for these cards
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.8, // Taller cards
                      ),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];
                        return CustomerCard(
                          customer: customer,
                          onViewProfile: () => _onViewProfile(customer),
                        );
                      },
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