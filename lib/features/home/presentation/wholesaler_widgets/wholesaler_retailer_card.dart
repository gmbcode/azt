// lib/widgets/retailer_card.dart

import 'package:flutter/material.dart';

class RetailerCard extends StatelessWidget {
  final String businessName;
  final String address;

  const RetailerCard({
    super.key,
    required this.businessName,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder Icon
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: 28,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),

          // Business Name (from your JSON)
          Text(
            businessName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, //it gives ... if text overflows
          ),
          const SizedBox(height: 4),

          // Address (from your JSON)
          Text(
            address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Spacer to push the button to the bottom
          const Spacer(),

          // View Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Handle navigation to retailer's profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: const Text('View Profile'),
            ),
          ),
        ],
      ),
    );
  }
}