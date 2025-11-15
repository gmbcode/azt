import 'package:flutter/material.dart';
import '../models/retailer_inventory_item_model.dart';

class InventoryTable extends StatelessWidget {
  final List<RetailerInventoryItemModel> items;
  final Function(RetailerInventoryItemModel item) onEdit;
  final Function(RetailerInventoryItemModel item) onDelete;

  const InventoryTable({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // We use a LayoutBuilder to get the width
    return LayoutBuilder(
      builder: (context, constraints) {
        // This SingleChildScrollView handles VERTICAL scrolling
        return SingleChildScrollView(
          child: SingleChildScrollView( // This one handles HORIZONTAL scrolling
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              // This forces the table to be at least as wide as the box
              constraints: BoxConstraints(minWidth: constraints.maxWidth), 
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('My Price', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Stock Remain', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Stock Sold', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: items.map((item) {
                  return DataRow(
                    cells: [
                      // Product Cell with Image
                      DataCell(Row(
                        children: [
                          Image.network(
                            item.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, e, s) => const Icon(Icons.image, color: Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          Text(item.name),
                        ],
                      )),
                      DataCell(Text(item.category)),
                      DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
                      DataCell(Text(item.stockremain.toString())),
                      DataCell(Text(item.stocksold.toString())),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => onEdit(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => onDelete(item),
                          ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }
    );
  }
}