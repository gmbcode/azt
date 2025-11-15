import 'package:flutter/material.dart';
import 'pages/retailer_dashboard_page.dart';

class RetailerApp extends StatelessWidget {
  const RetailerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retailer Hub', // Changed title
      // We're keeping the theme from before as it matches the app style
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[200], // Light background for pages
        // Define text styles to be consistent
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        // Style for all ElevatedButtons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Use orange as the main button color
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      
      // --- START PAGE ---
      // The app will now open directly to your new Retailer Dashboard.
      home: const RetailerDashboardPage(),
    );
  }
}