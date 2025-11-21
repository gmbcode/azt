import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/data/models/customer_product_model.dart';
import '../../../customer/presentation/cubits/customer_cubit.dart';

class CustomerProductCard extends StatelessWidget {
  final CustomerProductModel product;
  final VoidCallback onAdd;

  const CustomerProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        int qtyInCart = 0;
        
        // FIX: Safe lookup logic. 
        // Prevents "Bad state: No element" error when cart is empty.
        if (state is CustomerLoaded) {
          // Use .where() instead of .firstWhere() to avoid crashing if not found
          final found = state.cart.where((i) => i.productId == product.id);
          if (found.isNotEmpty) {
            qtyInCart = found.first.qty;
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Section
              Expanded(
                flex: 3, 
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(6), 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain, 
                        errorBuilder: (_,__,___) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12, right: 12,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black.withOpacity(0.8),
                        child: const Icon(Icons.favorite_border, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 2. Info Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category.toUpperCase(),
                            style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // PRICE WITH RUPEE
                          Text(
                            "₹${product.price.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                          ),
                          
                          // ADD / COUNTER BUTTON LOGIC
                          if (qtyInCart == 0)
                            InkWell(
                              onTap: onAdd,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 20),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => context.read<CustomerCubit>().decrementCartItem(product.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.remove, size: 16, color: Colors.white),
                                    )
                                  ),
                                  Text("$qtyInCart", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  InkWell(
                                    onTap: () => context.read<CustomerCubit>().incrementCartItem(product.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.add, size: 16, color: Colors.white),
                                    )
                                  ),
                                ],
                              ),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}