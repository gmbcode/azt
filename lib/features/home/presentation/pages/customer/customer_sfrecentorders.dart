import 'package:flutter/material.dart';

import '../../customer_widgets/customer_sfproductcards.dart';

class RecentOrdersPage extends StatefulWidget {
  final List<List<Product>> orders;

  const RecentOrdersPage({super.key, required this.orders});

  @override
  State<RecentOrdersPage> createState() => _RecentOrdersPageState();
}

class _RecentOrdersPageState extends State<RecentOrdersPage> {
  // Helper to parse price
  double parsePrice(String price) {
    try {
      return double.parse(price.replaceAll('₹', ''));
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Orders',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            if (widget.orders.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No recent orders.',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: widget.orders.length,
                  itemBuilder: (context, index) {
                    // Orders are stored newest first, so Order # is logic based on length
                    final orderNumber = widget.orders.length - index;
                    final List<Product> currentOrder = widget.orders[index];
                    
                    // Calculate totals and group items for this specific order
                    final Map<String, int> productCounts = {};
                    final Map<String, Product> productData = {};
                    double orderTotal = 0.0;

                    for (final product in currentOrder) {
                      productData[product.name] = product;
                      productCounts[product.name] = (productCounts[product.name] ?? 0) + 1;
                      orderTotal += parsePrice(product.price);
                    }

                    final uniqueProducts = productCounts.keys.toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #$orderNumber',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 31, 104, 178),
                                  ),
                                ),
                                Text(
                                  'Total: ₹${orderTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            // List of items in this order
                            ...uniqueProducts.map((name) {
                              final count = productCounts[name];
                              final product = productData[name]!;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${count}x',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      product.price,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  'Paid',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
}