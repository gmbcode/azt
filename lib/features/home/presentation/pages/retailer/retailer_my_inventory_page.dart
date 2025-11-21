import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../retailer_models/retailer_inventory_item_model.dart';
import '../../retailer_widgets/retailer_add_inventory_dialog.dart';

class RetailerMyInventoryPage extends StatelessWidget {
  const RetailerMyInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("My Inventory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Item Manually"),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AddInventoryDialog(
                          onSave: (item) => context.read<RetailerCubit>().addInventoryItem(item),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
                    child: ListView.separated(
                      itemCount: state.inventory.length,
                      separatorBuilder: (_,__) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = state.inventory[index];
                        return ListTile(
                          leading: Image.network(item.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.inventory)),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          // CURRENCY FIX
                          subtitle: Text("Stock: ${item.stockremain} | Cost: ₹${item.costPrice.toStringAsFixed(2)} | Selling: ₹${item.price.toStringAsFixed(2)}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: item.isLive, 
                                onChanged: (val) {
                                  if(val) {
                                    _showListDialog(context, item);
                                  } else {
                                    context.read<RetailerCubit>().toggleListing(item, 0);
                                  }
                                }
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.grey),
                                onPressed: () => context.read<RetailerCubit>().deleteInventoryItem(item.id),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _showListDialog(BuildContext context, RetailerInventoryItemModel item) {
    final qtyController = TextEditingController();
    final priceController = TextEditingController(text: item.price.toString()); 

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("List ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Set details for customers:"),
            const SizedBox(height: 15),
            
            TextField(
              controller: qtyController, 
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity to List (Max: ${item.stockremain})", 
                border: const OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 15),
            
            TextField(
              controller: priceController, 
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                // CURRENCY FIX
                labelText: "Selling Price per Unit (₹)", 
                border: OutlineInputBorder()
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              int qty = int.tryParse(qtyController.text) ?? 0;
              double? price = double.tryParse(priceController.text);

              if (qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Quantity must be greater than 0"))
                );
              } else if (qty > item.stockremain) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: You only have ${item.stockremain} items in stock!"))
                );
              } else if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid selling price"))
                );
              } else {
                context.read<RetailerCubit>().toggleListing(item, qty, newPrice: price);
                Navigator.pop(ctx);
              }
            },
            child: const Text("List Item"),
          )
        ],
      ),
    );
  }
}