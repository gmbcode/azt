import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';

class RetailerCustomerOrdersPage extends StatelessWidget {
  const RetailerCustomerOrdersPage({super.key});

  // 1. Helper to fix casing
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  // Confirmation Dialog for critical actions
  Future<bool> _showConfirmation(BuildContext context, String action) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$action Order?"),
        content: Text("Are you sure you want to mark this order as $action? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Confirm")),
        ],
      ),
    ) ?? false;
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
                     decoration: BoxDecoration(
                       color: Theme.of(context).colorScheme.secondary, 
                       borderRadius: BorderRadius.circular(8)
                     ),
                     child: ListView.separated(
                       itemCount: state.customerOrders.length,
                       separatorBuilder: (_,__) => const Divider(),
                       itemBuilder: (context, index) {
                         final order = state.customerOrders[index];
                         
                         // 2. Normalize Status: Remove whitespace & lowercase
                         final rawStatus = order.orderStatus.trim().toLowerCase();
                         
                         // 3. Display Logic: Ensure 'completed' shows as 'Delivered' in dropdown
                         String displayStatus = _capitalize(rawStatus);
                         if (rawStatus == 'completed') {
                           displayStatus = 'Delivered';
                         }
                         
                         // 4. Lock Logic: Lock if delivered, cancelled, or completed
                         final isLocked = rawStatus == 'delivered' || rawStatus == 'cancelled' || rawStatus == 'completed';

                         return ExpansionTile(
                           title: Text("Order #${order.id.substring(0,5)} - ₹${order.total}"),
                           subtitle: Text("Status: $displayStatus"),
                           trailing: SizedBox(
                             width: 130, 
                             child: DropdownButtonHideUnderline(
                               child: DropdownButton<String>(
                                 isExpanded: true,
                                 // 5. Value: Safely matches 'Delivered' even if DB said 'completed'
                                 value: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                                        .contains(displayStatus) ? displayStatus : 'Pending',
                                 
                                 // 6. Disable if locked
                                 onChanged: isLocked ? null : (val) async {
                                   if(val != null && val != displayStatus) {
                                     // Confirmation
                                     if (val == 'Delivered' || val == 'Cancelled') {
                                       final confirm = await _showConfirmation(context, val);
                                       if (!confirm) return;
                                     }
                                     
                                     // Handle Status Update
                                     if (val == 'Cancelled') {
                                       context.read<RetailerCubit>().updateCustomerOrderStatus(
                                         order.id, 
                                         val, 
                                         itemsToRestock: order.items
                                       );
                                     } else {
                                       context.read<RetailerCubit>().updateCustomerOrderStatus(
                                         order.id, 
                                         val
                                       );
                                     }
                                   }
                                 },
                                 // 7. Visual Feedback: Grey text when locked
                                 selectedItemBuilder: (BuildContext context) {
                                    return ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map<Widget>((String item) {
                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          item,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isLocked ? Colors.grey : Theme.of(context).textTheme.bodyMedium?.color,
                                            fontWeight: isLocked ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                 items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                                  .map((e) => DropdownMenuItem(
                                    value: e, 
                                    child: Text(e, style: const TextStyle(fontSize: 13))
                                  )).toList(),
                               ),
                             ),
                           ),
                           children: [
                             Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text("Address: ${order.deliveryAddress}"),
                                   Text("Time: ${order.formattedOrderTime}"),
                                   const Divider(),
                                   const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                                   ...order.items.map((item) => Padding(
                                     padding: const EdgeInsets.symmetric(vertical: 2.0),
                                     child: Row(
                                       children: [
                                         Expanded(
                                           child: Text(
                                             "• ${item['name']} (x${item['qty']})",
                                             overflow: TextOverflow.ellipsis,
                                           ),
                                         ),
                                       ],
                                     ),
                                   )),
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