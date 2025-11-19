import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;

  final String text;

  final bool isSelected;

  final VoidCallback? onTap;

  const SidebarItem({
    super.key,

    required this.icon,

    required this.text,

    this.isSelected = false,

    this.onTap,
  });

  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),

        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),

        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange
              : const Color.fromARGB(255, 2, 18, 37),

          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white),

            const SizedBox(width: 12),

            Text(
              text,

              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,

                fontSize: 16,

                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
