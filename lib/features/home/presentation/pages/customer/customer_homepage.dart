import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the Auth Cubit
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../customer_widgets/customer_sfproductcards.dart';
import '../../customer_widgets/customer_sfsidemenu.dart';
import 'customer_sfcart.dart';
import 'customer_sfcheckout.dart';
import 'customer_sfdashboard.dart';
import 'customer_sfrecentorders.dart';
import 'customer_sfsearch.dart';



class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int _selectedIndex = 0;

  // This list holds the products in our cart
  final List<Product> _cart = [];

  // This list holds the confirmed orders (List of Lists)
  final List<List<Product>> _recentOrders = [];

  // Callback to add a product to the cart
  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Callback to remove a product from the cart
  void _removeFromCart(Product product) {
    setState(() {
      _cart.remove(product);
    });
  }

  // Logic to handle successful payment
  void _handlePaymentSuccess() {
    setState(() {
      if (_cart.isNotEmpty) {
        // Create a copy of current cart and add to orders
        _recentOrders.insert(0, List.from(_cart));
        // Clear the cart
        _cart.clear();
      }
    });
  }

  void _onItemTapped(int index) {
    // Logout is index 5 in your side menu
    if (index == 5) {
      _confirmLogout();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Call the AuthCubit to perform the actual logout
              context.read<AuthCubit>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the pages
    final List<Widget> pages = <Widget>[
      DashboardPage(
        onNavigate: _onItemTapped, // Pass the navigation callback
      ),
      SearchPage(
        onAddToCart: _addToCart,
        onRemoveFromCart: _removeFromCart,
        cart: _cart,
      ),
      MyCartPage(
        cart: _cart,
        onRemoveFromCart: _removeFromCart,
        onItemTapped: _onItemTapped,
      ),
      CheckoutPage(
        cart: _cart,
        onPaymentSuccess: _handlePaymentSuccess,
      ),
      RecentOrdersPage(
        orders: _recentOrders,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SideMenu(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
            Expanded(
              // IndexedStack preserves state when switching tabs
              child: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}