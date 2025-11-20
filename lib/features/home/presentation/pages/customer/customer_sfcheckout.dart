import 'package:flutter/material.dart';

import '../../customer_widgets/customer_sfproductcards.dart';

class CheckoutPage extends StatefulWidget {
  // The cart list passed from the main screen
  final List<Product> cart;
  // Callback for when payment is completed
  final VoidCallback onPaymentSuccess;

  const CheckoutPage({
    super.key, 
    required this.cart,
    required this.onPaymentSuccess, // Add this required parameter
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // Helper function to parse price string like "₹2.99" to a double
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

    // Iterate over widget.cart to calculate totals
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
              'Checkout Summary',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            if (widget.cart.isEmpty)
              const Center(
                child: Text(
                  'Your cart is empty. Nothing to check out.',
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
                    backgroundColor:
                        const Color.fromARGB(255, 55, 214, 92), // Green for Pay
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // Trigger the payment success callback
                    widget.onPaymentSuccess(); 
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment done'),
                        backgroundColor: Color.fromARGB(255, 11, 187, 34),
                      ),
                    );
                  },
                  child: const Text('Pay Now'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}