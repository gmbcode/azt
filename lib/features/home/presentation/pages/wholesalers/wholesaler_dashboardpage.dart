// lib/pages/dashboardpage.dart

import 'package:azt/features/home/presentation/wholesaler_widgets/wholesaler_summary_card.dart';
import 'package:flutter/material.dart';

import '../../wholesaler_widgets/wholesaler_Main_sidebar.dart';
import '../../wholesaler_widgets/wholesaler_recent_orders_table.dart';


class WholesalerDashboardPage extends StatelessWidget {
  const WholesalerDashboardPage({super.key});

  
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // 1. Add the new sidebar widget
          const MainSidebar(selectedPage: 'dashboard'),

          // 2. This is your updated dashboard content
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- THIS IS THE NEW HEADER ---
                      const Text(
                        "Dashboard",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // --- END OF NEW HEADER ---

                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Expanded(
                            child: SummaryCard(
                              fontsize: 40,
                              color: Colors.green,
                              value: '854',
                              text: "Pending Order",
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: SummaryCard(
                              fontsize: 25,
                              color: Colors.red,
                              value: '\$7943',
                              text: "Revenue",
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: SummaryCard(
                              fontsize: 35,
                              color: Colors.blue,
                              value: '124',
                            text: "Low Stock Item",
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: SummaryCard(
                              fontsize: 25,
                              color: Color.fromARGB(255, 181, 30, 155),
                              value: '25',
                              text: "New Retailer",
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      const RecentOrdersTable(),
                      const SizedBox(height: 20), // Padding at the bottom
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}