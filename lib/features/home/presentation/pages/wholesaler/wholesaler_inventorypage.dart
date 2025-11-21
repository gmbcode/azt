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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
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
                // START: Responsive Header (Title + Button)
                isMobile 
                ? Column( // Stacked vertically on mobile
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Inventory", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
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
                      ),
                    ],
                  )
                : Row( // Side-by-side on desktop
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
                // END: Responsive Header
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
                          subtitle: Text("Category: ${item.category} | Stock: ${item.stock} | Price: \$${item.price}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!item.isListed)
                                ElevatedButton(
                                  // Compact button for mobile view
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: isMobile ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    textStyle: TextStyle(fontSize: isMobile ? 12 : 14)
                                  ),
                                  onPressed: () => _showListDialog(context, item),
                                  child: Text(isMobile ? "List" : "List Item", style: const TextStyle(color: Colors.white)),
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
              }
            }, 
            child: const Text("Confirm")
          ),
        ],
      ),
    );
  }
}