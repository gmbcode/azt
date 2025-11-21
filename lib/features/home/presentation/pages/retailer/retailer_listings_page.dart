import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';

class RetailerListingsPage extends StatelessWidget {
  const RetailerListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          final activeListings = state.inventory.where((i) => i.isLive).toList();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("My Active Listings", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("These products are visible to Customers.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                
                Expanded(
                  child: activeListings.isEmpty
                  ? const Center(child: Text("No active listings. Go to Inventory to list items."))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.0, // Adjusted Ratio
                      ),
                      itemCount: activeListings.length,
                      itemBuilder: (context, index) {
                        final item = activeListings[index];
                        return Card(
                          elevation: 2,
                          // FIX: Added SingleChildScrollView
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(item.imageUrl, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.image)),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Text("Listed Qty: ${item.listedQty}"),
                                        Text("Selling Price: ₹${item.price}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    tooltip: "Delist Item",
                                    onPressed: () => context.read<RetailerCubit>().toggleListing(item, 0),
                                  )
                                ],
                              ),
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