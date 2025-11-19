// lib/widgets/order_filter_chips.dart

import 'package:flutter/material.dart';

class OrderFilterChips extends StatefulWidget {
  const OrderFilterChips({super.key});

  @override
  State<OrderFilterChips> createState() => _OrderFilterChipsState();
}

class _OrderFilterChipsState extends State<OrderFilterChips> {
  // This variable will hold the currently selected filter
  String _selectedFilter = 'All';

  // List of all available filters
  final List<String> _filters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Completed',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _filters.map((filter) {
        final bool isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (bool selected) {
              if (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                // TODO: Add logic here to actually filter your list of orders
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