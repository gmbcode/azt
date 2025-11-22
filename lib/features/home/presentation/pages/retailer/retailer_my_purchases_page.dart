import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../../../wholesaler/data/models/order_model.dart';

class RetailerMyPurchasesPage extends StatelessWidget {
  const RetailerMyPurchasesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RetailerCubit, RetailerState>(
      listener: (context, state) {
        if (state is RetailerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "My Purchases (From Wholesalers)", 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary, 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: state.myPurchases.isEmpty 
                    ? const Center(child: Text("No purchases found.", style: TextStyle(color: Colors.white)))
                    : ListView.separated(
                      itemCount: state.myPurchases.length,
                      separatorBuilder: (_,__) => const Divider(color: Colors.white24),
                      itemBuilder: (context, index) {
                        final order = state.myPurchases[index];
                        
                        // Check statuses
                        final status = order.orderStatus.toLowerCase();
                        final bool isCompleted = status == 'completed' || status == 'delivered';
                        final bool isCancelled = status == 'cancelled';
                        
                        final String displayId = order.id.length > 5 ? order.id.substring(0, 5) : order.id;

                        // Use ExpansionTile to show details
                        return ExpansionTile(
                          collapsedIconColor: Colors.white,
                          iconColor: Colors.white,
                          title: Text("Order #$displayId", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text("Status: ${order.orderStatus} | Total: ₹${order.total}", style: const TextStyle(color: Colors.white70)),
                          trailing: _buildTrailingWidget(context, order, isCompleted, isCancelled),
                          children: [
                            Container(
                              color: Colors.black12,
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Items Ordered:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...order.items.map((item) => Text("• ${item['name']} (Qty: ${item['qty']})", style: const TextStyle(color: Colors.white70))),
                                ],
                              ),
                            )
                          ],
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

  Widget? _buildTrailingWidget(BuildContext context, OrderModel order, bool isCompleted, bool isCancelled) {
    if (order.inventoryAdded) {
      return const Chip(
        avatar: Icon(Icons.check, size: 16, color: Colors.white),
        label: Text("Stock Added"),
        backgroundColor: Colors.green,
        labelStyle: TextStyle(color: Colors.white),
      );
    }

    // Do not allow adding stock if cancelled
    if (isCancelled) {
      return const Chip(
        label: Text("Cancelled"),
        backgroundColor: Colors.red,
        labelStyle: TextStyle(color: Colors.white),
      );
    }

    if (isCompleted) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        onPressed: () {
          context.read<RetailerCubit>().receiveOrderToInventory(order);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Retrying Stock Update...")));
        },
        child: const Text("Force Add Stock", style: TextStyle(color: Colors.white)),
      );
    }

    return null; // Default arrows handled by ExpansionTile
  }
}