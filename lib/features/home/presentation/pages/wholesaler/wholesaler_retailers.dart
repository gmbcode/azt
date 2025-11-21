import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../wholesaler/presentation/cubits/wholesaler_cubit.dart';
import '../../wholesaler_widgets/wholesaler_retailer_search_bar.dart';
import '../../../../wholesaler/data/models/retailer_model.dart';

class RetailersPage extends StatefulWidget {
  const RetailersPage({super.key});

  @override
  State<RetailersPage> createState() => _RetailersPageState();
}

class _RetailersPageState extends State<RetailersPage> {
  String _searchTerm = '';

  Widget _buildRetailerItem(BuildContext context, WholesalerViewRetailerModel retailer, bool isMobile, Color secondaryColor) {
    if (isMobile) {
      // Mobile ListTile View
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: secondaryColor.withOpacity(0.1),
            child: Icon(Icons.store, color: secondaryColor, size: 24)
          ),
          title: Text(retailer.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(retailer.address, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
          trailing: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: secondaryColor),
              foregroundColor: secondaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(fontSize: 12)
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Details for ${retailer.businessName}"))
              );
            }, 
            child: const Text("View")
          ),
        ),
      );
    } else {
      // Desktop Grid Card View (original)
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30, 
                backgroundColor: secondaryColor.withOpacity(0.1),
                child: Icon(Icons.store, color: secondaryColor, size: 30)
              ),
              const SizedBox(height: 10),
              Text(
                retailer.businessName, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Text(
                retailer.address, 
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                maxLines: 1, 
                overflow: TextOverflow.ellipsis,
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
    }
  }


  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    
    // Corrected the syntax here
    final isMobile = MediaQuery.of(context).size.width < 600;

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
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Container(
              padding: isMobile ? const EdgeInsets.all(15) : const EdgeInsets.all(30), // Reduced padding for mobile
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Responsive Header: Title and Search
                  isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Retailers", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: RetailerSearchBar(onSearch: (term) => setState(() => _searchTerm = term)),
                        ),
                      ],
                    )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Retailers", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                      SizedBox(width: 300, child: RetailerSearchBar(onSearch: (term) => setState(() => _searchTerm = term))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: filteredRetailers.isEmpty 
                    ? Center(child: Text("No retailers found.", style: TextStyle(color: Theme.of(context).hintColor)))
                    : isMobile
                      ? ListView.builder( // Mobile List View
                          itemCount: filteredRetailers.length,
                          itemBuilder: (context, index) {
                            return _buildRetailerItem(context, filteredRetailers[index], true, secondaryColor);
                          },
                        )
                      : GridView.builder( // Desktop Grid View
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 300,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: filteredRetailers.length,
                          itemBuilder: (context, index) {
                            return _buildRetailerItem(context, filteredRetailers[index], false, secondaryColor);
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