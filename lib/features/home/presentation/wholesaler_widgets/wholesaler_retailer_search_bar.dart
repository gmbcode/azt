// lib/widgets/retailer_search_bar.dart

import 'package:flutter/material.dart';

class RetailerSearchBar extends StatelessWidget {
  const RetailerSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // Set a fixed width for the search bar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}