import 'package:flutter/material.dart';
import '../../../customer/data/models/customer_product_model.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Container with "Heart" Icon
          Expanded(
            flex: 3, // Takes up more space like the reference
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(6), // Inner padding for "framed" look
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white, // White bg for product images usually looks better
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.contain, // Contain preserves aspect ratio of shoes/items
                    errorBuilder: (_,__,___) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
                    ),
                  ),
                ),
                // Heart Icon (Visual only for now)
                Positioned(
                  top: 12,
                  right: 12,
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
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  
                  // Price and Add Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: Colors.white, // Price pop
                        ),
                      ),
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
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}