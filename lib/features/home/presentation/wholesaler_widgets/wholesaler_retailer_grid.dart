// lib/widgets/retailer_grid.dart

import 'package:flutter/material.dart';
import 'wholesaler_retailer_card.dart';

// Dummy data based on your JSON structure.
// In a real app, you would fetch this from Firebase.
final List<Map<String, dynamic>> dummyRetailers = [
  {
    "address": "99 abc avenue",
    "businessname": "xyz store",
    "usertype": "retailer"
  },
  {
    "address": "123 Main St, NY",
    "businessname": "The Daily Market",
    "usertype": "retailer"
  },
  {
    "address": "456 Oak Rd, CA",
    "businessname": "Green Earth Organics",
    "usertype": "retailer"
  },
  {
    "address": "789 Pine Ln, TX",
    "businessname": "Angeles CA",
    "usertype": "retailer"
  },
  {
    "address": "101 Maple Dr",
    "businessname": "Jun Smith",
    "usertype": "retailer"
  },
  {
    "address": "202 Birch Ct",
    "businessname": "Lirath Angels",
    "usertype": "retailer"
  },
];

class RetailerGrid extends StatelessWidget {
  const RetailerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace 'dummyRetailers' with your live data stream
    final retailers = dummyRetailers;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250, // Max width of each card
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8, // Adjusts the height (Width / Height)
      ),
      itemCount: retailers.length,
      itemBuilder: (context, index) {
        final retailer = retailers[index];
        return RetailerCard(
          businessName: retailer['businessname'] ?? 'No Name',
          address: retailer['address'] ?? 'No Address',
        );
      },
    );
  }
}