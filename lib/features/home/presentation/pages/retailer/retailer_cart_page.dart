import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';

class RetailerCartPage extends StatefulWidget {
  const RetailerCartPage({super.key});
  @override
  State<RetailerCartPage> createState() => _RetailerCartPageState();
}

class _RetailerCartPageState extends State<RetailerCartPage> {
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: BlocBuilder<RetailerCubit, RetailerState>(
        builder: (context, state) {
          if (state is RetailerLoaded) {
            final cart = state.cartItems;
            double total = 0;
            for (var item in cart) { total += item['price'] * item['qty']; }

            if (cart.isEmpty) return const Center(child: Text("Cart is empty"));

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image)),
                        title: Text(item['name']),
                        // Rupee Symbol Fix
                        subtitle: Text("${item['qty']} x ₹${item['price']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context.read<RetailerCubit>().removeFromCart(item['id']),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.secondary,
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
                          // Rupee Symbol Fix
                          Text("Total: ₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ElevatedButton(
                            onPressed: () {
                              if (_addressController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address Required")));
                                return;
                              }
                              context.read<RetailerCubit>().checkout(_addressController.text);
                              Navigator.pop(context);
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