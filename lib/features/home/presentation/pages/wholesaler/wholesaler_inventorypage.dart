import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../wholesaler/data/models/wholesaler_inventory_model.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_add_product_dialog.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is WholesalerLoaded) {
          final filtered = state.inventory.where((i) => i.name.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
          
          return Container(
            color: const Color(0xFFF8F9FA),
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Inventory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Product", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => AddProductDialog(
                          onAddProduct: (data) => context.read<WholesalerCubit>().addProduct(data),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search), 
                    hintText: "Search...", 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white
                  ),
                  onChanged: (v) => setState(() => _searchTerm = v),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (c, i) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.inventory_2, color: Colors.orange),
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Stock: ${item.stock} | Price: \$${item.price} | MOQ: ${item.moq}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // EDIT BUTTON
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showEditDialog(context, item),
                              ),
                              const SizedBox(width: 8),
                              if (!item.isListed)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () => _showListDialog(context, item),
                                  child: const Text("List Item", style: TextStyle(color: Colors.white)),
                                )
                              else
                                const Chip(label: Text("Listed", style: TextStyle(color: Colors.green))),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => context.read<WholesalerCubit>().deleteProduct(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  // --- LOGIC: List Item ---
  void _showListDialog(BuildContext context, WholesalerInventoryItem item) {
    final qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("List ${item.name}"),
        content: TextField(
          controller: qtyController, 
          keyboardType: TextInputType.number, 
          decoration: const InputDecoration(labelText: "Qty to List")
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              int? qty = int.tryParse(qtyController.text);
              if (qty != null && qty > 0 && qty <= item.stock) {
                context.read<WholesalerCubit>().listProduct(item, qty);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid Quantity")));
              }
            }, 
            child: const Text("Confirm")
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Edit Item ---
  void _showEditDialog(BuildContext context, WholesalerInventoryItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final priceCtrl = TextEditingController(text: item.price.toString());
    final stockCtrl = TextEditingController(text: item.stock.toString());
    
    // Note: We need to access the repo to update. Ideally, add updateProduct to Cubit.
    // For now, I'll assume you added `updateProduct` to WholesalerCubit in step 4 below.
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: "Stock"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final updatedItem = WholesalerInventoryItem(
                id: item.id,
                name: nameCtrl.text,
                category: item.category,
                price: double.tryParse(priceCtrl.text) ?? item.price,
                stock: int.tryParse(stockCtrl.text) ?? item.stock,
                moq: item.moq,
                description: item.description,
                imageUrl: item.imageUrl,
                isListed: item.isListed,
                listingId: item.listingId,
              );
              // TRIGGER CUBIT UPDATE (Requires update in Cubit)
              context.read<WholesalerCubit>().updateProduct(updatedItem);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}