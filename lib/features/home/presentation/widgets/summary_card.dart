import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData? icon; // We make the icon optional now

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.icon, // It can be null
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      color: color,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // We remove the icon row and just have title and value
          children: [
            Text(
              title, // Removed .toUpperCase() to match screenshot
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16, // Screenshot font looks a bit bigger
                fontWeight: FontWeight.w600, // Light bold
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36, // Large text for the value
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}