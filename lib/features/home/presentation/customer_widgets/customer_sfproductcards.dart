import 'package:flutter/material.dart';

class Product {
  final String name;
  final String price;
  const Product({required this.name, required this.price});
}

final List<Product> productList = [
  const Product(name: 'Apple', price: '₹40'),
  const Product(name: 'Headphone', price: '₹2500'),
  const Product(name: 'Banana', price: '₹8'),
  const Product(name: 'Pencil', price: '₹5'),
  const Product(name: 'Bottle', price: '₹500'),
  const Product(name: 'Lock', price: '₹200'),
  const Product(name: 'Marker', price: '₹40'),
  const Product(name: 'Spoon', price: '₹35'),
];

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onRemoveFromCart;
  final List<Product> cart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.cart,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    // Filter the cart to see how many of THIS product are in it
    final int countInCart =
        widget.cart.where((item) => item.name == widget.product.name).length;

    return Card(
      color: const Color.fromARGB(255, 104, 147, 190),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.product.price,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (countInCart > 0)
              Center(
                child: Text(
                  'In Cart: $countInCart',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Use widget.onAddToCart
                      widget.onAddToCart(widget.product);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 31, 104, 178),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: countInCart > 0
                        ? const Icon(Icons.add, size: 18)
                        : const Text('Add to Cart'),
                  ),
                ),
                if (countInCart > 0) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Use widget.onRemoveFromCart
                        widget.onRemoveFromCart(widget.product);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(Icons.remove, size: 18),
                    ),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}