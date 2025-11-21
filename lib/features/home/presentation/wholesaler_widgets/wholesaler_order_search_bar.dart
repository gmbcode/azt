// lib/widgets/order_search_bar.dart

import 'package:flutter/material.dart';

class OrderSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const OrderSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      // The width is controlled by the parent widget for responsiveness
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2), // Compact internal padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        onChanged: onSearch, // Reports search term to parent
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search by Order ID, Customer...',
          border: InputBorder.none,
          isDense: true, // Makes the TextField more compact
        ),
      ),
    );
  }
}