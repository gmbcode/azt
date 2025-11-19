// lib/widgets/retailer_card.dart

import 'package:flutter/material.dart';

import '../wholesaler_models/retailer_model.dart';


class RetailerCard extends StatelessWidget {
  final RetailerModel retailer; // Now takes a full model object

  const RetailerCard({
    super.key,
    required this.retailer,
  });

  void _viewProfile(BuildContext context) {
    // In a real app, this would navigate to a detailed profile page.
    // We'll just show a simple snackbar to demonstrate it works.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing profile for ${retailer.businessName} (ID: ${retailer.id})'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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

          // Business Name
          Text(
            retailer.businessName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Address
          Text(
            retailer.address,
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
              onPressed: () => _viewProfile(context), // **View Profile Logic Here**
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