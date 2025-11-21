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
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoaded) {
          final cart = state.cart;
          double total = cart.fold(0, (sum, item) => sum + (item.price * item.qty));

          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade700),
                  const SizedBox(height: 16),
                  const Text("Your cart is empty", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.length,
                  separatorBuilder: (_,__) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.image)),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("\$${item.price} x ${item.qty}", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => context.read<CustomerCubit>().decrementCartItem(item.productId),
                            ),
                            Text("${item.qty}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              // We need logic to check stock limit, but for now just increment
                              onPressed: () {
                                context.read<CustomerCubit>().incrementCartItem(item.productId);
                              }, 
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Checkout Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Delivery Address",
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Amount", style: TextStyle(fontSize: 16)),
                        Text("\$${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_addressController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter delivery address")));
                            return;
                          }
                          context.read<CustomerCubit>().checkout(_addressController.text);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully!"), backgroundColor: Colors.green));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text("Checkout Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}