// lib/widgets/order_filter_chips.dart

import 'package:flutter/material.dart';

class OrderFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const OrderFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  // List of all available filters
  final List<String> _filters = const [ 
    'All',
    'Pending',
    'Processing', // JSON status: confirmed
    'Shipped',
    'Completed', // JSON status: delivered
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _filters.map((filter) {
        final bool isSelected = selectedFilter == filter;
        
        return Padding( // FIX: Removed 'const' here
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                onFilterSelected(filter); 
              }
            },
            backgroundColor: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[100],
            selectedColor: Colors.orange.withOpacity(0.2),
            labelStyle: TextStyle(
              color: isSelected ? Colors.orange[800] : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.orange : Colors.grey[300]!,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}