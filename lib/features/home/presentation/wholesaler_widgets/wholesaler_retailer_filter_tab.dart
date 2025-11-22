// lib/widgets/retailer_filter_tabs.dart

import 'package:flutter/material.dart';

class RetailerFilterTabs extends StatelessWidget {
  final String selectedTab; // The currently active tab
  final ValueChanged<String> onTabSelected; // Callback to update parent state

  const RetailerFilterTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  Widget _buildTab(String title) {
    final bool isSelected = selectedTab == title;
    return InkWell(
      onTap: () {
        onTabSelected(title); // **Update parent state on tap**
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.orange : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.orange : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTab('All Retailers'),
        const SizedBox(width: 16),
        _buildTab('New Signups'),
      ],
    );
  }
}