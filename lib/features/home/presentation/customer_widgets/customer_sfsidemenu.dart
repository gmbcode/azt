import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: double.infinity,
      color: const Color.fromARGB(255, 104, 147, 190),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const SizedBox(height: 30),
          MenuItem(
            icon: Icons.home_outlined,
            title: 'Home',
            isActive: widget.selectedIndex == 0,
            onTap: () => widget.onItemTapped(0),
          ),
          MenuItem(
            icon: Icons.search,
            title: 'Search Products',
            isActive: widget.selectedIndex == 1,
            onTap: () => widget.onItemTapped(1),
          ),
          MenuItem(
            icon: Icons.shopping_cart_checkout_outlined,
            title: 'My Cart',
            isActive: widget.selectedIndex == 2,
            onTap: () => widget.onItemTapped(2),
          ),
          MenuItem(
            icon: Icons.payment_outlined,
            title: 'Checkout',
            isActive: widget.selectedIndex == 3,
            onTap: () => widget.onItemTapped(3),
          ),
          // New Menu Item
          MenuItem(
            icon: Icons.history,
            title: 'Your Orders',
            isActive: widget.selectedIndex == 4,
            onTap: () => widget.onItemTapped(4),
          ),
          const Spacer(),
          MenuItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () => widget.onItemTapped(5), // Changed index to 5
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class MenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: widget.isActive
              ? Colors.black.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}