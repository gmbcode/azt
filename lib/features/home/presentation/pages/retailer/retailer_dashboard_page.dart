import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../retailer_widgets/retailer_summary_card.dart';

class RetailerDashboardPage extends StatelessWidget {
  const RetailerDashboardPage({super.key});

  String _formatOrderTime(String timeString) {
    try {
      return DateTime.parse(timeString).toLocal().toString().substring(0, 16);
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          final double revenue = state.customerOrders
              .where((o) => o.orderStatus.toLowerCase() != 'cancelled')
              .fold(0.0, (sum, item) => sum + item.total);
              
          final int pendingOrders = state.customerOrders
              .where((o) => ['pending', 'processing'].contains(o.orderStatus.toLowerCase()))
              .length;
              
          final int lowStockItems = state.inventory
              .where((i) => i.stockremain < 10)
              .length;
          
          final recentOrders = state.customerOrders.take(5).toList();

          // Return ONLY the content, no Sidebar
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dashboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Expanded(child: SummaryCard(title: "My Revenue", value: "\$${revenue.toStringAsFixed(0)}", color: Colors.green)),
                    const SizedBox(width: 20),
                    Expanded(child: SummaryCard(title: "Pending Orders", value: pendingOrders.toString(), color: Colors.orange)),
                    const SizedBox(width: 20),
                    Expanded(child: SummaryCard(title: "Low Stock", value: lowStockItems.toString(), color: Colors.red)),
                  ],
                ),
                
                const SizedBox(height: 30),
                const Text("Recent Customer Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                Container(
                  decoration: BoxDecoration(color:Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentOrders.length,
                    separatorBuilder: (_,__) => const Divider(),
                    itemBuilder: (context, index) {
                      final order = recentOrders[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.shopping_bag, color: Colors.blue)),
                        title: Text("Order #${order.id.substring(0,5)}"),
                        subtitle: Text(_formatOrderTime(order.orderTime)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("\$${order.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(order.orderStatus, style: TextStyle(color: order.statusColor, fontSize: 12)),
                          ],
                        ),
                      );
                    },
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