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

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(30),
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
                  
                  OrderSearchBar(onSearch: (val) => setState(() => _searchTerm = val)),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor), // Dynamic Border
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: OrderTable(
                        orders: currentOrders,
                        selectionMap: _selectionMap,
                        onOrderSelectionChanged: (id, val) => setState(() => _selectionMap[id] = val),
                        onSelectAll: (val) => _onSelectAll(currentOrders, val),
                        allSelected: allSelected,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  if (hasSelected)
                    Row(
                      children: [
                        Text("Bulk Action: ", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                        const SizedBox(width: 10),
                        ElevatedButton(onPressed: () => _updateStatusForSelected(context, 'Processing'), child: const Text("Mark Processing")),
                        const SizedBox(width: 10),
                        ElevatedButton(onPressed: () => _updateStatusForSelected(context, 'Shipped'), child: const Text("Mark Shipped")),
                        const SizedBox(width: 10),
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