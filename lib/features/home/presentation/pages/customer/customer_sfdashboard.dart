import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(5, 31, 104, 178),
      child: DashboardMainContent(onNavigate: widget.onNavigate),
    );
  }
}

class DashboardMainContent extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardMainContent({super.key, required this.onNavigate});

  @override
  State<DashboardMainContent> createState() => _DashboardMainContentState();
}

class _DashboardMainContentState extends State<DashboardMainContent> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Your Orders page (Index 4)
                      widget.onNavigate(4);
                    },
                    child: InfoCard(
                      title: 'Recent Orders',
                      color: const Color.fromARGB(255, 183, 92, 18),
                      child: Container(),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InfoCard(
                    title: 'Account Credit',
                    color: const Color(0xFF2C3E50),
                    child: Container(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InfoCard(
                    title: 'Exclusive Deals',
                    color: const Color.fromARGB(255, 55, 214, 92),
                    child: Container(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: InfoCard(
                    title: 'New Arrivals',
                    color: const Color.fromARGB(255, 19, 132, 150),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatefulWidget {
  final String title;
  final Color color;
  final Widget child;

  const InfoCard({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}