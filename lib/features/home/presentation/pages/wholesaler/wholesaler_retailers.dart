// lib/pages/retailers.dart

import 'package:flutter/material.dart';

import '../../wholesaler_models/retailer_model.dart';
import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_retailer_filter_tab.dart';
import '../../wholesaler_widgets/wholesaler_retailer_grid.dart';
import '../../wholesaler_widgets/wholesaler_retailer_search_bar.dart';


class RetailersPage extends StatefulWidget {
  const RetailersPage({super.key});

  @override
  State<RetailersPage> createState() => _RetailersPageState();
}

class _RetailersPageState extends State<RetailersPage> {
  // 1. STATE VARIABLES
  String _selectedTab = 'All Retailers'; // Holds the current filter tab
  String _searchTerm = ''; // Holds the current search term
  late List<RetailerModel> _allRetailers; // The full list of retailers

  @override
  void initState() {
    super.initState();
    // Initialize the list of all retailers from the dummy data
    _allRetailers = dummyRetailerData;
  }

  // 2. LOGIC TO FILTER RETAILERS
  List<RetailerModel> _getFilteredRetailers() {
    // Apply tab filter
    final tabFiltered = _allRetailers.where((retailer) {
      if (_selectedTab == 'New Signups') {
        return retailer.isNewSignup;
      }
      return true; // 'All Retailers' tab returns all
    }).toList();

    // Apply search filter (case-insensitive)
    if (_searchTerm.isEmpty) {
      return tabFiltered;
    }

    final lowerCaseSearchTerm = _searchTerm.toLowerCase();
    return tabFiltered.where((retailer) {
      return retailer.businessName.toLowerCase().contains(lowerCaseSearchTerm) ||
             retailer.address.toLowerCase().contains(lowerCaseSearchTerm);
    }).toList();
  }

  // 3. CALLBACK FUNCTIONS (passed to child widgets)
  void _updateSearchTerm(String newTerm) {
    setState(() {
      _searchTerm = newTerm;
    });
  }

  void _updateSelectedTab(String newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }

  // Helper widget for the bottom pagination controls
  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios, size: 16), onPressed: () {}),
        const Text('1'),
        IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 16), onPressed: () {}),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRetailers = _getFilteredRetailers();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
      body: Row(
        children: [
          // 1. The Sidebar
          const MainSidebar(selectedPage: 'retailers'),

          // 2. The Main Content Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Title and Search Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Retailers",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Pass the search update function to the search bar
                        RetailerSearchBar(onSearch: _updateSearchTerm),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Tabs
                    // Pass the update function and current selection to the filter tabs
                    RetailerFilterTabs(
                      selectedTab: _selectedTab,
                      onTabSelected: _updateSelectedTab,
                    ),

                    // Divider Line
                    const Divider(height: 21, color: Color.fromARGB(255, 230, 230, 230)),

                    // Retailer Grid (takes up the remaining space)
                    // Pass the filtered list to the grid
                    Expanded(
                      child: RetailerGrid(retailers: filteredRetailers),
                    ),

                    // Pagination Controls
                    _buildPaginationControls(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}