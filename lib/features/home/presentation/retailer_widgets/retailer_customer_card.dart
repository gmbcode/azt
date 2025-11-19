// lib/widgets/customer_card.dart

import 'package:flutter/material.dart';
import '../retailer_models/retailer_customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onViewProfile;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Center the avatar and text
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar with initial
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[100],
              child: Text(
                customer.username.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Customer Name
            Text(
              customer.username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Address
            Text(
              customer.address,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(), // Pushes the button to the bottom
            // View Profile Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewProfile,
                child: const Text('View Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}