import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
    this.onTap,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.isSelected
          ? Colors.orange // Selected color
          : _isHovered
              ? Colors.white.withOpacity(0.1) // Hover color
              : Colors.transparent, // Default color
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) {
          setState(() {
            _isHovered = hovering;
          });
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? Colors.white : Colors.white70,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.white70,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}