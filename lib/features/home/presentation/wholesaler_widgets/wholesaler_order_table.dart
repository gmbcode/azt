import 'package:flutter/material.dart';
import '../../../wholesaler/data/models/order_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              onSelectAll: (selected) => onSelectAll(selected ?? false),
              columns: const [
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
                    DataCell(Text(order.id)),
                    DataCell(Text(order.customerId)),
                    DataCell(Text(order.orderTime.length > 10 ? order.orderTime.substring(0, 10) : order.orderTime)),
                    // Rupee Symbol Fix
                    DataCell(Text('₹${order.total.toStringAsFixed(2)}')),
                    DataCell(
                      Chip(
                        label: Text(
                          order.orderStatus,
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
        );
      },
    );
  }
}