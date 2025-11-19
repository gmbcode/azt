// lib/widgets/order_table.dart

import 'package:flutter/material.dart';

// A simple model for our dummy data.
// In a real app, this would come from your JSON.
class OrderData {
  final String orderId;
  final String customerId;
  final String orderTime;
  final double total;
  final String paymentStatus;
  final String orderStatus;
  bool isSelected; // To manage checkbox state

  OrderData({
    required this.orderId,
    required this.customerId,
    required this.orderTime,
    required this.total,
    required this.paymentStatus,
    required this.orderStatus,
    this.isSelected = false,
  });
}

class OrderTable extends StatefulWidget {
  const OrderTable({super.key});

  @override
  State<OrderTable> createState() => _OrderTableState();
}

class _OrderTableState extends State<OrderTable> {
  // TODO: Replace this with your actual data
  final List<OrderData> _orders = [
    OrderData(
      orderId: 'dummy1',
      customerId: 'customerid',
      orderTime: '2025-11-10T09:00:00Z',
      total: 100.0,
      paymentStatus: 'Paid',
      orderStatus: 'Delivered',
    ),
    OrderData(
      orderId: 'dummy2',
      customerId: 'retailerid',
      orderTime: '2025-11-11T10:30:00Z',
      total: 1500.0,
      paymentStatus: 'Pending',
      orderStatus: 'Processing',
    ),
    OrderData(
      orderId: 'dummy3',
      customerId: 'customerid_2',
      orderTime: '2025-11-12T14:15:00Z',
      total: 75.50,
      paymentStatus: 'Paid',
      orderStatus: 'Pending',
    ),
  ];

  bool _selectedAll = false;

  void _onSelectAll(bool? selected) {
    setState(() {
      _selectedAll = selected ?? false;
      for (var order in _orders) {
        order.isSelected = _selectedAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,//sets table= screen width
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
          onSelectAll: _onSelectAll, // <-- This creates the "Select All" header checkbox
          columns: const [
            // The checkbox column is now added AUTOMATICALLY
            DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Customer ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Order Time', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            // "Actions" column is removed as per new image
          ],
          rows: _orders.map((order) {
            return DataRow(
              selected: order.isSelected,
              onSelectChanged: (bool? selected) { // <-- This creates the row checkbox
                setState(() {
                  order.isSelected = selected ?? false;
                  // Check if all are selected
                  _selectedAll = _orders.every((o) => o.isSelected);
                });
              },
              cells: [
                // The checkbox cell is now added AUTOMATICALLY
                DataCell(Text(order.orderId)),
                DataCell(Text(order.customerId)),
                DataCell(Text(DateTime.parse(order.orderTime).toLocal().toString().substring(0, 16))),
                DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                DataCell(
                  Chip(
                    label: Text(
                      order.orderStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(order.orderStatus),//the function is below on how to get colour
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Helper method to get a color based on the order status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}