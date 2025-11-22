import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../customer/presentation/cubits/customer_cubit.dart';

class CustomerCartPage extends StatefulWidget {
  const CustomerCartPage({super.key});
  @override
  State<CustomerCartPage> createState() => _CustomerCartPageState();
}

class _CustomerCartPageState extends State<CustomerCartPage> {
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoaded) {
            final cart = state.cart;
            
            // LOGIC PRESERVED: Calculate Total
            double total = 0;
            for (var item in cart) { total += item.price * item.qty; }

            if (cart.isEmpty) return const Center(child: Text("Cart is empty"));

            return Column(
              children: [
                // 1. Cart List
                Expanded(
                  child: ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      String roundedprice = item.price.toStringAsFixed(2);
                      return ListTile(
                        leading: Image.network(
                          item.imageUrl, 
                          width: 50, 
                          height: 50, 
                          fit: BoxFit.cover, 
                          errorBuilder: (_,__,___) => const Icon(Icons.image)
                        ),
                        title: Text(item.name),
                        // Currency Fix
                        subtitle: Text("${item.qty} x ₹$roundedprice"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          // Logic Preserved: Calls remove from Cubit
                          onPressed: () => context.read<CustomerCubit>().removeFromCart(item.productId),
                        ),
                      );
                    },
                  ),
                ),
                
                // 2. Address & Checkout Section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black,
                  child: Column(
                    children: [
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: "Delivery Address", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Currency Fix
                          Text("Total: ₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            onPressed: () async {
                              if (_addressController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address Required")));
                                return;
                              }
                              
                              // UPDATED: Await the checkout logic
                              // The Cubit will clear the cart first, then place the order.
                              await context.read<CustomerCubit>().checkout(_addressController.text);
                              
                              // UPDATED: Check if still mounted before popping to prevent crash
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully")));
                              }
                            }, 
                            child: const Text("Checkout")
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}