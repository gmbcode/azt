import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_summary_card.dart';
import '../../wholesaler_widgets/wholesaler_recent_orders_table.dart';

class wholeSalerDashboardpage extends StatelessWidget {
  const wholeSalerDashboardpage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) return const Center(child: CircularProgressIndicator());
        if (state is WholesalerError) return Center(child: Text("Error: ${state.message}"));
        
        if (state is WholesalerLoaded) {
           final int lowStockCount = state.inventory.where((i) => i.stock < 10).length;
           final int retailerCount = state.retailers.length;
           final recentOrders = state.orders.take(5).toList();
           
           final bool isMobile = MediaQuery.of(context).size.width < 800;

           return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Dashboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double cardWidth = isMobile ? constraints.maxWidth : (constraints.maxWidth - 60) / 4;
                      
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          SizedBox(width: cardWidth, child: SummaryCard(fontsize: isMobile ? 30 : 40, color: const Color(0xFF4CAF50), value: state.pendingOrdersCount.toString(), text: "Pending")),
                          SizedBox(width: cardWidth, child: SummaryCard(fontsize: isMobile ? 24 : 25, color: const Color(0xFF2196F3), value: '₹${state.totalRevenue.toStringAsFixed(0)}', text: "Revenue")),
                          SizedBox(width: cardWidth, child: SummaryCard(fontsize: isMobile ? 30 : 35, color: const Color(0xFFF44336), value: lowStockCount.toString(), text: "Low Stock")),
                          SizedBox(width: cardWidth, child: SummaryCard(fontsize: isMobile ? 30 : 35, color: const Color(0xFF9C27B0), value: retailerCount.toString(), text: "Retailers")),
                        ],
                      );
                    }
                  ),
                  
                  const SizedBox(height: 30),
                  const Text("Recent Orders", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: isMobile ? 800 : 0),
                      child: RecentOrdersTable(orders: recentOrders)
                    )
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}