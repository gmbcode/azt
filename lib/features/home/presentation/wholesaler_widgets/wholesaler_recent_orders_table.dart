import 'package:flutter/material.dart';
import '../../../wholesaler/data/models/order_model.dart';
import '../../../wholesaler/data/models/retailer_model.dart'; // Added Import

class RecentOrdersTable extends StatelessWidget {
  final List<OrderModel> orders;
  final List<WholesalerViewRetailerModel> retailers; // Added retailers list

  const RecentOrdersTable({
    super.key, 
    required this.orders,
    required this.retailers, // Required
  });

  String _getRetailerName(String uid) {
    try {
      final retailer = retailers.firstWhere((r) => r.uid == uid);
      return retailer.businessName;
    } catch (e) {
      return 'Retailer ($uid)'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Status')),
            ],
            rows: orders.map((order) {
              return DataRow(
                cells: [
                  DataCell(Text(order.id)),
                  // Show Name instead of ID
                  DataCell(Text(_getRetailerName(order.customerId))), 
                  DataCell(Text('₹${order.total.toStringAsFixed(2)}')),
                  DataCell(
                    Chip(
                      label: Text(order.orderStatus, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: order.statusColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}