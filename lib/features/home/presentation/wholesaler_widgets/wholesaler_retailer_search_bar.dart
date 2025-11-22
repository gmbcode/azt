// lib/widgets/retailer_search_bar.dart
import 'package:flutter/material.dart';

class RetailerSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const RetailerSearchBar({
    super.key,
    required this.onSearch, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Changed from fixed width to constraints to allow shrinking
      constraints: const BoxConstraints(maxWidth: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        onChanged: onSearch,
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