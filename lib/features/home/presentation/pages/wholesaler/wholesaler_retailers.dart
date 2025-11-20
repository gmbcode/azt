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

          // Theme Colors
          final surfaceColor = Theme.of(context).colorScheme.surface;
          final primaryColor = Theme.of(context).primaryColor;
          final secondaryColor = Theme.of(context).colorScheme.secondary;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: surfaceColor, // Dynamic Surface
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Retailers", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
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
                        childAspectRatio: 1.0,
                      ),
                      itemCount: filteredRetailers.length,
                      itemBuilder: (context, index) {
                        final retailer = filteredRetailers[index];
                        return Card(
                          // Card color is handled by Theme.cardTheme automatically
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30, 
                                  backgroundColor: secondaryColor.withOpacity(0.1), // Light accent bg
                                  child: Icon(Icons.store, color: secondaryColor, size: 30)
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
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: secondaryColor),
                                      foregroundColor: secondaryColor,
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Details for ${retailer.businessName}"))
                                      );
                                    }, 
                                    child: const Text("View Profile")
                                  ),
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
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}