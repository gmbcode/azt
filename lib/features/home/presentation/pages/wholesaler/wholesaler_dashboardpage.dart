import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Cubit

// Widgets
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_summary_card.dart';
import '../../wholesaler_widgets/wholesaler_recent_orders_table.dart';

class wholeSalerDashboardpage extends StatelessWidget {
  const wholeSalerDashboardpage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is WholesalerError) {
          return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
        }
        
        if (state is WholesalerLoaded) {
           final int lowStockCount = state.inventory.where((i) => i.stock < 10).length;
           final int retailerCount = state.retailers.length;
           final recentOrders = state.orders.take(5).toList();

           return SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Use 800px as the breakpoint for the desktop view
                final isDesktop = constraints.maxWidth > 800; 
                
                final List<Widget> cards = [
                  SummaryCard(fontsize: 40, color: const Color(0xFF4CAF50), value: state.pendingOrdersCount.toString(), text: "Pending Orders", compact: !isDesktop),
                  SummaryCard(fontsize: 25, color: const Color(0xFF2196F3), value: '\$${state.totalRevenue.toStringAsFixed(0)}', text: "Revenue", compact: !isDesktop),
                  SummaryCard(fontsize: 35, color: const Color(0xFFF44336), value: lowStockCount.toString(), text: "Low Stock", compact: !isDesktop),
                  SummaryCard(fontsize: 35, color: const Color(0xFF9C27B0), value: retailerCount.toString(), text: "Retailers", compact: !isDesktop),
                ];
                
                return Padding(
                  padding:  EdgeInsets.all(isDesktop ? 30 : 16), // Smaller padding for mobile
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Dashboard", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      
                      // Responsive Summary Cards
                      isDesktop 
                        ? Row( // Original desktop layout
                            children: cards.map((card) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 20.0), child: card))).toList(),
                          )
                        : GridView.count( // Mobile grid layout (2 columns)
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 15, // Reduced spacing
                            crossAxisSpacing: 15,
                            children: cards,
                          ),
                      
                      const SizedBox(height: 30),
                      const Text("Recent Orders", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      
                      // Recent Orders Table is horizontally scrollable on mobile, which is acceptable for a table
                      RecentOrdersTable(orders: recentOrders),
                    ],
                  ),
                );
              }
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}