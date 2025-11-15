// lib/widgets/reusable_order_table.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart'; 

class ReusableOrderTable extends StatelessWidget {
  final List<OrderModel> orders;
  final Set<String> selectedOrderIds; 
  final bool showCustomerIdColumn;
  final String customerColumnTitle;
  final ValueChanged<bool?> onSelectAll;
  final Function(String orderId, bool? selected) onSelectRow;

  const ReusableOrderTable({
    super.key,
    required this.orders,
    required this.selectedOrderIds,
    required this.onSelectAll,
    required this.onSelectRow,
    this.showCustomerIdColumn = true, 
    this.customerColumnTitle = "Customer ID", 
  });

  @override
  Widget build(BuildContext context) {
    final List<DataColumn> columns = [
      const DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
      if (showCustomerIdColumn)
        DataColumn(label: Text(customerColumnTitle, style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Order Time', style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
    ];
    
    // The Container and LayoutBuilder are from our previous fix
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // --- THIS IS THE FIX ---
          // This NEW SingleChildScrollView handles VERTICAL scrolling
          // if the list of rows gets too long.
          return SingleChildScrollView(
            child: SingleChildScrollView( // This one handles HORIZONTAL scrolling
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth), // This forces it to fill
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                  onSelectAll: onSelectAll,
                  columns: columns,
                  rows: orders.map((order) {
                    final bool isSelected = selectedOrderIds.contains(order.id); 
                    
                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (bool? selected) {
                        onSelectRow(order.id, selected);
                      },
                      cells: [
                        DataCell(Text(order.id)),
                        if (showCustomerIdColumn)
                          DataCell(Text(order.orderbyid)),
                        DataCell(Text(order.formattedOrderTime)),
                        DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                        DataCell(
                          Chip(
                            label: Text(
                              order.status,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            backgroundColor: order.statusColor,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}