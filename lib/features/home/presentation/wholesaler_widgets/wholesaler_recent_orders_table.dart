// lib/widgets/recent_orders_table.dart

import 'package:flutter/material.dart';

class RecentOrdersTable extends StatelessWidget {
  const RecentOrdersTable({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data list based on your JSON structure
    // TODO: Replace this with a stream/future from your Firebase 'orders' collection
    final List<Map<String, dynamic>> recentOrders = [//just for display hence we use map
      {
        "id": "dummy1",
        "orderbyid": "customerid",
        "total": 100,
        "status": "delivered",
      },
      {
        "id": "dummy2",
        "orderbyid": "retailerid",
        "total": 1500,
        "status": "confirmed",
      },
      {
        "id": "dummy3",
        "orderbyid": "customerid_2",
        "total": 75.50,
        "status": "pending",
      }
    ];

    return Container(   //this is the whole box ,the parent code will decide the size
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Orders",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // --- THIS IS THE FIX ---
          // We use a SizedBox with width: double.infinity to force
          // the DataTable to stretch to the full width of the card.
          // The SingleChildScrollView has been removed.
          SizedBox(
            width: double.infinity,
            child: DataTable(   //creates a table like structure for datas
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              columns: const [
                DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: recentOrders.map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order['id'])),
                    DataCell(Text(order['orderbyid'])),
                    DataCell(Text('\$${order['total'].toStringAsFixed(2)}')),
                    DataCell(
                      Chip(
                        label: Text(
                          order['status'],
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(order['status']),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get a color based on the order status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}