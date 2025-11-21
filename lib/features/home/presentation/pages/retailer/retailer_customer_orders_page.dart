import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';

class RetailerCustomerOrdersPage extends StatelessWidget {
  const RetailerCustomerOrdersPage({super.key});

  Future<void> _confirmStatusChange(BuildContext context, dynamic order, String newStatus) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Mark as $newStatus?"),
        content: Text(newStatus == 'Cancelled' 
            ? "This will cancel the order. Inventory will not be deducted." 
            : "This will complete the order and permanently deduct items from your physical inventory."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: newStatus == 'Cancelled' ? Colors.red : Colors.green),
            child: const Text("Yes", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // ignore: use_build_context_synchronously
      context.read<RetailerCubit>().updateCustomerOrderStatus(order, newStatus);
    }
  }

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
                 const Text("Customer Orders", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 20),
                 Expanded(
                   child: Container(
                     decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
                     child: ListView.separated(
                       itemCount: state.customerOrders.length,
                       separatorBuilder: (_,__) => const Divider(),
                       itemBuilder: (context, index) {
                         final order = state.customerOrders[index];
                         final isLocked = ['Delivered', 'Completed', 'Cancelled'].contains(order.orderStatus);

                         return ExpansionTile(
                           title: Text("Order #${order.id.substring(0,5)} - ₹${order.total}"),
                           subtitle: Text("Status: ${order.orderStatus}"),
                           trailing: isLocked
                             ? Chip(
                                 label: Text(order.orderStatus, style: const TextStyle(color: Colors.white)),
                                 backgroundColor: order.orderStatus == 'Cancelled' ? Colors.red : Colors.green,
                               )
                             : DropdownButton<String>(
                                 value: ['Pending', 'Processing', 'Shipped'].contains(order.orderStatus) ? order.orderStatus : 'Pending',
                                 items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                 onChanged: (val) {
                                   if(val != null) {
                                     if (val == 'Delivered' || val == 'Cancelled') {
                                       _confirmStatusChange(context, order, val);
                                     } else {
                                       context.read<RetailerCubit>().updateCustomerOrderStatus(order, val);
                                     }
                                   }
                                 },
                               ),
                           children: [
                             Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text("Address: ${order.deliveryAddress}\nTime: ${order.formattedOrderTime}"),
                                   const SizedBox(height: 10),
                                   const Text("Items Ordered:", style: TextStyle(fontWeight: FontWeight.bold)),
                                   const Divider(),
                                   if (order.items.isNotEmpty)
                                     ...order.items.map<Widget>((item) {
                                       final map = item as Map;
                                       return Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Text("${map['qty']}x ${map['name']}"),
                                           Text("₹${map['price']}"),
                                         ],
                                       );
                                     }).toList()
                                   else
                                     const Text("No items data"),
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
}