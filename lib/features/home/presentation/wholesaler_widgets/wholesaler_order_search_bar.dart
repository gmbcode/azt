// lib/widgets/order_search_bar.dart

import 'package:flutter/material.dart';

class OrderSearchBar extends StatelessWidget {
  const OrderSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Changed from grey[200]
        borderRadius: BorderRadius.circular(8), // Less rounded
        border: Border.all(color: Colors.grey[300]!), // Added border
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search by Order ID, Customer...',
          border: InputBorder.none, // No underline
        ),
        // TODO: Implement search logic by adding an onChanged or onSubmitted handler
      ),
    );
  }
}