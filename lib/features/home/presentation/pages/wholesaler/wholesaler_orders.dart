import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../wholesaler/data/models/order_model.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_order_filter_chips.dart';
import '../../wholesaler_widgets/wholesaler_order_search_bar.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String _selectedFilter = 'All';
  String _searchTerm = '';
  Map<String, bool> _selectionMap = {};

  String _getRetailerName(String uid, List<dynamic> retailers) {
    try {
      final retailer = retailers.firstWhere((r) => r.uid == uid);
      return retailer.businessName;
    } catch (e) {
      return 'Retailer ($uid)';
    }
  }

  // Confirmation Dialog
  Future<bool> _showConfirmationDialog(BuildContext context, String status) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Set Order to $status?"),
        content: Text("Are you sure you want to mark the selected orders as $status? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    ) ?? false;
  }

  void _updateStatusForSelected(BuildContext context, String newStatus, List<OrderModel> currentOrders) async {
    final selectedIds = _selectionMap.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selectedIds.isEmpty) return;

    // Show confirmation for Critical Actions
    if (newStatus == 'Completed' || newStatus == 'Cancelled') {
      final confirm = await _showConfirmationDialog(context, newStatus);
      if (!confirm) return;
    }

    for (var id in selectedIds) {
      // Pass items if Cancelling to handle restocking
      if (newStatus == 'Cancelled') {
         final order = currentOrders.firstWhere((o) => o.id == id);
         context.read<WholesalerCubit>().updateOrderStatus(id, newStatus, itemsToRestock: order.items);
      } else {
         context.read<WholesalerCubit>().updateOrderStatus(id, newStatus);
      }
    }
    setState(() => _selectionMap.clear());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is WholesalerLoaded) {
          List<OrderModel> filtered = state.orders;
          if (_selectedFilter != 'All') filtered = filtered.where((o) => o.orderStatus == _selectedFilter).toList();
          if (_searchTerm.isNotEmpty) filtered = filtered.where((o) => o.id.contains(_searchTerm) || o.customerId.contains(_searchTerm)).toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Orders Management", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                const SizedBox(height: 16),
                SingleChildScrollView(scrollDirection: Axis.horizontal, child: OrderFilterChips(selectedFilter: _selectedFilter, onFilterSelected: (val) => setState(() => _selectedFilter = val))),
                const SizedBox(height: 10),
                OrderSearchBar(onSearch: (val) => setState(() => _searchTerm = val)),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_,__) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final order = filtered[index];
                        final retailerName = _getRetailerName(order.customerId, state.retailers);
                        final isCompleted = order.orderStatus == 'Completed';
                        final isCancelled = order.orderStatus == 'Cancelled';
                        final isLocked = isCompleted || isCancelled;

                        return CheckboxListTile(
                          value: _selectionMap[order.id] ?? false,
                          onChanged: isLocked ? null : (val) => setState(() => _selectionMap[order.id] = val ?? false),
                          enabled: !isLocked,
                          title: Text(retailerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Order #${order.id.substring(0,5)} • ₹${order.total.toStringAsFixed(2)}\n${order.formattedOrderTime}"),
                          secondary: Chip(label: Text(order.orderStatus, style: const TextStyle(color: Colors.white, fontSize: 10)), backgroundColor: order.statusColor, padding: EdgeInsets.zero),
                          isThreeLine: true,
                        );
                      },
                    ),
                  ),
                ),
                if (_selectionMap.values.any((v) => v))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Wrap(
                      spacing: 10,
                      children: [
                        ElevatedButton(onPressed: () => _updateStatusForSelected(context, 'Processing', state.orders), child: const Text("Set Processing")),
                        ElevatedButton(onPressed: () => _updateStatusForSelected(context, 'Shipped', state.orders), child: const Text("Set Shipped")),
                        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () => _updateStatusForSelected(context, 'Completed', state.orders), child: const Text("Set Completed", style: TextStyle(color: Colors.white))),
                        // Added Cancelled Button
                        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => _updateStatusForSelected(context, 'Cancelled', state.orders), child: const Text("Set Cancelled", style: TextStyle(color: Colors.white))),
                      ],
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