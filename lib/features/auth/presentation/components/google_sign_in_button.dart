import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class MyGoogleSignInButton extends StatelessWidget {
  final void Function()? onTap;
  const MyGoogleSignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Add some padding inside the button
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ), // BoxDecoration
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the content
          children: [
            // Your original image
            Image.asset(
              'lib/features/assets/googleimg.jpg',
              height: 30,
            ), // Image.asset

            // Add space between image and text
            const SizedBox(width: 12),

            // Your new text
            const Text(
              "Sign In Using Google",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ), // Row
      ), // Container
    ); // GestureDetector
  }
}