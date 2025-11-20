// lib/widgets/retailer_search_bar.dart

import 'package:flutter/material.dart';

class RetailerSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch; // Callback for search term changes

  const RetailerSearchBar({
    super.key,
    required this.onSearch, // Required callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        onChanged: onSearch, // **Pass the text back to the parent on change**
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Search',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}