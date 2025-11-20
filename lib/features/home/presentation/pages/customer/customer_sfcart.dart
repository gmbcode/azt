import 'package:flutter/material.dart';

import '../../customer_widgets/customer_sfproductcards.dart';

class MyCartPage extends StatefulWidget {
  final List<Product> cart;
  final Function(Product) onRemoveFromCart;
  final Function(int) onItemTapped;

  const MyCartPage({
    super.key,
    required this.cart,
    required this.onRemoveFromCart,
    required this.onItemTapped,
  });

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  double parsePrice(String price) {
    try {
      return double.parse(price.replaceAll('₹', ''));
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> productCounts = {};
    final Map<String, Product> productData = {};
    double grandTotal = 0.0;

    // Iterate over widget.cart
    for (final product in widget.cart) {
      productData[product.name] = product;
      productCounts[product.name] = (productCounts[product.name] ?? 0) + 1;
      grandTotal += parsePrice(product.price);
    }

    final uniqueProductNames = productCounts.keys.toList();

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Cart',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            if (widget.cart.isEmpty)
              const Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: uniqueProductNames.length,
                  itemBuilder: (context, index) {
                    final productName = uniqueProductNames[index];
                    final product = productData[productName]!;
                    final count = productCounts[productName]!;
                    final double itemPrice = parsePrice(product.price);
                    final double itemTotal = itemPrice * count;

                    return Card(
                      color: Colors.grey.shade100,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              const Color.fromARGB(255, 104, 147, 190),
                          child: Text(
                            'x$count',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          '${product.price} each (Total: ₹${itemTotal.toStringAsFixed(2)})',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_shopping_cart,
                              color: Colors.red),
                          // Use widget.onRemoveFromCart
                          onPressed: () => widget.onRemoveFromCart(product),
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            if (widget.cart.isNotEmpty) ...[
              const Divider(height: 30, thickness: 1, color: Colors.black12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Grand Total: ₹${grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 19, 132, 150),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // Use widget.onItemTapped
                    widget.onItemTapped(3);
                  },
                  child: const Text('Proceed to Checkout'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}