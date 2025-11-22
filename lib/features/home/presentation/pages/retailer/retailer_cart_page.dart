import 'package:azt/config/razorpay_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../retailer/presentation/cubits/retailer_cubit.dart';


class RetailerCartPage extends StatefulWidget {
  const RetailerCartPage({super.key});
  @override
  State<RetailerCartPage> createState() => _RetailerCartPageState();
}

class _RetailerCartPageState extends State<RetailerCartPage> {
  final _addressController = TextEditingController();
  late Razorpay _razorpay;
  bool _isProcessingPayment = false;
  double _pendingTotal = 0;
  String _pendingAddress = '';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _addressController.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!mounted) return;
    
    setState(() => _isProcessingPayment = false);
    
    // Payment successful - Complete the order
    context.read<RetailerCubit>().checkout(_pendingAddress);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful! Order ID: ${response.orderId ?? 'N/A'}'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back after order placement
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    
    setState(() => _isProcessingPayment = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? 'Unknown error'}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    
    setState(() => _isProcessingPayment = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName ?? 'Unknown'}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openRazorpayCheckout(double amount, String address) {
    if (_isProcessingPayment) return; // Prevent duplicate calls
    
    setState(() {
      _isProcessingPayment = true;
      _pendingTotal = amount;
      _pendingAddress = address;
    });

    var options = {
      'key': RazorpayConfig.keyId,
      'amount': (amount * 100).toInt(), // Amount in paise
      'name': RazorpayConfig.companyName,
      'description': 'Payment for Wholesale Purchase',
      'prefill': {
        'contact': '9999999999',
        'email': 'retailer@example.com'
      },
      'theme': {
        'color': RazorpayConfig.themeColor
      },
      'image': RazorpayConfig.companyLogo,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessingPayment = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening Razorpay: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: BlocBuilder<RetailerCubit, RetailerState>(
        builder: (context, state) {
          if (state is RetailerLoaded) {
            final cart = state.cartItems;
            double total = 0;
            for (var item in cart) { 
              total += item['price'] * item['qty']; 
            }

            if (cart.isEmpty) {
              return const Center(
                child: Text("Cart is empty", style: TextStyle(fontSize: 18))
              );
            }

            return Column(
              children: [
                // 1. Cart List
                Expanded(
                  child: ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        leading: Image.network(
                          item['imageUrl'], 
                          width: 50, 
                          height: 50, 
                          fit: BoxFit.cover, 
                          errorBuilder: (_,__,___) => const Icon(Icons.image)
                        ),
                        title: Text(item['name']),
                        subtitle: Text("${item['qty']} x ₹${item['price']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => context.read<RetailerCubit>().removeFromCart(item['id']),
                        ),
                      );
                    },
                  ),
                ),
                
                // 2. Address & Checkout Section
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.secondary,
                  child: Column(
                    children: [
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: "Delivery Address", 
                          border: OutlineInputBorder()
                        ),
                        enabled: !_isProcessingPayment,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total: ₹${total.toStringAsFixed(2)}", 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                          ElevatedButton(
                            onPressed: _isProcessingPayment ? null : () {
                              if (_addressController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Address Required"))
                                );
                                return;
                              }
                              
                              // Open Razorpay
                              _openRazorpayCheckout(total, _addressController.text);
                            }, 
                            child: _isProcessingPayment 
                              ? const SizedBox(
                                  width: 20, 
                                  height: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : const Text("Pay with Razorpay")
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