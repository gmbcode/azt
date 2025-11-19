// lib/widgets/retailer_filter_tabs.dart

import 'package:flutter/material.dart';

class RetailerFilterTabs extends StatefulWidget {
  const RetailerFilterTabs({super.key});

  @override
  State<RetailerFilterTabs> createState() => _RetailerFilterTabsState();
}

class _RetailerFilterTabsState extends State<RetailerFilterTabs> {
  String _selectedTab = 'All Retailers';

  Widget _buildTab(String title) {
    final bool isSelected = _selectedTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = title;
          // TODO: Add logic to filter retailers based on the selected tab
        });
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