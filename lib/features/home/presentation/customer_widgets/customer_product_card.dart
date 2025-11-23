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
    required this.onAdd
  });

  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('This is the maximum quantity that can be ordered.'),
      duration: const Duration(seconds: 2), 
    );
    
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        int inCartQty = 0;
        
        if (state is CustomerLoaded) {
          final index = state.cart.indexWhere((item) => item.productId == product.id);
          if (index != -1) {
            inCartQty = state.cart[index].qty;
          }
        }

        final bool isMaxReached = inCartQty >= product.availableQty;
        final bool isOutOfStock = product.availableQty == 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl, 
                      fit: BoxFit.cover, 
                      errorBuilder: (_,__,___) => Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                    ),
                    if (isOutOfStock)
                      Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: const Text("SOLD OUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              
              // Details Section
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 4),
                    
                    // --- Retailer Name ---
                    Text(
                      "Sold by ${product.retailerName}",
                      style: TextStyle(fontSize: 10, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // ----------------------------

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Button Logic
                    if (isOutOfStock)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: null, 
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                          child: const Text("Out of Stock", style: TextStyle(fontSize: 12))
                        ),
                      )
                    else if (inCartQty == 0)
                       LayoutBuilder(
                        builder: (context, constraints) {
                          // Check if the screen is mobile width
                          bool isMobile = MediaQuery.of(context).size.width < 600;
                          
                          return SizedBox(
                            width: double.infinity,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: onAdd,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Always Black
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.zero, // Ensures icon is centered
                              ),
                              // Show Icon on mobile, Text on desktop
                              child: isMobile
                                  ? const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20)
                                  : const Text("Add to Cart", style: TextStyle(fontSize: 12, color: Colors.white)),
                            ),
                          );
                        }
                      )
                    else
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16, color: Colors.red),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => context.read<CustomerCubit>().decrementCartItem(product.id),
                            ),
                            
                            Text(
                              '$inCartQty', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)
                            ),
                            
                            IconButton(
                              icon: Icon(Icons.add, size: 16, color: isMaxReached ? Colors.grey : Colors.green),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: isMaxReached 
                                ? () => ScaffoldMessenger.of(context).showSnackBar(snackBar)
                                : () => context.read<CustomerCubit>().incrementCartItem(product.id),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}