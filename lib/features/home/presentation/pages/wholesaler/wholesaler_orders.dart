import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../wholesaler/data/models/order_model.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_order_filter_chips.dart';
import '../../wholesaler_widgets/wholesaler_order_search_bar.dart';
import '../../wholesaler_widgets/wholesaler_order_table.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedFilter = 'All';
  String _searchTerm = '';
  Map<String, bool> _selectionMap = {};

  List<OrderModel> _getFilteredOrders(List<OrderModel> allOrders) {
    List<OrderModel> filtered = allOrders;
    if (_selectedFilter != 'All') {
      filtered = filtered.where((o) => o.orderStatus == _selectedFilter).toList();
    }
    if (_searchTerm.isNotEmpty) {
      final term = _searchTerm.toLowerCase();
      filtered = filtered.where((o) => 
        o.id.toLowerCase().contains(term) || 
        o.customerId.toLowerCase().contains(term)
      ).toList();
    }
    return filtered;
  }

  void _onSelectAll(List<OrderModel> currentOrders, bool isSelected) {
    setState(() {
      for (var order in currentOrders) {
        _selectionMap[order.id] = isSelected;
      }
    });
  }

  void _updateStatusForSelected(BuildContext context, String newStatus) {
    final selectedIds = _selectionMap.entries.where((e) => e.value).map((e) => e.key).toList();
    for (var id in selectedIds) {
      context.read<WholesalerCubit>().updateOrderStatus(id, newStatus);
    }
    setState(() => _selectionMap.clear());
  }
  
  void _onOrderSelectionChanged(String id, bool val) {
    setState(() => _selectionMap[id] = val);
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is WholesalerLoaded) {
          final currentOrders = _getFilteredOrders(state.orders);
          final bool allSelected = currentOrders.isNotEmpty && currentOrders.every((o) => _selectionMap[o.id] == true);
          final bool hasSelected = _selectionMap.values.any((v) => v);

          // Use Theme Colors
          final surfaceColor = Theme.of(context).colorScheme.surface;
          final primaryColor = Theme.of(context).primaryColor;
          final borderColor = Theme.of(context).dividerColor;
          
          // Corrected the syntax here
          final isMobile = MediaQuery.of(context).size.width < 600;

          return Padding(
            padding:  EdgeInsets.all(isMobile ? 16 : 24),
            child: Container(
              padding: isMobile ? const EdgeInsets.all(15) : const EdgeInsets.all(30), // Reduced padding for mobile
              decoration: BoxDecoration(
                color: surfaceColor, // Dynamic Surface Color
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Orders", 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor) // Dynamic Text
                  ),
                  const SizedBox(height: 20),
                  
                  OrderFilterChips(
                    selectedFilter: _selectedFilter,
                    onFilterSelected: (val) => setState(() => _selectedFilter = val),
                  ),
                  const SizedBox(height: 20),
                  
                  // Mobile Search Bar is full width
                  SizedBox(
                    width: isMobile ? double.infinity : 300, 
                    child: OrderSearchBar(onSearch: (val) => setState(() => _searchTerm = val))
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: isMobile
                      ? ListView.builder( // Mobile List View (Clean Cards)
                          itemCount: currentOrders.length,
                          itemBuilder: (context, index) {
                            final order = currentOrders[index];
                            final isSelected = _selectionMap[order.id] ?? false;
                            
                            return MobileOrderCard(
                              order: order, 
                              isSelected: isSelected,
                              onSelect: (val) => _onOrderSelectionChanged(order.id, val ?? false),
                            );
                          },
                        )
                      : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor), // Dynamic Border
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Desktop: Use DataTable with horizontal scroll
                        child: OrderTable(
                          orders: currentOrders,
                          selectionMap: _selectionMap,
                          onOrderSelectionChanged: _onOrderSelectionChanged,
                          onSelectAll: (val) => _onSelectAll(currentOrders, val),
                          allSelected: allSelected,
                        ),
                      ),
                  ),
                  
                  const SizedBox(height: 20),
                  if (hasSelected)
                    Wrap( // Use Wrap for responsive bulk actions
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text("Bulk Action: ", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                        ElevatedButton(onPressed: () => _updateStatusForSelected(context, 'Processing'), child: const Text("Mark Processing")),
                        ElevatedButton(onPressed: () => _updateStatusForSelected(context, 'Shipped'), child: const Text("Mark Shipped")),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green), 
                          onPressed: () => _updateStatusForSelected(context, 'Completed'), 
                          child: const Text("Mark Completed", style: TextStyle(color: Colors.white))
                        ),
                      ],
                    )
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


// --- NEW MOBILE ORDER CARD WIDGET ---
class MobileOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isSelected;
  final ValueChanged<bool?> onSelect;

  const MobileOrderCard({
    super.key,
    required this.order,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Order ID: ${order.id.substring(0, 5)}...",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  "\$${order.total.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const Divider(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer: ${order.customerId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text("Time: ${order.formattedOrderTime}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    Chip(
                      label: Text(
                        order.orderStatus,
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                      backgroundColor: order.statusColor,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ),
                    Checkbox(
                      value: isSelected,
                      onChanged: onSelect,
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}