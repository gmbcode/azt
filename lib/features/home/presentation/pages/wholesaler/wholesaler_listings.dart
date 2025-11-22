import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is WholesalerLoaded) {
          final listings = state.listings;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text("Active Listings", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                     // Statistics Chip
                     Chip(
                       label: Text("${listings.length} Active"),
                       backgroundColor: Theme.of(context).colorScheme.secondary,
                       labelStyle: const TextStyle(color: Colors.white),
                     )
                  ],
                ),
                const SizedBox(height: 5),
                Text("These items are currently visible to Retailers.", style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 20),
                
                Expanded(
                  child: listings.isEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt_outlined, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        Text("No active listings.", style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 5),
                        Text("Go to Inventory to list items.", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ))
                  : ListView.separated(
                      itemCount: listings.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = listings[index];
                        return Card(
                          elevation: 0, // Flat style
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade200)
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.shopping_bag_outlined, color: Theme.of(context).colorScheme.secondary),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  _InfoBadge(icon: Icons.inventory_2_outlined, text: "${item.availableQty} units"),
                                  const SizedBox(width: 15),
                                  _InfoBadge(icon: Icons.attach_money, text: item.price.toStringAsFixed(2)),
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              tooltip: "Delist Item",
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text("Remove Listing?"),
                                    content: Text("This will remove '${item.name}' from the marketplace. It will remain in your inventory."),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        onPressed: () {
                                          context.read<WholesalerCubit>().deleteListing(item.id, item.inventoryItemId);
                                          Navigator.pop(c);
                                        },
                                        child: const Text("Remove"),
                                      )
                                    ],
                                  )
                                );
                              },
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
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
    ]);
  }
}