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

  final List<Product> _cart = [];
  final List<List<Product>> _recentOrders = [];

  void _addToCart(Product product) {
    setState(() {
      _cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart!'), duration: const Duration(seconds: 1)),
    );
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cart.remove(product);
    });
  }

  void _handlePaymentSuccess() {
    setState(() {
      if (_cart.isNotEmpty) {
        _recentOrders.insert(0, List.from(_cart));
        _cart.clear();
      }
    });
  }

  void _onItemTapped(int index) {
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
    final List<Widget> pages = <Widget>[
      DashboardPage(onNavigate: _onItemTapped),
      SearchPage(onAddToCart: _addToCart, onRemoveFromCart: _removeFromCart, cart: _cart),
      MyCartPage(cart: _cart, onRemoveFromCart: _removeFromCart, onItemTapped: _onItemTapped),
      CheckoutPage(cart: _cart, onPaymentSuccess: _handlePaymentSuccess),
      RecentOrdersPage(orders: _recentOrders),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          appBar: isMobile 
            ? AppBar(
                title: const Text("Shop"),
                backgroundColor: const Color.fromARGB(255, 104, 147, 190),
                actions: [
                  IconButton(icon: const Icon(Icons.logout), onPressed: _confirmLogout)
                ],
              ) 
            : null,
          
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  SideMenu(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
                
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: pages),
                ),
              ],
            ),
          ),
          
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex > 4 ? 0 : _selectedIndex, // Handle logout index safety
                  onTap: _onItemTapped,
                  selectedItemColor: const Color.fromARGB(255, 104, 147, 190),
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
                    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
                    BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pay'),
                    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
                  ],
                )
              : null,
        );
      }
    );
  }
}