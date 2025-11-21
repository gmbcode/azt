import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_retailer_search_bar.dart';

class RetailersPage extends StatefulWidget {
  const RetailersPage({super.key});

  @override
  State<RetailersPage> createState() => _RetailersPageState();
}

class _RetailersPageState extends State<RetailersPage> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WholesalerCubit, WholesalerState>(
      builder: (context, state) {
        if (state is WholesalerLoading) return const Center(child: CircularProgressIndicator());
        
        if (state is WholesalerLoaded) {
          final filteredRetailers = state.retailers.where((retailer) {
            final term = _searchTerm.toLowerCase();
            return retailer.businessName.toLowerCase().contains(term) ||
                   retailer.address.toLowerCase().contains(term);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Retailers", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      RetailerSearchBar(onSearch: (term) => setState(() => _searchTerm = term)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredRetailers.isEmpty 
                    ? Center(child: Text("No retailers found.", style: TextStyle(color: Theme.of(context).hintColor)))
                    : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1.2, 
                      ),
                      itemCount: filteredRetailers.length,
                      itemBuilder: (context, index) {
                        final retailer = filteredRetailers[index];
                        return Card(
                          elevation: 2,
                          // FIX: Added scroll view to prevent overflow on small screens
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 30, 
                                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1), 
                                    child: Icon(Icons.store, color: Theme.of(context).colorScheme.secondary, size: 30)
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    retailer.businessName, 
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    retailer.address, 
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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