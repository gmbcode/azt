import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';

class RetailerCustomerOrdersPage extends StatelessWidget {
  const RetailerCustomerOrdersPage({super.key});

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
                         return ExpansionTile(
                           title: Text("Order #${order.id.substring(0,5)} - \$${order.total}"),
                           subtitle: Text("Status: ${order.orderStatus}"),
                           trailing: DropdownButton<String>(
                             value: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].contains(order.orderStatus) ? order.orderStatus : 'Pending',
                             items: ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                              .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                             onChanged: (val) {
                               if(val != null) {
                                 context.read<RetailerCubit>().updateCustomerOrderStatus(order.id, val);
                               }
                             },
                           ),
                           children: [
                             Padding(
                               padding: const EdgeInsets.all(16.0),
                               child: Text("Address: ${order.deliveryAddress}\nTime: ${order.orderTime}"),
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