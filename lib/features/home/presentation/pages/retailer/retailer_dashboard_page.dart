import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../retailer_widgets/retailer_summary_card.dart';

class RetailerDashboardPage extends StatelessWidget {
  const RetailerDashboardPage({super.key});

  String _formatOrderTime(String timeString) {
    try { return DateTime.parse(timeString).toLocal().toString().substring(0, 16); } 
    catch (e) { return timeString; }
  }

  // Helper to make the Recent Orders list look clean
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          // 1. REVENUE: Exclude cancelled
          final double revenue = state.customerOrders
              .where((o) => o.orderStatus.trim().toLowerCase() != 'cancelled')
              .fold(0.0, (sum, item) => sum + item.total);

          // 2. PENDING: Changed to EXCLUSION logic.
          // If it is NOT Delivered, Completed, Cancelled, or Shipped -> It is Pending.
          // This prevents 'Completed' or 'Delivered' orders from ever being counted here.
          final int pendingOrders = state.customerOrders
              .where((o) {
                 final status = o.orderStatus.trim().toLowerCase();
                 return status != 'delivered' && 
                        status != 'completed' && 
                        status != 'cancelled' && 
                        status != 'shipped';
              })
              .length;

          final int lowStockItems = state.inventory.where((i) => i.stockremain < 10).length;
          final recentOrders = state.customerOrders.take(5).toList();
          
          final bool isMobile = MediaQuery.of(context).size.width < 800;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Dashboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 40) / 3;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        SizedBox(width: cardWidth, child: SummaryCard(title: "Revenue", value: "₹${revenue.toStringAsFixed(0)}", color: Colors.green)),
                        SizedBox(width: cardWidth, child: SummaryCard(title: "Pending", value: pendingOrders.toString(), color: Colors.orange)),
                        SizedBox(width: cardWidth, child: SummaryCard(title: "Low Stock", value: lowStockItems.toString(), color: Colors.red)),
                      ],
                    );
                  }
                ),
                
                const SizedBox(height: 30),
                const Text("Recent Customer Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary, borderRadius: BorderRadius.circular(8)),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentOrders.length,
                    separatorBuilder: (_,__) => const Divider(),
                    itemBuilder: (context, index) {
                      final order = recentOrders[index];
                      
                      // 3. VISUAL FIX: Ensure 'Completed' shows as 'Delivered' to match Orders Page
                      String displayStatus = _capitalize(order.orderStatus.trim());
                      if (displayStatus.toLowerCase() == 'completed') {
                        displayStatus = 'Delivered';
                      }

                      return ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue[50], child: const Icon(Icons.shopping_bag, color: Colors.blue)),
                        title: Text("Order #${order.id.substring(0,5)}"),
                        subtitle: Text(_formatOrderTime(order.orderTime)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("₹${order.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(displayStatus, style: TextStyle(color: order.statusColor, fontSize: 12)),
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