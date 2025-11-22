import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';
import '../../retailer_widgets/retailer_reusable_search_bar.dart';

class RetailerCustomersPage extends StatefulWidget {
  const RetailerCustomersPage({super.key});

  @override
  State<RetailerCustomersPage> createState() => _RetailerCustomersPageState();
}

class _RetailerCustomersPageState extends State<RetailerCustomersPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RetailerCubit, RetailerState>(
      builder: (context, state) {
        if (state is RetailerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is RetailerLoaded) {
          final filteredCustomers = state.customers.where((c) {
            final term = _searchQuery.toLowerCase();
            return c.username.toLowerCase().contains(term) || 
                   c.email.toLowerCase().contains(term);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                     color: Theme.of(context).colorScheme.secondary,
                     borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Customers',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      ReusableSearchBar(
                        hintText: 'Search by username or email...',
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: filteredCustomers.isEmpty 
                  ? const Center(child: Text("No customers found."))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        // FIXED: Adjusted ratio to preventing bottom overflow
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        
                        final customerOrders = state.customerOrders
                            .where((o) => o.customerId == customer.id) 
                            .toList();
                        
                        final totalSpent = customerOrders.fold(0.0, (sum, o) => sum + o.total);

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    customer.username.isNotEmpty ? customer.username[0].toUpperCase() : '?',
                                    style: TextStyle(color: Colors.blue[800], fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  customer.username,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  customer.email,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Column(
                                      children: [
                                        const Text("Orders", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        Text("${customerOrders.length}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text("Spent", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                        // FIXED: Currency Symbol
                                        Text("₹${totalSpent.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}