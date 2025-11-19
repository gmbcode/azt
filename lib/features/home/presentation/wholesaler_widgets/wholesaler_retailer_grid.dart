// lib/widgets/retailer_grid.dart

import 'package:flutter/material.dart';

import '../wholesaler_models/retailer_model.dart';
import 'wholesaler_retailer_card.dart';

// Declare the top-level map as Map<String, dynamic> for better type safety
final Map<String, dynamic> retailerJsonData = {
  "R001": {
    "address": "99 abc avenue",
    "businessname": "xyz store", 
    "inventory": { "dummy": { "name": "apples" } },
    "usertype": "retailer"
  },
  "R002": {
    "address": "123 Main St, NY",
    "businessname": "The Daily Market",
    "inventory": { "dummy": { "name": "oranges" } },
    "usertype": "retailer"
  },
  "R003": {
    "address": "456 Oak Rd, CA",
    "businessname": "Green Earth Organics",
    "inventory": {},
    "usertype": "retailer"
  },
  "R004": {
    "address": "789 Pine Ln, TX",
    "businessname": "Angeles Hardware", 
    "inventory": {},
    "usertype": "retailer"
  },
  "R005": {
    "address": "101 Maple Dr",
    "businessname": "Jun Smith Fresh",
    "inventory": {},
    "usertype": "retailer"
  },
  "R006": {
    "address": "202 Birch Ct",
    "businessname": "Lirath Angels Supplies",
    "inventory": {},
    "usertype": "retailer"
  },
};

// Use the map's entries and explicitly cast the inner map to Map<String, dynamic>
final List<RetailerModel> dummyRetailerData = retailerJsonData.entries.map((entry) {
  // Explicitly cast the value to the expected Map<String, dynamic> type
  final retailerData = entry.value as Map<String, dynamic>; 
  return RetailerModel.fromJson(entry.key, retailerData);
}).toList();

// ... the rest of the file remains unchanged ...
class RetailerGrid extends StatelessWidget {
  final List<RetailerModel> retailers; // Receives the filtered list

  const RetailerGrid({
    super.key,
    required this.retailers, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    if (retailers.isEmpty) {
      return const Center(child: Text("No retailers found matching the criteria."));
    }
    
    return GridView.builder(
      padding: const EdgeInsets.only(top: 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: retailers.length,
      itemBuilder: (context, index) {
        final retailer = retailers[index];
        return RetailerCard(
          retailer: retailer, // Pass the full model object
        );
      },
    );
  }
}