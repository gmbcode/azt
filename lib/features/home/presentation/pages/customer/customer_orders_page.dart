import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../customer/presentation/cubits/customer_cubit.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoaded) {
          if (state.orders.isEmpty) return Center(child: Text("No orders yet.", style: TextStyle(color: Colors.grey.shade600)));

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: state.orders.length,
            separatorBuilder: (_,__) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return ExpansionTile(
                collapsedBackgroundColor: Theme.of(context).colorScheme.surface,
                backgroundColor: Theme.of(context).colorScheme.surface,
                textColor: Theme.of(context).colorScheme.onSurface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(backgroundColor: order.statusColor.withOpacity(0.2), child: Icon(Icons.local_shipping, color: order.statusColor)),
                title: Text("Order #${order.id.substring(0,5)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                // Currency Fix
                subtitle: Text("${order.formattedOrderTime} • ₹${order.total.toStringAsFixed(2)}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text("Status: ${order.orderStatus}", style: TextStyle(color: order.statusColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                        if (order.items.isNotEmpty)
                          ...order.items.map<Widget>((item) {
                            final map = item as Map;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${map['qty']}x ${map['name']}", style: const TextStyle(fontSize: 14)),
                                  // Currency Fix
                                  Text("₹${map['price']}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                                ],
                              ),
                            );
                          }).toList()
                        else
                          const Text("Item details not available"),
                      ],
                    ),
                  )
                ],
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}