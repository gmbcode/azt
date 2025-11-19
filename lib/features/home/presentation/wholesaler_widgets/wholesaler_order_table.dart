// lib/widgets/order_table.dart

import 'package:flutter/material.dart';

// --- Order Model based on JSON ---
class OrderModel {
  final String id;
  final String customerId;
  final String orderTime;
  final double total;
  final String deliveryAddress;
  final String orderStatus;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.orderTime,
    required this.total,
    required this.deliveryAddress,
    required this.orderStatus,
  });

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    String customerId = json['orderbyid']?.split('/').first ?? 'N/A';
    
    // Ensure total is a double
    double totalValue = 0.0;
    if (json['total'] is num) {
      totalValue = (json['total'] as num).toDouble();
    } else if (json['total'] is String) {
      totalValue = double.tryParse(json['total']!) ?? 0.0;
    }
    
    // Normalize status for UI
    String status = json['status']?.toString().toLowerCase() ?? 'pending';
    String normalizedStatus = 'Pending';
    if (status.contains('delivered')) {
      normalizedStatus = 'Completed';
    } else if (status.contains('confirmed')) {
      normalizedStatus = 'Processing';
    } else if (status.contains('shipped')) {
      normalizedStatus = 'Shipped';
    } else if (status.contains('cancelled')) {
      normalizedStatus = 'Cancelled';
    }

    return OrderModel(
      id: id,
      customerId: customerId,
      orderTime: json['ordertime'] ?? DateTime.now().toIso8601String(),
      total: totalValue,
      deliveryAddress: json['deliveryaddress'] ?? 'Unknown Address',
      orderStatus: normalizedStatus,
    );
  }
}

// --- Dummy Data (Must be present for compilation) ---
final Map<String, dynamic> rawOrderData = {
  "dummy1": {
    "deliveryaddress": "99 abcd avenue",
    "orderbyid": "customerid/wholesalerid",
    "ordertime": "2025-11-10T14:30:00Z",
    "status": "delivered",
    "total": 100,
  },
  "dummy2": {
    "deliveryaddress": "123 main street",
    "orderbyid": "retailerid/wholesalerid",
    "ordertime": "2025-11-11T16:00:00Z",
    "status": "confirmed",
    "total": 1500,
  },
  "dummy3": {
    "deliveryaddress": "45 oak rd",
    "orderbyid": "customerid_2/wholesalerid",
    "ordertime": "2025-11-12T19:45:00Z",
    "status": "pending",
    "total": 75.50,
  },
  "dummy4": {
    "deliveryaddress": "67 maple ave",
    "orderbyid": "customerid_3/wholesalerid",
    "ordertime": "2025-11-13T10:00:00Z",
    "status": "shipped", 
    "total": 250,
  },
  "dummy5": {
    "deliveryaddress": "88 pine ln",
    "orderbyid": "retailerid_2/wholesalerid",
    "ordertime": "2025-11-14T11:00:00Z",
    "status": "cancelled", 
    "total": 50,
  },
};

List<OrderModel> allOrders = rawOrderData.entries.map((entry) {
  return OrderModel.fromJson(entry.key, entry.value as Map<String, dynamic>);
}).toList();


class OrderTable extends StatelessWidget {
  final List<OrderModel> orders;
  final Map<String, bool> selectionMap;
  final void Function(String id, bool isSelected) onOrderSelectionChanged; 
  final ValueChanged<bool> onSelectAll;
  final bool allSelected;

  const OrderTable({
    super.key,
    required this.orders,
    required this.selectionMap,
    required this.onOrderSelectionChanged,
    required this.onSelectAll,
    required this.allSelected,
  });

  static String _formatOrderTime(String time) {
    try {
      return DateTime.parse(time).toLocal().toString().substring(0, 16);
    } catch (e) {
      return time;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed': 
        return Colors.green;
      case 'Processing': 
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Cancelled':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use LayoutBuilder to determine the maximum width available from the parent Expanded.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the maxWidth constraint from the parent to set the minimum width of the table.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            // Ensure the table is at least as wide as its container, allowing it to stretch.
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              onSelectAll: (selected) => onSelectAll(selected ?? false), 
              
              columns: const [
                // 5 Defined Columns + 1 Automatic Selection Column = 6 UI Columns
                DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Customer ID', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Order Time', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              
              rows: orders.map((order) {
                final isSelected = selectionMap[order.id] ?? false;
                return DataRow(
                  selected: isSelected,
                  onSelectChanged: (bool? selected) { 
                    onOrderSelectionChanged(order.id, selected ?? false); 
                  },
                  cells: [
                    // 5 DataCells to match the 5 DataColumns (selection column is automatic)
                    DataCell(Text(order.id)),        
                    DataCell(Text(order.customerId)), 
                    DataCell(Text(_formatOrderTime(order.orderTime))),
                    DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                    DataCell(
                      Chip(
                        label: Text(
                          order.orderStatus,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(order.orderStatus),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}