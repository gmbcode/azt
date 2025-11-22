import 'package:flutter/material.dart';
import '../retailer_models/retailer_inventory_item_model.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth), 
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                columns: const [
                  DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: items.map((item) {
                  return DataRow(
                    cells: [
                      DataCell(Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.grey[200],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, e, s) => const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(width: 120, child: Text(item.name, overflow: TextOverflow.ellipsis)),
                        ],
                      )),
                      DataCell(Text(item.category)),
                      DataCell(Text('₹${item.costPrice.toStringAsFixed(2)}')),
                      DataCell(Text('₹${item.price.toStringAsFixed(2)}')),
                      DataCell(Text(item.stockremain.toString())),
                      DataCell(
                        Chip(
                          label: Text(
                            item.isLive ? 'Listed (${item.listedQty})' : 'Hidden',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor: item.isLive ? Colors.green : Colors.grey,
                          padding: const EdgeInsets.all(0),
                        )
                      ),
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