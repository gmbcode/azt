import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../../../wholesaler/data/models/order_model.dart'; // Import OrderModel

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
                    // Dark Mode Friendly Background
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
                        final bool isCompleted = order.orderStatus.toLowerCase() == 'completed' || 
                                                 order.orderStatus.toLowerCase() == 'delivered';
                        
                        final String displayId = order.id.length > 5 ? order.id.substring(0, 5) : order.id;

                        return ListTile(
                          title: Text("Order #$displayId", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text("Status: ${order.orderStatus} | Total: \$${order.total}", style: const TextStyle(color: Colors.white70)),
                          trailing: _buildTrailingWidget(context, order, isCompleted),
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

  Widget _buildTrailingWidget(BuildContext context, OrderModel order, bool isCompleted) {
    // 1. If stock is added (automatically or manually), show Green Chip
    if (order.inventoryAdded) {
      return const Chip(
        avatar: Icon(Icons.check, size: 16, color: Colors.white),
        label: Text("Stock Added"),
        backgroundColor: Colors.green,
        labelStyle: TextStyle(color: Colors.white),
      );
    }

    // 2. If Completed but NOT added (Auto-logic might be processing, or failed), show Manual Button
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

    // 3. Otherwise (Pending/Processing), just show status
    return Chip(
      label: Text(order.orderStatus),
      backgroundColor: Colors.black26,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}